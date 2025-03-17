import Egg

-- TODO: This should generate a type class projection reduction from HAdd.hAdd to Add.add.
--       It doesn't because `α` and the `inst : Add α` are bvars.
--       To fix this, the tc-proj generator should generate fvars for the given bvars, perform the
--       reduction, and then over any remaining bvar-fvars.
-- #guard_msgs in
set_option trace.egg true in
set_option egg.builtins false in
example (h : (fun (α) [Mul α] (x y : α) => x * y) = a) : true = true := by
  sorry -- egg [h]

-- TODO: This should generate a goal type specialization for `h`, but I think it doesn't for the
--       same reason as outlined above.
example (h : ∀ {α} [Add α] (a : α), a + a = a) : 1 + 1 = 1 := by
  sorry -- egg [h]

-- This test ensures that projection reductions are produced for terms appearing in binder domains.
/--
info: [egg.rewrites] Rewrites
  [egg.rewrites] Basic (1)
    [egg.rewrites] #0(⇔): h
      [egg.rewrites] z = z
      [egg.rewrites] Conditions
        [egg.rewrites] x * y = z
      [egg.rewrites] LHS MVars
          expr:  []
          class: []
          level: []
      [egg.rewrites] RHS MVars
          expr:  []
          class: []
          level: []
  [egg.rewrites] Tagged (0)
  [egg.rewrites] Generated (2)
    [egg.rewrites] #0[0?69632,0](⇔)
      [egg.rewrites] HMul.hMul = Mul.mul
      [egg.rewrites] LHS MVars
          expr:  []
          class: []
          level: []
      [egg.rewrites] RHS MVars
          expr:  []
          class: []
          level: []
    [egg.rewrites] #0[0?69632,1](⇔)
      [egg.rewrites] Mul.mul = Nat.mul
      [egg.rewrites] LHS MVars
          expr:  []
          class: []
          level: []
      [egg.rewrites] RHS MVars
          expr:  []
          class: []
          level: []
  [egg.rewrites] Exploded (0)
  [egg.rewrites] Builtin (0)
  [egg.rewrites] Hypotheses (0)
  [egg.rewrites] Definitional
  [egg.rewrites] Pruned (0)
-/
#guard_msgs in
set_option linter.unusedVariables false in
set_option trace.egg.rewrites true in
set_option egg.builtins false in
set_option egg.beta false in
set_option egg.eta false in
set_option egg.natLit false in
example (x : Nat) (h : ∀ (_ : x * y = z), z = z) : x = x := by
  egg [h]
