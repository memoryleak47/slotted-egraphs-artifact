import Egg.Tactic.Basic
open Lean Meta Elab Tactic
open Egg.Config.Modifier (egg_cfg_mod)

namespace Egg

private def appendPremises : (TSyntax `egg_premises) → (TSyntax `egg_premises) → TacticM (TSyntax `egg_premises)
  | `(egg_premises|$[$ps₁]?), `(egg_premises|$[$ps₂]?) =>
    match ps₁, ps₂ with
    | ps, none | none, ps => `(egg_premises|$[$ps]?)
    | some ps₁, some ps₂ => do
      match ps₁, ps₂ with
      | `(egg_premise_list| [$rws₁,* $[; $fs₁,*]?]), `(egg_premise_list| [$rws₂,* $[; $fs₂,*]?]) =>
        let rws := rws₁.getElems ++ rws₂
        let fs := match fs₁, fs₂ with
          | fs, none | none, fs => fs
          | some fs₁, some fs₂ => fs₁.getElems ++ fs₂.getElems
        `(egg_premises| [$rws,* $[; $fs,*]?])
      | _, _ => throwUnsupportedSyntax
  | _, _ => throwUnsupportedSyntax

namespace Calc

syntax egg_calc_step := ppIndent(colGe term (&" with " egg_cfg_mod egg_premises)? (egg_guides)?)

private structure Step where
  goal   : Term
  mod    : TSyntax ``egg_cfg_mod
  prems  : TSyntax `egg_premises
  guides : Option (TSyntax `egg_guides)
  deriving Inhabited

private def parseStep : (TSyntax ``egg_calc_step) → TacticM Step
  | `(egg_calc_step| $goal $[with $mod $prems]? $[$guides]?) => do
    let mod ← mod.getDM `(egg_cfg_mod|)
    let prems ← prems.getDM `(egg_premises|)
    return { goal, mod, prems, guides }
  | _ => throwUnsupportedSyntax

syntax egg_calc_steps := ppLine withPosition(egg_calc_step) withPosition((ppLine linebreak egg_calc_step)*)

private structure Steps where
  head : Step
  tail : Array Step
  deriving Inhabited

private def parseSteps : (TSyntax ``egg_calc_steps) → TacticM Steps
  | `(egg_calc_steps| $head $[
      $tail]*) => return { head := ← parseStep head, tail := ← tail.mapM parseStep }
  | _ => throwUnsupportedSyntax

syntax &"egg " &"calc " egg_premises egg_calc_steps : tactic

private def eval
    (prems : TSyntax `egg_premises) (steps : TSyntax ``egg_calc_steps) (bang : Bool := false) :
    TacticM Unit := do
  withMainContext do
    let steps ← parseSteps steps
    let goals := steps.tail.map (·.goal)
    let stepToEgg (step : Step) : TacticM (TSyntax `tactic) := do
      let allPrems ← appendPremises step.prems prems
      if bang
      then `(tactic| egg! $step.mod $allPrems $[$(Option.none)]? $[$step.guides]?)
      else `(tactic| egg  $step.mod $allPrems $[$(Option.none)]? $[$step.guides]?)
    let tailEggs ← steps.tail.mapM stepToEgg
    let headEgg : Option (TSyntax `tactic) ← do
      if (← elabTerm steps.head.goal none).eqOrIff?.isSome
      then pure <| some (← stepToEgg steps.head)
      else pure none
    let stx ← `(tactic| calc $steps.head.goal:term $[:= by $headEgg:tactic]?
                $[
                $goals := by $tailEggs:tactic]*)
    evalTactic stx

elab "egg " "calc " prems:egg_premises steps:egg_calc_steps : tactic =>
  eval prems steps

elab "egg! " "calc " prems:egg_premises steps:egg_calc_steps : tactic =>
  eval prems steps (bang := true)
