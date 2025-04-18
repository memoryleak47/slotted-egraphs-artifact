import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2015 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura, Mario Carneiro
-/
import Mathlib.Data.Bool.Basic
import Mathlib.Data.Option.Defs
import Mathlib.Data.Prod.Basic
import Mathlib.Data.Sigma.Basic
import Mathlib.Data.Subtype
import Mathlib.Data.Sum.Basic
import Mathlib.Logic.Equiv.Defs
import Mathlib.Logic.Function.Conjugate
import Mathlib.Tactic.Coe
import Mathlib.Tactic.Lift
import Mathlib.Tactic.Convert
import Mathlib.Tactic.Contrapose
import Mathlib.Tactic.GeneralizeProofs
import Mathlib.Tactic.SimpRw
import Mathlib.Tactic.CC

/-!
# Equivalence between types

In this file we continue the work on equivalences begun in `Logic/Equiv/Defs.lean`, defining

* canonical isomorphisms between various types: e.g.,

  - `Equiv.sumEquivSigmaBool` is the canonical equivalence between the sum of two types `α ⊕ β`
    and the sigma-type `Σ b : Bool, b.casesOn α β`;

  - `Equiv.prodSumDistrib : α × (β ⊕ γ) ≃ (α × β) ⊕ (α × γ)` shows that type product and type sum
    satisfy the distributive law up to a canonical equivalence;

* operations on equivalences: e.g.,

  - `Equiv.prodCongr ea eb : α₁ × β₁ ≃ α₂ × β₂`: combine two equivalences `ea : α₁ ≃ α₂` and
    `eb : β₁ ≃ β₂` using `Prod.map`.

  More definitions of this kind can be found in other files.
  E.g., `Logic/Equiv/TransferInstance.lean` does it for many algebraic type classes like
  `Group`, `Module`, etc.

## Tags

equivalence, congruence, bijective map
-/

universe u v w z

open Function

-- Unless required to be `Type*`, all variables in this file are `Sort*`
variable {α α₁ α₂ β β₁ β₂ γ δ : Sort*}

namespace Equiv

/-- `PProd α β` is equivalent to `α × β` -/
@[simps apply symm_apply]
def pprodEquivProd {α β} : PProd α β ≃ α × β where
  toFun x := (x.1, x.2)
  invFun x := ⟨x.1, x.2⟩
  left_inv := fun _ => rfl
  right_inv := fun _ => rfl

/-- Product of two equivalences, in terms of `PProd`. If `α ≃ β` and `γ ≃ δ`, then
`PProd α γ ≃ PProd β δ`. -/
-- Porting note: in Lean 3 this had `@[congr]`
@[simps apply]
def pprodCongr (e₁ : α ≃ β) (e₂ : γ ≃ δ) : PProd α γ ≃ PProd β δ where
  toFun x := ⟨e₁ x.1, e₂ x.2⟩
  invFun x := ⟨e₁.symm x.1, e₂.symm x.2⟩
  left_inv := fun ⟨x, y⟩ => by simp
  right_inv := fun ⟨x, y⟩ => by simp

/-- Combine two equivalences using `PProd` in the domain and `Prod` in the codomain. -/
@[simps! apply symm_apply]
def pprodProd {α₂ β₂} (ea : α₁ ≃ α₂) (eb : β₁ ≃ β₂) :
    PProd α₁ β₁ ≃ α₂ × β₂ :=
  (ea.pprodCongr eb).trans pprodEquivProd

/-- Combine two equivalences using `PProd` in the codomain and `Prod` in the domain. -/
@[simps! apply symm_apply]
def prodPProd {α₁ β₁} (ea : α₁ ≃ α₂) (eb : β₁ ≃ β₂) :
    α₁ × β₁ ≃ PProd α₂ β₂ :=
  (ea.symm.pprodProd eb.symm).symm

/-- `PProd α β` is equivalent to `PLift α × PLift β` -/
@[simps! apply symm_apply]
def pprodEquivProdPLift : PProd α β ≃ PLift α × PLift β :=
  Equiv.plift.symm.pprodProd Equiv.plift.symm

/-- Product of two equivalences. If `α₁ ≃ α₂` and `β₁ ≃ β₂`, then `α₁ × β₁ ≃ α₂ × β₂`. This is
`Prod.map` as an equivalence. -/
-- Porting note: in Lean 3 there was also a @[congr] tag
@[simps (config := .asFn) apply]
def prodCongr {α₁ α₂ β₁ β₂} (e₁ : α₁ ≃ α₂) (e₂ : β₁ ≃ β₂) : α₁ × β₁ ≃ α₂ × β₂ :=
  ⟨Prod.map e₁ e₂, Prod.map e₁.symm e₂.symm, fun ⟨a, b⟩ => by simp, fun ⟨a, b⟩ => by simp⟩

@[simp]
theorem prodCongr_symm {α₁ α₂ β₁ β₂} (e₁ : α₁ ≃ α₂) (e₂ : β₁ ≃ β₂) :
    (prodCongr e₁ e₂).symm = prodCongr e₁.symm e₂.symm :=
  rfl

/-- Type product is commutative up to an equivalence: `α × β ≃ β × α`. This is `Prod.swap` as an
equivalence. -/
def prodComm (α β) : α × β ≃ β × α :=
  ⟨Prod.swap, Prod.swap, Prod.swap_swap, Prod.swap_swap⟩

@[simp]
theorem coe_prodComm (α β) : (⇑(prodComm α β) : α × β → β × α) = Prod.swap :=
  rfl

@[simp]
theorem prodComm_apply {α β} (x : α × β) : prodComm α β x = x.swap :=
  rfl

@[simp]
theorem prodComm_symm (α β) : (prodComm α β).symm = prodComm β α :=
  rfl

/-- Type product is associative up to an equivalence. -/
@[simps]
def prodAssoc (α β γ) : (α × β) × γ ≃ α × β × γ :=
  ⟨fun p => (p.1.1, p.1.2, p.2), fun p => ((p.1, p.2.1), p.2.2), fun ⟨⟨_, _⟩, _⟩ => rfl,
    fun ⟨_, ⟨_, _⟩⟩ => rfl⟩

/-- Four-way commutativity of `prod`. The name matches `mul_mul_mul_comm`. -/
@[simps apply]
def prodProdProdComm (α β γ δ) : (α × β) × γ × δ ≃ (α × γ) × β × δ where
  toFun abcd := ((abcd.1.1, abcd.2.1), (abcd.1.2, abcd.2.2))
  invFun acbd := ((acbd.1.1, acbd.2.1), (acbd.1.2, acbd.2.2))
  left_inv := fun ⟨⟨_a, _b⟩, ⟨_c, _d⟩⟩ => rfl
  right_inv := fun ⟨⟨_a, _c⟩, ⟨_b, _d⟩⟩ => rfl

@[simp]
theorem prodProdProdComm_symm (α β γ δ) :
    (prodProdProdComm α β γ δ).symm = prodProdProdComm α γ β δ :=
  rfl

/-- `γ`-valued functions on `α × β` are equivalent to functions `α → β → γ`. -/
@[simps (config := .asFn)]
def curry (α β γ) : (α × β → γ) ≃ (α → β → γ) where
  toFun := Function.curry
  invFun := uncurry
  left_inv := uncurry_curry
  right_inv := curry_uncurry

section

/-- `PUnit` is a right identity for type product up to an equivalence. -/
@[simps]
def prodPUnit (α) : α × PUnit ≃ α :=
  ⟨fun p => p.1, fun a => (a, PUnit.unit), fun ⟨_, PUnit.unit⟩ => rfl, fun _ => rfl⟩

/-- `PUnit` is a left identity for type product up to an equivalence. -/
@[simps!]
def punitProd (α) : PUnit × α ≃ α :=
  calc
    PUnit × α ≃ α × PUnit := prodComm _ _
    _ ≃ α := prodPUnit _

/-- `PUnit` is a right identity for dependent type product up to an equivalence. -/
@[simps]
def sigmaPUnit (α) : (_ : α) × PUnit ≃ α :=
  ⟨fun p => p.1, fun a => ⟨a, PUnit.unit⟩, fun ⟨_, PUnit.unit⟩ => rfl, fun _ => rfl⟩

/-- Any `Unique` type is a right identity for type product up to equivalence. -/
def prodUnique (α β) [Unique β] : α × β ≃ α :=
  ((Equiv.refl α).prodCongr <| equivPUnit.{_,1} β).trans <| prodPUnit α

@[simp]
theorem coe_prodUnique {α β} [Unique β] : (⇑(prodUnique α β) : α × β → α) = Prod.fst :=
  rfl

theorem prodUnique_apply {α β} [Unique β] (x : α × β) : prodUnique α β x = x.1 :=
  rfl

@[simp]
theorem prodUnique_symm_apply {α β} [Unique β] (x : α) : (prodUnique α β).symm x = (x, default) :=
  rfl

/-- Any `Unique` type is a left identity for type product up to equivalence. -/
def uniqueProd (α β) [Unique β] : β × α ≃ α :=
  ((equivPUnit.{_,1} β).prodCongr <| Equiv.refl α).trans <| punitProd α

@[simp]
theorem coe_uniqueProd {α β} [Unique β] : (⇑(uniqueProd α β) : β × α → α) = Prod.snd :=
  rfl

theorem uniqueProd_apply {α β} [Unique β] (x : β × α) : uniqueProd α β x = x.2 :=
  rfl

@[simp]
theorem uniqueProd_symm_apply {α β} [Unique β] (x : α) :
    (uniqueProd α β).symm x = (default, x) :=
  rfl

/-- Any family of `Unique` types is a right identity for dependent type product up to
equivalence. -/
def sigmaUnique (α) (β : α → Type*) [∀ a, Unique (β a)] : (a : α) × (β a) ≃ α :=
  (Equiv.sigmaCongrRight fun a ↦ equivPUnit.{_,1} (β a)).trans <| sigmaPUnit α

@[simp]
theorem coe_sigmaUnique {α} {β : α → Type*} [∀ a, Unique (β a)] :
    (⇑(sigmaUnique α β) : (a : α) × (β a) → α) = Sigma.fst :=
  rfl

theorem sigmaUnique_apply {α} {β : α → Type*} [∀ a, Unique (β a)] (x : (a : α) × β a) :
    sigmaUnique α β x = x.1 :=
  rfl

@[simp]
theorem sigmaUnique_symm_apply {α} {β : α → Type*} [∀ a, Unique (β a)] (x : α) :
    (sigmaUnique α β).symm x = ⟨x, default⟩ :=
  rfl

/-- `Empty` type is a right absorbing element for type product up to an equivalence. -/
def prodEmpty (α) : α × Empty ≃ Empty :=
  equivEmpty _

/-- `Empty` type is a left absorbing element for type product up to an equivalence. -/
def emptyProd (α) : Empty × α ≃ Empty :=
  equivEmpty _

/-- `PEmpty` type is a right absorbing element for type product up to an equivalence. -/
def prodPEmpty (α) : α × PEmpty ≃ PEmpty :=
  equivPEmpty _

/-- `PEmpty` type is a left absorbing element for type product up to an equivalence. -/
def pemptyProd (α) : PEmpty × α ≃ PEmpty :=
  equivPEmpty _

end

section

open Sum

/-- `PSum` is equivalent to `Sum`. -/
def psumEquivSum (α β) : α ⊕' β ≃ α ⊕ β where
  toFun s := PSum.casesOn s inl inr
  invFun := Sum.elim PSum.inl PSum.inr
  left_inv s := by cases s <;> rfl
  right_inv s := by cases s <;> rfl

/-- If `α ≃ α'` and `β ≃ β'`, then `α ⊕ β ≃ α' ⊕ β'`. This is `Sum.map` as an equivalence. -/
@[simps apply]
def sumCongr {α₁ α₂ β₁ β₂} (ea : α₁ ≃ α₂) (eb : β₁ ≃ β₂) : α₁ ⊕ β₁ ≃ α₂ ⊕ β₂ :=
  ⟨Sum.map ea eb, Sum.map ea.symm eb.symm, fun x => by simp, fun x => by simp⟩

/-- If `α ≃ α'` and `β ≃ β'`, then `α ⊕' β ≃ α' ⊕' β'`. -/
def psumCongr (e₁ : α ≃ β) (e₂ : γ ≃ δ) : α ⊕' γ ≃ β ⊕' δ where
  toFun x := PSum.casesOn x (PSum.inl ∘ e₁) (PSum.inr ∘ e₂)
  invFun x := PSum.casesOn x (PSum.inl ∘ e₁.symm) (PSum.inr ∘ e₂.symm)
  left_inv := by rintro (x | x) <;> simp
  right_inv := by rintro (x | x) <;> simp

/-- Combine two `Equiv`s using `PSum` in the domain and `Sum` in the codomain. -/
def psumSum {α₂ β₂} (ea : α₁ ≃ α₂) (eb : β₁ ≃ β₂) :
    α₁ ⊕' β₁ ≃ α₂ ⊕ β₂ :=
  (ea.psumCongr eb).trans (psumEquivSum _ _)

/-- Combine two `Equiv`s using `Sum` in the domain and `PSum` in the codomain. -/
def sumPSum {α₁ β₁} (ea : α₁ ≃ α₂) (eb : β₁ ≃ β₂) :
    α₁ ⊕ β₁ ≃ α₂ ⊕' β₂ :=
  (ea.symm.psumSum eb.symm).symm

@[simp]
theorem sumCongr_trans {α₁ α₂ β₁ β₂ γ₁ γ₂} (e : α₁ ≃ β₁) (f : α₂ ≃ β₂) (g : β₁ ≃ γ₁) (h : β₂ ≃ γ₂) :
    (Equiv.sumCongr e f).trans (Equiv.sumCongr g h) = Equiv.sumCongr (e.trans g) (f.trans h) := by
  ext i
  cases i <;> rfl

@[simp]
theorem sumCongr_symm {α β γ δ} (e : α ≃ β) (f : γ ≃ δ) :
    (Equiv.sumCongr e f).symm = Equiv.sumCongr e.symm f.symm :=
  rfl

@[simp]
theorem sumCongr_refl {α β} :
    Equiv.sumCongr (Equiv.refl α) (Equiv.refl β) = Equiv.refl (α ⊕ β) := by
  ext i
  cases i <;> rfl

/-- A subtype of a sum is equivalent to a sum of subtypes. -/
def subtypeSum {α β} {p : α ⊕ β → Prop} :
    {c // p c} ≃ {a // p (Sum.inl a)} ⊕ {b // p (Sum.inr b)} where
  toFun c := match h : c.1 with
    | Sum.inl a => Sum.inl ⟨a, h ▸ c.2⟩
    | Sum.inr b => Sum.inr ⟨b, h ▸ c.2⟩
  invFun c := match c with
    | Sum.inl a => ⟨Sum.inl a, a.2⟩
    | Sum.inr b => ⟨Sum.inr b, b.2⟩
  left_inv := by rintro ⟨a | b, h⟩ <;> rfl
  right_inv := by rintro (a | b) <;> rfl

namespace Perm

/-- Combine a permutation of `α` and of `β` into a permutation of `α ⊕ β`. -/
abbrev sumCongr {α β} (ea : Equiv.Perm α) (eb : Equiv.Perm β) : Equiv.Perm (α ⊕ β) :=
  Equiv.sumCongr ea eb

@[simp]
theorem sumCongr_apply {α β} (ea : Equiv.Perm α) (eb : Equiv.Perm β) (x : α ⊕ β) :
    sumCongr ea eb x = Sum.map (⇑ea) (⇑eb) x :=
  Equiv.sumCongr_apply ea eb x

-- Porting note: it seems the general theorem about `Equiv` is now applied, so there's no need
-- to have this version also have `@[simp]`. Similarly for below.
theorem sumCongr_trans {α β} (e : Equiv.Perm α) (f : Equiv.Perm β) (g : Equiv.Perm α)
    (h : Equiv.Perm β) : (sumCongr e f).trans (sumCongr g h) = sumCongr (e.trans g) (f.trans h) :=
  Equiv.sumCongr_trans e f g h

theorem sumCongr_symm {α β} (e : Equiv.Perm α) (f : Equiv.Perm β) :
    (sumCongr e f).symm = sumCongr e.symm f.symm :=
  Equiv.sumCongr_symm e f

theorem sumCongr_refl {α β} : sumCongr (Equiv.refl α) (Equiv.refl β) = Equiv.refl (α ⊕ β) :=
  Equiv.sumCongr_refl

end Perm

/-- `Bool` is equivalent the sum of two `PUnit`s. -/
def boolEquivPUnitSumPUnit : Bool ≃ PUnit.{u + 1} ⊕ PUnit.{v + 1} :=
  ⟨fun b => b.casesOn (inl PUnit.unit) (inr PUnit.unit) , Sum.elim (fun _ => false) fun _ => true,
    fun b => by cases b <;> rfl, fun s => by rcases s with (⟨⟨⟩⟩ | ⟨⟨⟩⟩) <;> rfl⟩

/-- Sum of types is commutative up to an equivalence. This is `Sum.swap` as an equivalence. -/
@[simps (config := .asFn) apply]
def sumComm (α β) : α ⊕ β ≃ β ⊕ α :=
  ⟨Sum.swap, Sum.swap, Sum.swap_swap, Sum.swap_swap⟩

@[simp]
theorem sumComm_symm (α β) : (sumComm α β).symm = sumComm β α :=
  rfl

/-- Sum of types is associative up to an equivalence. -/
def sumAssoc (α β γ) : (α ⊕ β) ⊕ γ ≃ α ⊕ (β ⊕ γ) :=
  ⟨Sum.elim (Sum.elim Sum.inl (Sum.inr ∘ Sum.inl)) (Sum.inr ∘ Sum.inr),
    Sum.elim (Sum.inl ∘ Sum.inl) <| Sum.elim (Sum.inl ∘ Sum.inr) Sum.inr,
      by rintro (⟨_ | _⟩ | _) <;> rfl, by
    rintro (_ | ⟨_ | _⟩) <;> rfl⟩

@[simp]
theorem sumAssoc_apply_inl_inl {α β γ} (a) : sumAssoc α β γ (inl (inl a)) = inl a :=
  rfl

@[simp]
theorem sumAssoc_apply_inl_inr {α β γ} (b) : sumAssoc α β γ (inl (inr b)) = inr (inl b) :=
  rfl

@[simp]
theorem sumAssoc_apply_inr {α β γ} (c) : sumAssoc α β γ (inr c) = inr (inr c) :=
  rfl

@[simp]
theorem sumAssoc_symm_apply_inl {α β γ} (a) : (sumAssoc α β γ).symm (inl a) = inl (inl a) :=
  rfl

@[simp]
theorem sumAssoc_symm_apply_inr_inl {α β γ} (b) :
    (sumAssoc α β γ).symm (inr (inl b)) = inl (inr b) :=
  rfl

@[simp]
theorem sumAssoc_symm_apply_inr_inr {α β γ} (c) : (sumAssoc α β γ).symm (inr (inr c)) = inr c :=
  rfl

/-- Four-way commutativity of `sum`. The name matches `add_add_add_comm`. -/
@[simps apply]
def sumSumSumComm (α β γ δ) : (α ⊕ β) ⊕ γ ⊕ δ ≃ (α ⊕ γ) ⊕ β ⊕ δ where
  toFun :=
    (sumAssoc (α ⊕ γ) β δ) ∘ (Sum.map (sumAssoc α γ β).symm (@id δ))
      ∘ (Sum.map (Sum.map (@id α) (sumComm β γ)) (@id δ))
      ∘ (Sum.map (sumAssoc α β γ) (@id δ))
      ∘ (sumAssoc (α ⊕ β) γ δ).symm
  invFun :=
    (sumAssoc (α ⊕ β) γ δ) ∘ (Sum.map (sumAssoc α β γ).symm (@id δ))
      ∘ (Sum.map (Sum.map (@id α) (sumComm β γ).symm) (@id δ))
      ∘ (Sum.map (sumAssoc α γ β) (@id δ))
      ∘ (sumAssoc (α ⊕ γ) β δ).symm
  left_inv x := by rcases x with ((a | b) | (c | d)) <;> simp
  right_inv x := by rcases x with ((a | c) | (b | d)) <;> simp

@[simp]
theorem sumSumSumComm_symm (α β γ δ) : (sumSumSumComm α β γ δ).symm = sumSumSumComm α γ β δ :=
  rfl

/-- Sum with `IsEmpty` is equivalent to the original type. -/
@[simps symm_apply]
def sumEmpty (α β) [IsEmpty β] : α ⊕ β ≃ α where
  toFun := Sum.elim id isEmptyElim
  invFun := inl
  left_inv s := by
    rcases s with (_ | x)
    · rfl
    · exact isEmptyElim x
  right_inv _ := rfl

@[simp]
theorem sumEmpty_apply_inl {α β} [IsEmpty β] (a : α) : sumEmpty α β (Sum.inl a) = a :=
  rfl

/-- The sum of `IsEmpty` with any type is equivalent to that type. -/
@[simps! symm_apply]
def emptySum (α β) [IsEmpty α] : α ⊕ β ≃ β :=
  (sumComm _ _).trans <| sumEmpty _ _

@[simp]
theorem emptySum_apply_inr {α β} [IsEmpty α] (b : β) : emptySum α β (Sum.inr b) = b :=
  rfl

/-- `Option α` is equivalent to `α ⊕ PUnit` -/
def optionEquivSumPUnit (α) : Option α ≃ α ⊕ PUnit :=
  ⟨fun o => o.elim (inr PUnit.unit) inl, fun s => s.elim some fun _ => none,
    fun o => by cases o <;> rfl,
    fun s => by rcases s with (_ | ⟨⟨⟩⟩) <;> rfl⟩

@[simp]
theorem optionEquivSumPUnit_none {α} : optionEquivSumPUnit α none = Sum.inr PUnit.unit :=
  rfl

@[simp]
theorem optionEquivSumPUnit_some {α} (a) : optionEquivSumPUnit α (some a) = Sum.inl a :=
  rfl

@[simp]
theorem optionEquivSumPUnit_coe {α} (a : α) : optionEquivSumPUnit α a = Sum.inl a :=
  rfl

@[simp]
theorem optionEquivSumPUnit_symm_inl {α} (a) : (optionEquivSumPUnit α).symm (Sum.inl a) = a :=
  rfl

@[simp]
theorem optionEquivSumPUnit_symm_inr {α} (a) : (optionEquivSumPUnit α).symm (Sum.inr a) = none :=
  rfl

/-- The set of `x : Option α` such that `isSome x` is equivalent to `α`. -/
@[simps]
def optionIsSomeEquiv (α) : { x : Option α // x.isSome } ≃ α where
  toFun o := Option.get _ o.2
  invFun x := ⟨some x, rfl⟩
  left_inv _ := Subtype.eq <| Option.some_get _
  right_inv _ := Option.get_some _ _

/-- The product over `Option α` of `β a` is the binary product of the
product over `α` of `β (some α)` and `β none` -/
@[simps]
def piOptionEquivProd {α} {β : Option α → Type*} :
    (∀ a : Option α, β a) ≃ β none × ∀ a : α, β (some a) where
  toFun f := (f none, fun a => f (some a))
  invFun x a := Option.casesOn a x.fst x.snd
  left_inv f := funext fun a => by cases a <;> rfl
  right_inv x := by simp

/-- `α ⊕ β` is equivalent to a `Sigma`-type over `Bool`. Note that this definition assumes `α` and
`β` to be types from the same universe, so it cannot be used directly to transfer theorems about
sigma types to theorems about sum types. In many cases one can use `ULift` to work around this
difficulty. -/
def sumEquivSigmaBool (α β) : α ⊕ β ≃ Σ b : Bool, b.casesOn α β :=
  ⟨fun s => s.elim (fun x => ⟨false, x⟩) fun x => ⟨true, x⟩, fun s =>
    match s with
    | ⟨false, a⟩ => inl a
    | ⟨true, b⟩ => inr b,
    fun s => by cases s <;> rfl, fun s => by rcases s with ⟨_ | _, _⟩ <;> rfl⟩

-- See also `Equiv.sigmaPreimageEquiv`.
/-- `sigmaFiberEquiv f` for `f : α → β` is the natural equivalence between
the type of all fibres of `f` and the total space `α`. -/
@[simps]
def sigmaFiberEquiv {α β : Type*} (f : α → β) : (Σ y : β, { x // f x = y }) ≃ α :=
  ⟨fun x => ↑x.2, fun x => ⟨f x, x, rfl⟩, fun ⟨_, _, rfl⟩ => rfl, fun _ => rfl⟩

/-- Inhabited types are equivalent to `Option β` for some `β` by identifying `default` with `none`.
-/
def sigmaEquivOptionOfInhabited (α : Type u) [Inhabited α] [DecidableEq α] :
    Σ β : Type u, α ≃ Option β where
  fst := {a // a ≠ default}
  snd.toFun a := if h : a = default then none else some ⟨a, h⟩
  snd.invFun := Option.elim' default (↑)
  snd.left_inv a := by dsimp only; split_ifs <;> simp [*]
  snd.right_inv
    | none => by simp
    | some ⟨_, ha⟩ => dif_neg ha

end

section sumCompl

/-- For any predicate `p` on `α`,
the sum of the two subtypes `{a // p a}` and its complement `{a // ¬ p a}`
is naturally equivalent to `α`.

See `subtypeOrEquiv` for sum types over subtypes `{x // p x}` and `{x // q x}`
that are not necessarily `IsCompl p q`. -/
def sumCompl {α : Type*} (p : α → Prop) [DecidablePred p] :
    { a // p a } ⊕ { a // ¬p a } ≃ α where
  toFun := Sum.elim Subtype.val Subtype.val
  invFun a := if h : p a then Sum.inl ⟨a, h⟩ else Sum.inr ⟨a, h⟩
  left_inv := by
    rintro (⟨x, hx⟩ | ⟨x, hx⟩) <;> dsimp
    · rw [dif_pos]
    · rw [dif_neg]
  right_inv a := by
    dsimp
    split_ifs <;> rfl

@[simp]
theorem sumCompl_apply_inl {α} (p : α → Prop) [DecidablePred p] (x : { a // p a }) :
    sumCompl p (Sum.inl x) = x :=
  rfl

@[simp]
theorem sumCompl_apply_inr {α} (p : α → Prop) [DecidablePred p] (x : { a // ¬p a }) :
    sumCompl p (Sum.inr x) = x :=
  rfl

@[simp]
theorem sumCompl_apply_symm_of_pos {α} (p : α → Prop) [DecidablePred p] (a : α) (h : p a) :
    (sumCompl p).symm a = Sum.inl ⟨a, h⟩ :=
  dif_pos h

@[simp]
theorem sumCompl_apply_symm_of_neg {α} (p : α → Prop) [DecidablePred p] (a : α) (h : ¬p a) :
    (sumCompl p).symm a = Sum.inr ⟨a, h⟩ :=
  dif_neg h

/-- Combines an `Equiv` between two subtypes with an `Equiv` between their complements to form a
  permutation. -/
def subtypeCongr {α} {p q : α → Prop} [DecidablePred p] [DecidablePred q]
    (e : { x // p x } ≃ { x // q x }) (f : { x // ¬p x } ≃ { x // ¬q x }) : Perm α :=
  (sumCompl p).symm.trans ((sumCongr e f).trans (sumCompl q))

variable {ε : Type*} {p : ε → Prop} [DecidablePred p]
variable (ep ep' : Perm { a // p a }) (en en' : Perm { a // ¬p a })

/-- Combining permutations on `ε` that permute only inside or outside the subtype
split induced by `p : ε → Prop` constructs a permutation on `ε`. -/
def Perm.subtypeCongr : Equiv.Perm ε :=
  permCongr (sumCompl p) (sumCongr ep en)

theorem Perm.subtypeCongr.apply (a : ε) : ep.subtypeCongr en a =
    if h : p a then (ep ⟨a, h⟩ : ε) else en ⟨a, h⟩ := by
  by_cases h : p a <;> simp [Perm.subtypeCongr, h]

@[simp]
theorem Perm.subtypeCongr.left_apply {a : ε} (h : p a) : ep.subtypeCongr en a = ep ⟨a, h⟩ := by
  simp [Perm.subtypeCongr.apply, h]

@[simp]
theorem Perm.subtypeCongr.left_apply_subtype (a : { a // p a }) : ep.subtypeCongr en a = ep a :=
    Perm.subtypeCongr.left_apply ep en a.property

@[simp]
theorem Perm.subtypeCongr.right_apply {a : ε} (h : ¬p a) : ep.subtypeCongr en a = en ⟨a, h⟩ := by
  simp [Perm.subtypeCongr.apply, h]

@[simp]
theorem Perm.subtypeCongr.right_apply_subtype (a : { a // ¬p a }) : ep.subtypeCongr en a = en a :=
  Perm.subtypeCongr.right_apply ep en a.property

@[simp]
theorem Perm.subtypeCongr.refl :
    Perm.subtypeCongr (Equiv.refl { a // p a }) (Equiv.refl { a // ¬p a }) = Equiv.refl ε := by
  ext x
  by_cases h : p x <;> simp [h]

@[simp]
theorem Perm.subtypeCongr.symm : (ep.subtypeCongr en).symm = Perm.subtypeCongr ep.symm en.symm := by
  ext x
  by_cases h : p x
  · have : p (ep.symm ⟨x, h⟩) := Subtype.property _
    simp [Perm.subtypeCongr.apply, h, symm_apply_eq, this]
  · have : ¬p (en.symm ⟨x, h⟩) := Subtype.property (en.symm _)
    simp [Perm.subtypeCongr.apply, h, symm_apply_eq, this]

@[simp]
theorem Perm.subtypeCongr.trans :
    (ep.subtypeCongr en).trans (ep'.subtypeCongr en')
    = Perm.subtypeCongr (ep.trans ep') (en.trans en') := by
  ext x
  by_cases h : p x
  · have : p (ep ⟨x, h⟩) := Subtype.property _
    simp [Perm.subtypeCongr.apply, h, this]
  · have : ¬p (en ⟨x, h⟩) := Subtype.property (en _)
    simp [Perm.subtypeCongr.apply, h, symm_apply_eq, this]

end sumCompl

section subtypePreimage

variable (p : α → Prop) [DecidablePred p] (x₀ : { a // p a } → β)

/-- For a fixed function `x₀ : {a // p a} → β` defined on a subtype of `α`,
the subtype of functions `x : α → β` that agree with `x₀` on the subtype `{a // p a}`
is naturally equivalent to the type of functions `{a // ¬ p a} → β`. -/
@[simps]
def subtypePreimage : { x : α → β // x ∘ Subtype.val = x₀ } ≃ ({ a // ¬p a } → β) where
  toFun (x : { x : α → β // x ∘ Subtype.val = x₀ }) a := (x : α → β) a
  invFun x := ⟨fun a => if h : p a then x₀ ⟨a, h⟩ else x ⟨a, h⟩, funext fun ⟨_, h⟩ => dif_pos h⟩
  left_inv := fun ⟨x, hx⟩ =>
    Subtype.val_injective <|
      funext fun a => by
        dsimp only
        split_ifs
        · rw [← hx]; rfl
        · rfl
  right_inv x :=
    funext fun ⟨a, h⟩ =>
      show dite (p a) _ _ = _ by
        dsimp only
        rw [dif_neg h]

theorem subtypePreimage_symm_apply_coe_pos (x : { a // ¬p a } → β) (a : α) (h : p a) :
    ((subtypePreimage p x₀).symm x : α → β) a = x₀ ⟨a, h⟩ :=
  dif_pos h

theorem subtypePreimage_symm_apply_coe_neg (x : { a // ¬p a } → β) (a : α) (h : ¬p a) :
    ((subtypePreimage p x₀).symm x : α → β) a = x ⟨a, h⟩ :=
  dif_neg h

end subtypePreimage

section

/-- A family of equivalences `∀ a, β₁ a ≃ β₂ a` generates an equivalence between `∀ a, β₁ a` and
`∀ a, β₂ a`. -/
def piCongrRight {β₁ β₂ : α → Sort*} (F : ∀ a, β₁ a ≃ β₂ a) : (∀ a, β₁ a) ≃ (∀ a, β₂ a) :=
  ⟨Pi.map fun a ↦ F a, Pi.map fun a ↦ (F a).symm, fun H => funext <| by simp,
    fun H => funext <| by simp⟩

/-- Given `φ : α → β → Sort*`, we have an equivalence between `∀ a b, φ a b` and `∀ b a, φ a b`.
This is `Function.swap` as an `Equiv`. -/
@[simps apply]
def piComm (φ : α → β → Sort*) : (∀ a b, φ a b) ≃ ∀ b a, φ a b :=
  ⟨swap, swap, fun _ => rfl, fun _ => rfl⟩

@[simp]
theorem piComm_symm {φ : α → β → Sort*} : (piComm φ).symm = (piComm <| swap φ) :=
  rfl

/-- Dependent `curry` equivalence: the type of dependent functions on `Σ i, β i` is equivalent
to the type of dependent functions of two arguments (i.e., functions to the space of functions).

This is `Sigma.curry` and `Sigma.uncurry` together as an equiv. -/
def piCurry {α} {β : α → Type*} (γ : ∀ a, β a → Type*) :
    (∀ x : Σ i, β i, γ x.1 x.2) ≃ ∀ a b, γ a b where
  toFun := Sigma.curry
  invFun := Sigma.uncurry
  left_inv := Sigma.uncurry_curry
  right_inv := Sigma.curry_uncurry

-- `simps` overapplies these but `simps (config := .asFn)` under-applies them
@[simp] theorem piCurry_apply {α} {β : α → Type*} (γ : ∀ a, β a → Type*)
    (f : ∀ x : Σ i, β i, γ x.1 x.2) :
    piCurry γ f = Sigma.curry f :=
  rfl

@[simp] theorem piCurry_symm_apply {α} {β : α → Type*} (γ : ∀ a, β a → Type*) (f : ∀ a b, γ a b) :
    (piCurry γ).symm f = Sigma.uncurry f :=
  rfl

end

section prodCongr

variable {α₁ α₂ β₁ β₂ : Type*} (e : α₁ → β₁ ≃ β₂)

/-- A family of equivalences `∀ (a : α₁), β₁ ≃ β₂` generates an equivalence
between `β₁ × α₁` and `β₂ × α₁`. -/
def prodCongrLeft : β₁ × α₁ ≃ β₂ × α₁ where
  toFun ab := ⟨e ab.2 ab.1, ab.2⟩
  invFun ab := ⟨(e ab.2).symm ab.1, ab.2⟩
  left_inv := by
    rintro ⟨a, b⟩
    simp
  right_inv := by
    rintro ⟨a, b⟩
    simp

@[simp]
theorem prodCongrLeft_apply (b : β₁) (a : α₁) : prodCongrLeft e (b, a) = (e a b, a) :=
  rfl

theorem prodCongr_refl_right (e : β₁ ≃ β₂) :
    prodCongr e (Equiv.refl α₁) = prodCongrLeft fun _ => e := by
  ext ⟨a, b⟩ : 1
  simp

/-- A family of equivalences `∀ (a : α₁), β₁ ≃ β₂` generates an equivalence
between `α₁ × β₁` and `α₁ × β₂`. -/
def prodCongrRight : α₁ × β₁ ≃ α₁ × β₂ where
  toFun ab := ⟨ab.1, e ab.1 ab.2⟩
  invFun ab := ⟨ab.1, (e ab.1).symm ab.2⟩
  left_inv := by
    rintro ⟨a, b⟩
    simp
  right_inv := by
    rintro ⟨a, b⟩
    simp

@[simp]
theorem prodCongrRight_apply (a : α₁) (b : β₁) : prodCongrRight e (a, b) = (a, e a b) :=
  rfl

theorem prodCongr_refl_left (e : β₁ ≃ β₂) :
    prodCongr (Equiv.refl α₁) e = prodCongrRight fun _ => e := by
  ext ⟨a, b⟩ : 1
  simp

@[simp]
theorem prodCongrLeft_trans_prodComm :
    (prodCongrLeft e).trans (prodComm _ _) = (prodComm _ _).trans (prodCongrRight e) := by
  ext ⟨a, b⟩ : 1
  simp

@[simp]
theorem prodCongrRight_trans_prodComm :
    (prodCongrRight e).trans (prodComm _ _) = (prodComm _ _).trans (prodCongrLeft e) := by
  ext ⟨a, b⟩ : 1
  simp

theorem sigmaCongrRight_sigmaEquivProd :
    (sigmaCongrRight e).trans (sigmaEquivProd α₁ β₂)
    = (sigmaEquivProd α₁ β₁).trans (prodCongrRight e) := by
  ext ⟨a, b⟩ : 1
  simp

theorem sigmaEquivProd_sigmaCongrRight :
    (sigmaEquivProd α₁ β₁).symm.trans (sigmaCongrRight e)
    = (prodCongrRight e).trans (sigmaEquivProd α₁ β₂).symm := by
  ext ⟨a, b⟩ : 1
  simp only [trans_apply, sigmaCongrRight_apply, prodCongrRight_apply]
  rfl

-- See also `Equiv.ofPreimageEquiv`.
/-- A family of equivalences between fibers gives an equivalence between domains. -/
@[simps!]
def ofFiberEquiv {α β γ} {f : α → γ} {g : β → γ}
    (e : ∀ c, { a // f a = c } ≃ { b // g b = c }) : α ≃ β :=
  (sigmaFiberEquiv f).symm.trans <| (Equiv.sigmaCongrRight e).trans (sigmaFiberEquiv g)

theorem ofFiberEquiv_map {α β γ} {f : α → γ} {g : β → γ}
    (e : ∀ c, { a // f a = c } ≃ { b // g b = c }) (a : α) : g (ofFiberEquiv e a) = f a :=
  (_ : { b // g b = _ }).property

/-- A variation on `Equiv.prodCongr` where the equivalence in the second component can depend
  on the first component. A typical example is a shear mapping, explaining the name of this
  declaration. -/
@[simps (config := .asFn)]
def prodShear (e₁ : α₁ ≃ α₂) (e₂ : α₁ → β₁ ≃ β₂) : α₁ × β₁ ≃ α₂ × β₂ where
  toFun := fun x : α₁ × β₁ => (e₁ x.1, e₂ x.1 x.2)
  invFun := fun y : α₂ × β₂ => (e₁.symm y.1, (e₂ <| e₁.symm y.1).symm y.2)
  left_inv := by
    rintro ⟨x₁, y₁⟩
    simp only [symm_apply_apply]
  right_inv := by
    rintro ⟨x₁, y₁⟩
    simp only [apply_symm_apply]

end prodCongr

namespace Perm

variable {α₁ β₁ : Type*} [DecidableEq α₁] (a : α₁) (e : Perm β₁)

/-- `prodExtendRight a e` extends `e : Perm β` to `Perm (α × β)` by sending `(a, b)` to
`(a, e b)` and keeping the other `(a', b)` fixed. -/
def prodExtendRight : Perm (α₁ × β₁) where
  toFun ab := if ab.fst = a then (a, e ab.snd) else ab
  invFun ab := if ab.fst = a then (a, e.symm ab.snd) else ab
  left_inv := by
    rintro ⟨k', x⟩
    dsimp only
    split_ifs with h₁ h₂
    · simp [h₁]
    · simp at h₂
    · simp
  right_inv := by
    rintro ⟨k', x⟩
    dsimp only
    split_ifs with h₁ h₂
    · simp [h₁]
    · simp at h₂
    · simp

@[simp]
theorem prodExtendRight_apply_eq (b : β₁) : prodExtendRight a e (a, b) = (a, e b) :=
  if_pos rfl

theorem prodExtendRight_apply_ne {a a' : α₁} (h : a' ≠ a) (b : β₁) :
    prodExtendRight a e (a', b) = (a', b) :=
  if_neg h

theorem eq_of_prodExtendRight_ne {e : Perm β₁} {a a' : α₁} {b : β₁}
    (h : prodExtendRight a e (a', b) ≠ (a', b)) : a' = a := by
  contrapose! h
  exact prodExtendRight_apply_ne _ h _

@[simp]
theorem fst_prodExtendRight (ab : α₁ × β₁) : (prodExtendRight a e ab).fst = ab.fst := by
  rw [prodExtendRight]
  dsimp
  split_ifs with h
  · rw [h]
  · rfl

end Perm

section

/-- The type of functions to a product `α × β` is equivalent to the type of pairs of functions
`γ → α` and `γ → β`. -/
def arrowProdEquivProdArrow (α β γ : Type*) : (γ → α × β) ≃ (γ → α) × (γ → β) where
  toFun := fun f => (fun c => (f c).1, fun c => (f c).2)
  invFun := fun p c => (p.1 c, p.2 c)
  left_inv := fun _ => rfl
  right_inv := fun p => by cases p; rfl

open Sum

/-- The type of dependent functions on a sum type `ι ⊕ ι'` is equivalent to the type of pairs of
functions on `ι` and on `ι'`. This is a dependent version of `Equiv.sumArrowEquivProdArrow`. -/
@[simps]
def sumPiEquivProdPi {ι ι'} (π : ι ⊕ ι' → Type*) :
    (∀ i, π i) ≃ (∀ i, π (inl i)) × ∀ i', π (inr i') where
  toFun f := ⟨fun i => f (inl i), fun i' => f (inr i')⟩
  invFun g := Sum.rec g.1 g.2
  left_inv f := by ext (i | i) <;> rfl
  right_inv _ := Prod.ext rfl rfl

/-- The equivalence between a product of two dependent functions types and a single dependent
function type. Basically a symmetric version of `Equiv.sumPiEquivProdPi`. -/
@[simps!]
def prodPiEquivSumPi {ι ι'} (π : ι → Type u) (π' : ι' → Type u) :
    ((∀ i, π i) × ∀ i', π' i') ≃ ∀ i, Sum.elim π π' i :=
  sumPiEquivProdPi (Sum.elim π π') |>.symm

/-- The type of functions on a sum type `α ⊕ β` is equivalent to the type of pairs of functions
on `α` and on `β`. -/
def sumArrowEquivProdArrow (α β γ : Type*) : (α ⊕ β → γ) ≃ (α → γ) × (β → γ) :=
  ⟨fun f => (f ∘ inl, f ∘ inr), fun p => Sum.elim p.1 p.2, fun f => by ext ⟨⟩ <;> rfl, fun p => by
    cases p
    rfl⟩

@[simp]
theorem sumArrowEquivProdArrow_apply_fst {α β γ} (f : α ⊕ β → γ) (a : α) :
    (sumArrowEquivProdArrow α β γ f).1 a = f (inl a) :=
  rfl

@[simp]
theorem sumArrowEquivProdArrow_apply_snd {α β γ} (f : α ⊕ β → γ) (b : β) :
    (sumArrowEquivProdArrow α β γ f).2 b = f (inr b) :=
  rfl

@[simp]
theorem sumArrowEquivProdArrow_symm_apply_inl {α β γ} (f : α → γ) (g : β → γ) (a : α) :
    ((sumArrowEquivProdArrow α β γ).symm (f, g)) (inl a) = f a :=
  rfl

@[simp]
theorem sumArrowEquivProdArrow_symm_apply_inr {α β γ} (f : α → γ) (g : β → γ) (b : β) :
    ((sumArrowEquivProdArrow α β γ).symm (f, g)) (inr b) = g b :=
  rfl

/-- Type product is right distributive with respect to type sum up to an equivalence. -/
def sumProdDistrib (α β γ) : (α ⊕ β) × γ ≃ α × γ ⊕ β × γ :=
  ⟨fun p => p.1.map (fun x => (x, p.2)) fun x => (x, p.2),
    fun s => s.elim (Prod.map inl id) (Prod.map inr id), by
      rintro ⟨_ | _, _⟩ <;> rfl, by rintro (⟨_, _⟩ | ⟨_, _⟩) <;> rfl⟩

@[simp]
theorem sumProdDistrib_apply_left {α β γ} (a : α) (c : γ) :
    sumProdDistrib α β γ (Sum.inl a, c) = Sum.inl (a, c) :=
  rfl

@[simp]
theorem sumProdDistrib_apply_right {α β γ} (b : β) (c : γ) :
    sumProdDistrib α β γ (Sum.inr b, c) = Sum.inr (b, c) :=
  rfl

@[simp]
theorem sumProdDistrib_symm_apply_left {α β γ} (a : α × γ) :
    (sumProdDistrib α β γ).symm (inl a) = (inl a.1, a.2) :=
  rfl

@[simp]
theorem sumProdDistrib_symm_apply_right {α β γ} (b : β × γ) :
    (sumProdDistrib α β γ).symm (inr b) = (inr b.1, b.2) :=
  rfl

/-- Type product is left distributive with respect to type sum up to an equivalence. -/
def prodSumDistrib (α β γ) : α × (β ⊕ γ) ≃ (α × β) ⊕ (α × γ) :=
  calc
    α × (β ⊕ γ) ≃ (β ⊕ γ) × α := prodComm _ _
    _ ≃ (β × α) ⊕ (γ × α) := sumProdDistrib _ _ _
    _ ≃ (α × β) ⊕ (α × γ) := sumCongr (prodComm _ _) (prodComm _ _)

@[simp]
theorem prodSumDistrib_apply_left {α β γ} (a : α) (b : β) :
    prodSumDistrib α β γ (a, Sum.inl b) = Sum.inl (a, b) :=
  rfl

@[simp]
theorem prodSumDistrib_apply_right {α β γ} (a : α) (c : γ) :
    prodSumDistrib α β γ (a, Sum.inr c) = Sum.inr (a, c) :=
  rfl

@[simp]
theorem prodSumDistrib_symm_apply_left {α β γ} (a : α × β) :
    (prodSumDistrib α β γ).symm (inl a) = (a.1, inl a.2) :=
  rfl

@[simp]
theorem prodSumDistrib_symm_apply_right {α β γ} (a : α × γ) :
    (prodSumDistrib α β γ).symm (inr a) = (a.1, inr a.2) :=
  rfl

/-- An indexed sum of disjoint sums of types is equivalent to the sum of the indexed sums. -/
@[simps]
def sigmaSumDistrib {ι} (α β : ι → Type*) :
    (Σ i, α i ⊕ β i) ≃ (Σ i, α i) ⊕ (Σ i, β i) :=
  ⟨fun p => p.2.map (Sigma.mk p.1) (Sigma.mk p.1),
    Sum.elim (Sigma.map id fun _ => Sum.inl) (Sigma.map id fun _ => Sum.inr), fun p => by
    rcases p with ⟨i, a | b⟩ <;> rfl, fun p => by rcases p with (⟨i, a⟩ | ⟨i, b⟩) <;> rfl⟩

/-- The product of an indexed sum of types (formally, a `Sigma`-type `Σ i, α i`) by a type `β` is
equivalent to the sum of products `Σ i, (α i × β)`. -/
@[simps apply symm_apply]
def sigmaProdDistrib {ι} (α : ι → Type*) (β) : (Σ i, α i) × β ≃ Σ i, α i × β :=
  ⟨fun p => ⟨p.1.1, (p.1.2, p.2)⟩, fun p => (⟨p.1, p.2.1⟩, p.2.2), fun p => by
    rcases p with ⟨⟨_, _⟩, _⟩
    rfl, fun p => by
    rcases p with ⟨_, ⟨_, _⟩⟩
    rfl⟩

/-- An equivalence that separates out the 0th fiber of `(Σ (n : ℕ), f n)`. -/
def sigmaNatSucc (f : ℕ → Type u) : (Σ n, f n) ≃ f 0 ⊕ Σ n, f (n + 1) :=
  ⟨fun x =>
    @Sigma.casesOn ℕ f (fun _ => f 0 ⊕ Σ n, f (n + 1)) x fun n =>
      @Nat.casesOn (fun i => f i → f 0 ⊕ Σ n : ℕ, f (n + 1)) n (fun x : f 0 => Sum.inl x)
        fun (n : ℕ) (x : f n.succ) => Sum.inr ⟨n, x⟩,
    Sum.elim (Sigma.mk 0) (Sigma.map Nat.succ fun _ => id), by rintro ⟨n | n, x⟩ <;> rfl, by
    rintro (x | ⟨n, x⟩) <;> rfl⟩

/-- The product `Bool × α` is equivalent to `α ⊕ α`. -/
@[simps]
def boolProdEquivSum (α) : Bool × α ≃ α ⊕ α where
  toFun p := p.1.casesOn (inl p.2) (inr p.2)
  invFun := Sum.elim (Prod.mk false) (Prod.mk true)
  left_inv := by rintro ⟨_ | _, _⟩ <;> rfl
  right_inv := by rintro (_ | _) <;> rfl

/-- The function type `Bool → α` is equivalent to `α × α`. -/
@[simps]
def boolArrowEquivProd (α) : (Bool → α) ≃ α × α where
  toFun f := (f false, f true)
  invFun p b := b.casesOn p.1 p.2
  left_inv _ := funext <| Bool.forall_bool.2 ⟨rfl, rfl⟩
  right_inv := fun _ => rfl

end

section

open Sum Nat

/-- The set of natural numbers is equivalent to `ℕ ⊕ PUnit`. -/
def natEquivNatSumPUnit : ℕ ≃ ℕ ⊕ PUnit where
  toFun n := Nat.casesOn n (inr PUnit.unit) inl
  invFun := Sum.elim Nat.succ fun _ => 0
  left_inv n := by cases n <;> rfl
  right_inv := by rintro (_ | _) <;> rfl

/-- `ℕ ⊕ PUnit` is equivalent to `ℕ`. -/
def natSumPUnitEquivNat : ℕ ⊕ PUnit ≃ ℕ :=
  natEquivNatSumPUnit.symm

/-- The type of integer numbers is equivalent to `ℕ ⊕ ℕ`. -/
def intEquivNatSumNat : ℤ ≃ ℕ ⊕ ℕ where
  toFun z := Int.casesOn z inl inr
  invFun := Sum.elim Int.ofNat Int.negSucc
  left_inv := by rintro (m | n) <;> rfl
  right_inv := by rintro (m | n) <;> rfl

end

/-- An equivalence between `α` and `β` generates an equivalence between `List α` and `List β`. -/
def listEquivOfEquiv {α β} (e : α ≃ β) : List α ≃ List β where
  toFun := List.map e
  invFun := List.map e.symm
  left_inv l := by rw [List.map_map, e.symm_comp_self, List.map_id]
  right_inv l := by rw [List.map_map, e.self_comp_symm, List.map_id]

/-- If `α` is equivalent to `β`, then `Unique α` is equivalent to `Unique β`. -/
def uniqueCongr (e : α ≃ β) : Unique α ≃ Unique β where
  toFun h := @Equiv.unique _ _ h e.symm
  invFun h := @Equiv.unique _ _ h e
  left_inv _ := Subsingleton.elim _ _
  right_inv _ := Subsingleton.elim _ _

/-- If `α` is equivalent to `β`, then `IsEmpty α` is equivalent to `IsEmpty β`. -/
theorem isEmpty_congr (e : α ≃ β) : IsEmpty α ↔ IsEmpty β :=
  ⟨fun h => @Function.isEmpty _ _ h e.symm, fun h => @Function.isEmpty _ _ h e⟩

protected theorem isEmpty (e : α ≃ β) [IsEmpty β] : IsEmpty α :=
  e.isEmpty_congr.mpr ‹_›

section

open Subtype

/-- If `α` is equivalent to `β` and the predicates `p : α → Prop` and `q : β → Prop` are equivalent
at corresponding points, then `{a // p a}` is equivalent to `{b // q b}`.
For the statement where `α = β`, that is, `e : perm α`, see `Perm.subtypePerm`. -/
def subtypeEquiv {p : α → Prop} {q : β → Prop} (e : α ≃ β) (h : ∀ a, p a ↔ q (e a)) :
    { a : α // p a } ≃ { b : β // q b } where
  toFun a := ⟨e a, (h _).mp a.property⟩
  invFun b := ⟨e.symm b, (h _).mpr ((e.apply_symm_apply b).symm ▸ b.property)⟩
  left_inv a := Subtype.ext <| by simp
  right_inv b := Subtype.ext <| by simp

lemma coe_subtypeEquiv_eq_map {X Y} {p : X → Prop} {q : Y → Prop} (e : X ≃ Y)
    (h : ∀ x, p x ↔ q (e x)) : ⇑(e.subtypeEquiv h) = Subtype.map e (h · |>.mp) :=
  rfl

@[simp]
theorem subtypeEquiv_refl {p : α → Prop} (h : ∀ a, p a ↔ p (Equiv.refl _ a) := fun _ => Iff.rfl) :
    (Equiv.refl α).subtypeEquiv h = Equiv.refl { a : α // p a } := by
  ext
  rfl

@[simp]
theorem subtypeEquiv_symm {p : α → Prop} {q : β → Prop} (e : α ≃ β) (h : ∀ a : α, p a ↔ q (e a)) :
    (e.subtypeEquiv h).symm =
      e.symm.subtypeEquiv fun a => by
        convert (h <| e.symm a).symm
        exact (e.apply_symm_apply a).symm :=
  rfl

@[simp]
theorem subtypeEquiv_trans {p : α → Prop} {q : β → Prop} {r : γ → Prop} (e : α ≃ β) (f : β ≃ γ)
    (h : ∀ a : α, p a ↔ q (e a)) (h' : ∀ b : β, q b ↔ r (f b)) :
    (e.subtypeEquiv h).trans (f.subtypeEquiv h')
    = (e.trans f).subtypeEquiv fun a => (h a).trans (h' <| e a) :=
  rfl

@[simp]
theorem subtypeEquiv_apply {p : α → Prop} {q : β → Prop}
    (e : α ≃ β) (h : ∀ a : α, p a ↔ q (e a)) (x : { x // p x }) :
    e.subtypeEquiv h x = ⟨e x, (h _).1 x.2⟩ :=
  rfl

/-- If two predicates `p` and `q` are pointwise equivalent, then `{x // p x}` is equivalent to
`{x // q x}`. -/
@[simps!]
def subtypeEquivRight {p q : α → Prop} (e : ∀ x, p x ↔ q x) : { x // p x } ≃ { x // q x } :=
  subtypeEquiv (Equiv.refl _) e

lemma subtypeEquivRight_apply {p q : α → Prop} (e : ∀ x, p x ↔ q x)
    (z : { x // p x }) : subtypeEquivRight e z = ⟨z, (e z.1).mp z.2⟩ := rfl

lemma subtypeEquivRight_symm_apply {p q : α → Prop} (e : ∀ x, p x ↔ q x)
    (z : { x // q x }) : (subtypeEquivRight e).symm z = ⟨z, (e z.1).mpr z.2⟩ := rfl

/-- If `α ≃ β`, then for any predicate `p : β → Prop` the subtype `{a // p (e a)}` is equivalent
to the subtype `{b // p b}`. -/
def subtypeEquivOfSubtype {p : β → Prop} (e : α ≃ β) : { a : α // p (e a) } ≃ { b : β // p b } :=
  subtypeEquiv e <| by simp

/-- If `α ≃ β`, then for any predicate `p : α → Prop` the subtype `{a // p a}` is equivalent
to the subtype `{b // p (e.symm b)}`. This version is used by `equiv_rw`. -/
def subtypeEquivOfSubtype' {p : α → Prop} (e : α ≃ β) :
    { a : α // p a } ≃ { b : β // p (e.symm b) } :=
  e.symm.subtypeEquivOfSubtype.symm

/-- If two predicates are equal, then the corresponding subtypes are equivalent. -/
def subtypeEquivProp {p q : α → Prop} (h : p = q) : Subtype p ≃ Subtype q :=
  subtypeEquiv (Equiv.refl α) fun _ => h ▸ Iff.rfl

/-- A subtype of a subtype is equivalent to the subtype of elements satisfying both predicates. This
version allows the “inner” predicate to depend on `h : p a`. -/
@[simps]
def subtypeSubtypeEquivSubtypeExists (p : α → Prop) (q : Subtype p → Prop) :
    Subtype q ≃ { a : α // ∃ h : p a, q ⟨a, h⟩ } :=
  ⟨fun a =>
    ⟨a.1, a.1.2, by
      rcases a with ⟨⟨a, hap⟩, haq⟩
      exact haq⟩,
    fun a => ⟨⟨a, a.2.fst⟩, a.2.snd⟩, fun ⟨⟨_, _⟩, _⟩ => rfl, fun ⟨_, _, _⟩ => rfl⟩

/-- A subtype of a subtype is equivalent to the subtype of elements satisfying both predicates. -/
@[simps!]
def subtypeSubtypeEquivSubtypeInter {α : Type u} (p q : α → Prop) :
    { x : Subtype p // q x.1 } ≃ Subtype fun x => p x ∧ q x :=
  (subtypeSubtypeEquivSubtypeExists p _).trans <|
    subtypeEquivRight fun x => @exists_prop (q x) (p x)

/-- If the outer subtype has more restrictive predicate than the inner one,
then we can drop the latter. -/
@[simps!]
def subtypeSubtypeEquivSubtype {α} {p q : α → Prop} (h : ∀ {x}, q x → p x) :
    { x : Subtype p // q x.1 } ≃ Subtype q :=
  (subtypeSubtypeEquivSubtypeInter p _).trans <| subtypeEquivRight fun _ => and_iff_right_of_imp h

/-- If a proposition holds for all elements, then the subtype is
equivalent to the original type. -/
@[simps apply symm_apply]
def subtypeUnivEquiv {α} {p : α → Prop} (h : ∀ x, p x) : Subtype p ≃ α :=
  ⟨fun x => x, fun x => ⟨x, h x⟩, fun _ => Subtype.eq rfl, fun _ => rfl⟩

/-- A subtype of a sigma-type is a sigma-type over a subtype. -/
def subtypeSigmaEquiv {α} (p : α → Type v) (q : α → Prop) : { y : Sigma p // q y.1 } ≃ Σ x :
    Subtype q, p x.1 :=
  ⟨fun x => ⟨⟨x.1.1, x.2⟩, x.1.2⟩, fun x => ⟨⟨x.1.1, x.2⟩, x.1.2⟩, fun _ => rfl,
    fun _ => rfl⟩

/-- A sigma type over a subtype is equivalent to the sigma set over the original type,
if the fiber is empty outside of the subset -/
def sigmaSubtypeEquivOfSubset {α} (p : α → Type v) (q : α → Prop) (h : ∀ x, p x → q x) :
    (Σ x : Subtype q, p x) ≃ Σ x : α, p x :=
  (subtypeSigmaEquiv p q).symm.trans <| subtypeUnivEquiv fun x => h x.1 x.2

/-- If a predicate `p : β → Prop` is true on the range of a map `f : α → β`, then
`Σ y : {y // p y}, {x // f x = y}` is equivalent to `α`. -/
def sigmaSubtypeFiberEquiv {α β : Type*} (f : α → β) (p : β → Prop) (h : ∀ x, p (f x)) :
    (Σ y : Subtype p, { x : α // f x = y }) ≃ α :=
  calc
    _ ≃ Σy : β, { x : α // f x = y } := sigmaSubtypeEquivOfSubset _ p fun _ ⟨x, h'⟩ => h' ▸ h x
    _ ≃ α := sigmaFiberEquiv f

/-- If for each `x` we have `p x ↔ q (f x)`, then `Σ y : {y // q y}, f ⁻¹' {y}` is equivalent
to `{x // p x}`. -/
def sigmaSubtypeFiberEquivSubtype {α β : Type*} (f : α → β) {p : α → Prop} {q : β → Prop}
    (h : ∀ x, p x ↔ q (f x)) : (Σ y : Subtype q, { x : α // f x = y }) ≃ Subtype p :=
  calc
    (Σy : Subtype q, { x : α // f x = y }) ≃ Σy :
        Subtype q, { x : Subtype p // Subtype.mk (f x) ((h x).1 x.2) = y } := by {
          apply sigmaCongrRight
          intro y
          apply Equiv.symm
          refine (subtypeSubtypeEquivSubtypeExists _ _).trans (subtypeEquivRight ?_)
          intro x
          exact ⟨fun ⟨hp, h'⟩ => congr_arg Subtype.val h', fun h' => ⟨(h x).2 (h'.symm ▸ y.2),
            Subtype.eq h'⟩⟩ }
    _ ≃ Subtype p := sigmaFiberEquiv fun x : Subtype p => (⟨f x, (h x).1 x.property⟩ : Subtype q)

/-- A sigma type over an `Option` is equivalent to the sigma set over the original type,
if the fiber is empty at none. -/
def sigmaOptionEquivOfSome {α} (p : Option α → Type v) (h : p none → False) :
    (Σ x : Option α, p x) ≃ Σ x : α, p (some x) :=
  haveI h' : ∀ x, p x → x.isSome := by
    intro x
    cases x
    · intro n
      exfalso
      exact h n
    · intro _
      exact rfl
  (sigmaSubtypeEquivOfSubset _ _ h').symm.trans (sigmaCongrLeft' (optionIsSomeEquiv α))

/-- The `Pi`-type `∀ i, π i` is equivalent to the type of sections `f : ι → Σ i, π i` of the
`Sigma` type such that for all `i` we have `(f i).fst = i`. -/
def piEquivSubtypeSigma (ι) (π : ι → Type*) :
    (∀ i, π i) ≃ { f : ι → Σ i, π i // ∀ i, (f i).1 = i } where
  toFun := fun f => ⟨fun i => ⟨i, f i⟩, fun _ => rfl⟩
  invFun := fun f i => by rw [← f.2 i]; exact (f.1 i).2
  left_inv := fun _ => funext fun _ => rfl
  right_inv := fun ⟨f, hf⟩ =>
    Subtype.eq <| funext fun i =>
      Sigma.eq (hf i).symm <| eq_of_heq <| rec_heq_of_heq _ <| by simp

/-- The type of functions `f : ∀ a, β a` such that for all `a` we have `p a (f a)` is equivalent
to the type of functions `∀ a, {b : β a // p a b}`. -/
def subtypePiEquivPi {β : α → Sort v} {p : ∀ a, β a → Prop} :
    { f : ∀ a, β a // ∀ a, p a (f a) } ≃ ∀ a, { b : β a // p a b } where
  toFun := fun f a => ⟨f.1 a, f.2 a⟩
  invFun := fun f => ⟨fun a => (f a).1, fun a => (f a).2⟩
  left_inv := by
    rintro ⟨f, h⟩
    rfl
  right_inv := by
    rintro f
    funext a
    exact Subtype.ext_val rfl

/-- A subtype of a product defined by componentwise conditions
is equivalent to a product of subtypes. -/
def subtypeProdEquivProd {α β} {p : α → Prop} {q : β → Prop} :
    { c : α × β // p c.1 ∧ q c.2 } ≃ { a // p a } × { b // q b } where
  toFun := fun x => ⟨⟨x.1.1, x.2.1⟩, ⟨x.1.2, x.2.2⟩⟩
  invFun := fun x => ⟨⟨x.1.1, x.2.1⟩, ⟨x.1.2, x.2.2⟩⟩
  left_inv := fun ⟨⟨_, _⟩, ⟨_, _⟩⟩ => rfl
  right_inv := fun ⟨⟨_, _⟩, ⟨_, _⟩⟩ => rfl

/-- A subtype of a `Prod` that depends only on the first component is equivalent to the
corresponding subtype of the first type times the second type. -/
def prodSubtypeFstEquivSubtypeProd {α β} {p : α → Prop} :
    {s : α × β // p s.1} ≃ {a // p a} × β where
  toFun x := ⟨⟨x.1.1, x.2⟩, x.1.2⟩
  invFun x := ⟨⟨x.1.1, x.2⟩, x.1.2⟩
  left_inv _ := rfl
  right_inv _ := rfl

/-- A subtype of a `Prod` is equivalent to a sigma type whose fibers are subtypes. -/
def subtypeProdEquivSigmaSubtype {α β} (p : α → β → Prop) :
    { x : α × β // p x.1 x.2 } ≃ Σa, { b : β // p a b } where
  toFun x := ⟨x.1.1, x.1.2, x.property⟩
  invFun x := ⟨⟨x.1, x.2⟩, x.2.property⟩
  left_inv x := by ext <;> rfl
  right_inv := fun ⟨_, _, _⟩ => rfl

/-- The type `∀ (i : α), β i` can be split as a product by separating the indices in `α`
depending on whether they satisfy a predicate `p` or not. -/
@[simps]
def piEquivPiSubtypeProd {α : Type*} (p : α → Prop) (β : α → Type*) [DecidablePred p] :
    (∀ i : α, β i) ≃ (∀ i : { x // p x }, β i) × ∀ i : { x // ¬p x }, β i where
  toFun f := (fun x => f x, fun x => f x)
  invFun f x := if h : p x then f.1 ⟨x, h⟩ else f.2 ⟨x, h⟩
  right_inv := by
    rintro ⟨f, g⟩
    ext1 <;>
      · ext y
        rcases y with ⟨val, property⟩
        simp only [property, dif_pos, dif_neg, not_false_iff, Subtype.coe_mk]
  left_inv f := by
    ext x
    by_cases h : p x <;>
      · simp only [h, dif_neg, dif_pos, not_false_iff]

/-- A product of types can be split as the binary product of one of the types and the product
  of all the remaining types. -/
@[simps]
def piSplitAt {α : Type*} [DecidableEq α] (i : α) (β : α → Type*) :
    (∀ j, β j) ≃ β i × ∀ j : { j // j ≠ i }, β j where
  toFun f := ⟨f i, fun j => f j⟩
  invFun f j := if h : j = i then h.symm.rec f.1 else f.2 ⟨j, h⟩
  right_inv f := by
    ext x
    exacts [dif_pos rfl, (dif_neg x.2).trans (by cases x; rfl)]
  left_inv f := by
    ext x
    dsimp only
    split_ifs with h
    · subst h; rfl
    · rfl

/-- A product of copies of a type can be split as the binary product of one copy and the product
  of all the remaining copies. -/
@[simps!]
def funSplitAt {α : Type*} [DecidableEq α] (i : α) (β : Type*) :
    (α → β) ≃ β × ({ j // j ≠ i } → β) :=
  piSplitAt i _

end

section subtypeEquivCodomain

variable {X Y : Sort*} [DecidableEq X] {x : X}

/-- The type of all functions `X → Y` with prescribed values for all `x' ≠ x`
is equivalent to the codomain `Y`. -/
def subtypeEquivCodomain (f : { x' // x' ≠ x } → Y) :
    { g : X → Y // g ∘ (↑) = f } ≃ Y :=
  (subtypePreimage _ f).trans <|
    @funUnique { x' // ¬x' ≠ x } _ <|
      show Unique { x' // ¬x' ≠ x } from
        @Equiv.unique _ _
          (show Unique { x' // x' = x } from {
            default := ⟨x, rfl⟩, uniq := fun ⟨_, h⟩ => Subtype.val_injective h })
          (subtypeEquivRight fun _ => not_not)

@[simp]
theorem coe_subtypeEquivCodomain (f : { x' // x' ≠ x } → Y) :
    (subtypeEquivCodomain f : _ → Y) =
      fun g : { g : X → Y // g ∘ (↑) = f } => (g : X → Y) x :=
  rfl

@[simp]
theorem subtypeEquivCodomain_apply (f : { x' // x' ≠ x } → Y) (g) :
    subtypeEquivCodomain f g = (g : X → Y) x :=
  rfl

theorem coe_subtypeEquivCodomain_symm (f : { x' // x' ≠ x } → Y) :
    ((subtypeEquivCodomain f).symm : Y → _) = fun y =>
      ⟨fun x' => if h : x' ≠ x then f ⟨x', h⟩ else y, by
        funext x'
        simp only [ne_eq, dite_not, comp_apply, Subtype.coe_eta, dite_eq_ite, ite_eq_right_iff]
        intro w
        exfalso
        exact x'.property w⟩ :=
  rfl

@[simp]
theorem subtypeEquivCodomain_symm_apply (f : { x' // x' ≠ x } → Y) (y : Y) (x' : X) :
    ((subtypeEquivCodomain f).symm y : X → Y) x' = if h : x' ≠ x then f ⟨x', h⟩ else y :=
  rfl

theorem subtypeEquivCodomain_symm_apply_eq (f : { x' // x' ≠ x } → Y) (y : Y) :
    ((subtypeEquivCodomain f).symm y : X → Y) x = y :=
  dif_neg (not_not.mpr rfl)

theorem subtypeEquivCodomain_symm_apply_ne
    (f : { x' // x' ≠ x } → Y) (y : Y) (x' : X) (h : x' ≠ x) :
    ((subtypeEquivCodomain f).symm y : X → Y) x' = f ⟨x', h⟩ :=
  dif_pos h

end subtypeEquivCodomain

instance : CanLift (α → β) (α ≃ β) (↑) Bijective where prf f hf := ⟨ofBijective f hf, rfl⟩

section

variable {α' β' : Type*} (e : Perm α') {p : β' → Prop} [DecidablePred p] (f : α' ≃ Subtype p)

/-- Extend the domain of `e : Equiv.Perm α` to one that is over `β` via `f : α → Subtype p`,
where `p : β → Prop`, permuting only the `b : β` that satisfy `p b`.
This can be used to extend the domain across a function `f : α → β`,
keeping everything outside of `Set.range f` fixed. For this use-case `Equiv` given by `f` can
be constructed by `Equiv.of_leftInverse'` or `Equiv.of_leftInverse` when there is a known
inverse, or `Equiv.ofInjective` in the general case.
-/
def Perm.extendDomain : Perm β' :=
  (permCongr f e).subtypeCongr (Equiv.refl _)

@[simp]
theorem Perm.extendDomain_apply_image (a : α') : e.extendDomain f (f a) = f (e a) := by
  simp [Perm.extendDomain]

theorem Perm.extendDomain_apply_subtype {b : β'} (h : p b) :
    e.extendDomain f b = f (e (f.symm ⟨b, h⟩)) := by
  simp [Perm.extendDomain, h]

theorem Perm.extendDomain_apply_not_subtype {b : β'} (h : ¬p b) : e.extendDomain f b = b := by
  simp [Perm.extendDomain, h]

@[simp]
theorem Perm.extendDomain_refl : Perm.extendDomain (Equiv.refl _) f = Equiv.refl _ := by
  simp [Perm.extendDomain]

@[simp]
theorem Perm.extendDomain_symm : (e.extendDomain f).symm = Perm.extendDomain e.symm f :=
  rfl

theorem Perm.extendDomain_trans (e e' : Perm α') :
    (e.extendDomain f).trans (e'.extendDomain f) = Perm.extendDomain (e.trans e') f := by
  simp [Perm.extendDomain, permCongr_trans]

end

/-- Subtype of the quotient is equivalent to the quotient of the subtype. Let `α` be a setoid with
equivalence relation `~`. Let `p₂` be a predicate on the quotient type `α/~`, and `p₁` be the lift
of this predicate to `α`: `p₁ a ↔ p₂ ⟦a⟧`. Let `~₂` be the restriction of `~` to `{x // p₁ x}`.
Then `{x // p₂ x}` is equivalent to the quotient of `{x // p₁ x}` by `~₂`. -/
def subtypeQuotientEquivQuotientSubtype (p₁ : α → Prop) {s₁ : Setoid α} {s₂ : Setoid (Subtype p₁)}
    (p₂ : Quotient s₁ → Prop) (hp₂ : ∀ a, p₁ a ↔ p₂ ⟦a⟧)
    (h : ∀ x y : Subtype p₁, s₂.r x y ↔ s₁.r x y) : {x // p₂ x} ≃ Quotient s₂ where
  toFun a :=
    Quotient.hrecOn a.1 (fun a h => ⟦⟨a, (hp₂ _).2 h⟩⟧)
      (fun a b hab => hfunext (by rw [Quotient.sound hab]) fun _ _ _ =>
        heq_of_eq (Quotient.sound ((h _ _).2 hab)))
      a.2
  invFun a :=
    Quotient.liftOn a (fun a => (⟨⟦a.1⟧, (hp₂ _).1 a.2⟩ : { x // p₂ x })) fun _ _ hab =>
      Subtype.ext_val (Quotient.sound ((h _ _).1 hab))
  left_inv := by exact fun ⟨a, ha⟩ => Quotient.inductionOn a (fun b hb => rfl) ha
  right_inv a := by exact Quotient.inductionOn a fun ⟨a, ha⟩ => rfl

@[simp]
theorem subtypeQuotientEquivQuotientSubtype_mk (p₁ : α → Prop)
    [s₁ : Setoid α] [s₂ : Setoid (Subtype p₁)] (p₂ : Quotient s₁ → Prop) (hp₂ : ∀ a, p₁ a ↔ p₂ ⟦a⟧)
    (h : ∀ x y : Subtype p₁, s₂ x y ↔ (x : α) ≈ y)
    (x hx) : subtypeQuotientEquivQuotientSubtype p₁ p₂ hp₂ h ⟨⟦x⟧, hx⟩ = ⟦⟨x, (hp₂ _).2 hx⟩⟧ :=
  rfl

@[simp]
theorem subtypeQuotientEquivQuotientSubtype_symm_mk (p₁ : α → Prop)
    [s₁ : Setoid α] [s₂ : Setoid (Subtype p₁)] (p₂ : Quotient s₁ → Prop) (hp₂ : ∀ a, p₁ a ↔ p₂ ⟦a⟧)
    (h : ∀ x y : Subtype p₁, s₂ x y ↔ (x : α) ≈ y) (x) :
    (subtypeQuotientEquivQuotientSubtype p₁ p₂ hp₂ h).symm ⟦x⟧ = ⟨⟦x⟧, (hp₂ _).1 x.property⟩ :=
  rfl

section Swap

variable [DecidableEq α]

/-- A helper function for `Equiv.swap`. -/
def swapCore (a b r : α) : α :=
  if r = a then b else if r = b then a else r

theorem swapCore_self (r a : α) : swapCore a a r = r := by
  unfold swapCore
  split_ifs <;> simp [*]

theorem swapCore_swapCore (r a b : α) : swapCore a b (swapCore a b r) = r := by
  unfold swapCore; split_ifs <;> cc

theorem swapCore_comm (r a b : α) : swapCore a b r = swapCore b a r := by
  unfold swapCore
  -- Porting note: whatever solution works for `swapCore_swapCore` will work here too.
  split_ifs with h₁ h₂ h₃ <;> try simp
  · cases h₁; cases h₂; rfl

/-- `swap a b` is the permutation that swaps `a` and `b` and
  leaves other values as is. -/
def swap (a b : α) : Perm α :=
  ⟨swapCore a b, swapCore a b, fun r => swapCore_swapCore r a b,
    fun r => swapCore_swapCore r a b⟩

@[simp]
theorem swap_self (a : α) : swap a a = Equiv.refl _ :=
  ext fun r => swapCore_self r a

theorem swap_comm (a b : α) : swap a b = swap b a :=
  ext fun r => swapCore_comm r _ _

theorem swap_apply_def (a b x : α) : swap a b x = if x = a then b else if x = b then a else x :=
  rfl

@[simp]
theorem swap_apply_left (a b : α) : swap a b a = b :=
  if_pos rfl

@[simp]
theorem swap_apply_right (a b : α) : swap a b b = a := by
  by_cases h : b = a <;> simp [swap_apply_def, h]

theorem swap_apply_of_ne_of_ne {a b x : α} : x ≠ a → x ≠ b → swap a b x = x := by
  simp (config := { contextual := true }) [swap_apply_def]

theorem eq_or_eq_of_swap_apply_ne_self {a b x : α} (h : swap a b x ≠ x) : x = a ∨ x = b := by
  contrapose! h
  exact swap_apply_of_ne_of_ne h.1 h.2

@[simp]
theorem swap_swap (a b : α) : (swap a b).trans (swap a b) = Equiv.refl _ :=
  ext fun _ => swapCore_swapCore _ _ _

@[simp]
theorem symm_swap (a b : α) : (swap a b).symm = swap a b :=
  rfl

@[simp]
theorem swap_eq_refl_iff {x y : α} : swap x y = Equiv.refl _ ↔ x = y := by
  refine ⟨fun h => (Equiv.refl _).injective ?_, fun h => h ▸ swap_self _⟩
  rw [← h, swap_apply_left, h, refl_apply]

theorem swap_comp_apply {a b x : α} (π : Perm α) :
    π.trans (swap a b) x = if π x = a then b else if π x = b then a else π x := by
  cases π
  rfl

theorem swap_eq_update (i j : α) : (Equiv.swap i j : α → α) = update (update id j i) i j :=
  funext fun x => by rw [update_apply _ i j, update_apply _ j i, Equiv.swap_apply_def, id]

theorem comp_swap_eq_update (i j : α) (f : α → β) :
    f ∘ Equiv.swap i j = update (update f j (f i)) i (f j) := by
  rw [swap_eq_update, comp_update, comp_update, comp_id]

@[simp]
theorem symm_trans_swap_trans [DecidableEq β] (a b : α) (e : α ≃ β) :
    (e.symm.trans (swap a b)).trans e = swap (e a) (e b) :=
  Equiv.ext fun x => by
    have : ∀ a, e.symm x = a ↔ x = e a := fun a => by
      rw [@eq_comm _ (e.symm x)]
      constructor <;> intros <;> simp_all
    simp only [trans_apply, swap_apply_def, this]
    split_ifs <;> simp

@[simp]
theorem trans_swap_trans_symm [DecidableEq β] (a b : β) (e : α ≃ β) :
    (e.trans (swap a b)).trans e.symm = swap (e.symm a) (e.symm b) :=
  symm_trans_swap_trans a b e.symm

@[simp]
theorem swap_apply_self (i j a : α) : swap i j (swap i j a) = a := by
  rw [← Equiv.trans_apply, Equiv.swap_swap, Equiv.refl_apply]

/-- A function is invariant to a swap if it is equal at both elements -/
theorem apply_swap_eq_self {v : α → β} {i j : α} (hv : v i = v j) (k : α) :
    v (swap i j k) = v k := by
  by_cases hi : k = i
  · rw [hi, swap_apply_left, hv]

  by_cases hj : k = j
  · rw [hj, swap_apply_right, hv]

  rw [swap_apply_of_ne_of_ne hi hj]

theorem swap_apply_eq_iff {x y z w : α} : swap x y z = w ↔ z = swap x y w := by
  rw [apply_eq_iff_eq_symm_apply, symm_swap]

theorem swap_apply_ne_self_iff {a b x : α} : swap a b x ≠ x ↔ a ≠ b ∧ (x = a ∨ x = b) := by
  by_cases hab : a = b
  · simp [hab]

  by_cases hax : x = a
  · simp [hax, eq_comm]

  by_cases hbx : x = b
  · simp [hbx]

  simp [hab, hax, hbx, swap_apply_of_ne_of_ne]

namespace Perm

@[simp]
theorem sumCongr_swap_refl {α β : Sort _} [DecidableEq α] [DecidableEq β] (i j : α) :
    Equiv.Perm.sumCongr (Equiv.swap i j) (Equiv.refl β) = Equiv.swap (Sum.inl i) (Sum.inl j) := by
  ext x
  cases x
  · simp only [Equiv.sumCongr_apply, Sum.map, coe_refl, comp_id, Sum.elim_inl, comp_apply,
      swap_apply_def, Sum.inl.injEq]
    split_ifs <;> rfl
  · simp [Sum.map, swap_apply_of_ne_of_ne]

@[simp]
theorem sumCongr_refl_swap {α β : Sort _} [DecidableEq α] [DecidableEq β] (i j : β) :
    Equiv.Perm.sumCongr (Equiv.refl α) (Equiv.swap i j) = Equiv.swap (Sum.inr i) (Sum.inr j) := by
  ext x
  cases x
  · simp [Sum.map, swap_apply_of_ne_of_ne]

  · simp only [Equiv.sumCongr_apply, Sum.map, coe_refl, comp_id, Sum.elim_inr, comp_apply,
      swap_apply_def, Sum.inr.injEq]
    split_ifs <;> rfl

end Perm

/-- Augment an equivalence with a prescribed mapping `f a = b` -/
def setValue (f : α ≃ β) (a : α) (b : β) : α ≃ β :=
  (swap a (f.symm b)).trans f

@[simp]
theorem setValue_eq (f : α ≃ β) (a : α) (b : β) : setValue f a b a = b := by
  simp [setValue, swap_apply_left]

end Swap

end Equiv

namespace Function.Involutive

/-- Convert an involutive function `f` to a permutation with `toFun = invFun = f`. -/
def toPerm (f : α → α) (h : Involutive f) : Equiv.Perm α :=
  ⟨f, f, h.leftInverse, h.rightInverse⟩

@[simp]
theorem coe_toPerm {f : α → α} (h : Involutive f) : (h.toPerm f : α → α) = f :=
  rfl

@[simp]
theorem toPerm_symm {f : α → α} (h : Involutive f) : (h.toPerm f).symm = h.toPerm f :=
  rfl

theorem toPerm_involutive {f : α → α} (h : Involutive f) : Involutive (h.toPerm f) :=
  h

theorem symm_eq_self_of_involutive (f : Equiv.Perm α) (h : Involutive f) : f.symm = f :=
  DFunLike.coe_injective (h.leftInverse_iff.mp f.left_inv)

end Function.Involutive

theorem PLift.eq_up_iff_down_eq {x : PLift α} {y : α} : x = PLift.up y ↔ x.down = y :=
  Equiv.plift.eq_symm_apply

theorem Function.Injective.map_swap [DecidableEq α] [DecidableEq β] {f : α → β}
    (hf : Function.Injective f) (x y z : α) :
    f (Equiv.swap x y z) = Equiv.swap (f x) (f y) (f z) := by
  conv_rhs => rw [Equiv.swap_apply_def]
  split_ifs with h₁ h₂
  · rw [hf h₁, Equiv.swap_apply_left]
  · rw [hf h₂, Equiv.swap_apply_right]
  · rw [Equiv.swap_apply_of_ne_of_ne (mt (congr_arg f) h₁) (mt (congr_arg f) h₂)]

namespace Equiv

section

/-- Transport dependent functions through an equivalence of the base space.
-/
@[simps apply, simps (config := .lemmasOnly) symm_apply]
def piCongrLeft' (P : α → Sort*) (e : α ≃ β) : (∀ a, P a) ≃ ∀ b, P (e.symm b) where
  toFun f x := f (e.symm x)
  invFun f x := (e.symm_apply_apply x).ndrec (f (e x))
  left_inv f := funext fun x =>
    (by rintro _ rfl; rfl : ∀ {y} (h : y = x), h.ndrec (f y) = f x) (e.symm_apply_apply x)
  right_inv f := funext fun x =>
    (by rintro _ rfl; rfl : ∀ {y} (h : y = x), (congr_arg e.symm h).ndrec (f y) = f x)
      (e.apply_symm_apply x)

/-- Note: the "obvious" statement `(piCongrLeft' P e).symm g a = g (e a)` doesn't typecheck: the
LHS would have type `P a` while the RHS would have type `P (e.symm (e a))`. For that reason,
we have to explicitly substitute along `e.symm (e a) = a` in the statement of this lemma. -/
add_decl_doc Equiv.piCongrLeft'_symm_apply

/-- This lemma is impractical to state in the dependent case. -/
@[simp]
theorem piCongrLeft'_symm (P : Sort*) (e : α ≃ β) :
    (piCongrLeft' (fun _ => P) e).symm = piCongrLeft' _ e.symm := by ext; simp [piCongrLeft']

/-- Note: the "obvious" statement `(piCongrLeft' P e).symm g a = g (e a)` doesn't typecheck: the
LHS would have type `P a` while the RHS would have type `P (e.symm (e a))`. This lemma is a way
around it in the case where `a` is of the form `e.symm b`, so we can use `g b` instead of
`g (e (e.symm b))`. -/
@[simp]
lemma piCongrLeft'_symm_apply_apply (P : α → Sort*) (e : α ≃ β) (g : ∀ b, P (e.symm b)) (b : β) :
    (piCongrLeft' P e).symm g (e.symm b) = g b := by
  rw [piCongrLeft'_symm_apply, ← heq_iff_eq, rec_heq_iff_heq]
  exact congr_arg_heq _ (e.apply_symm_apply _)

end

section

variable (P : β → Sort w) (e : α ≃ β)

/-- Transporting dependent functions through an equivalence of the base,
expressed as a "simplification".
-/
def piCongrLeft : (∀ a, P (e a)) ≃ ∀ b, P b :=
  (piCongrLeft' P e.symm).symm

/-- Note: the "obvious" statement `(piCongrLeft P e) f b = f (e.symm b)` doesn't typecheck: the
LHS would have type `P b` while the RHS would have type `P (e (e.symm b))`. For that reason,
we have to explicitly substitute along `e (e.symm b) = b` in the statement of this lemma. -/
@[simp]
lemma piCongrLeft_apply (f : ∀ a, P (e a)) (b : β) :
    (piCongrLeft P e) f b = e.apply_symm_apply b ▸ f (e.symm b) :=
  rfl

@[simp]
lemma piCongrLeft_symm_apply (g : ∀ b, P b) (a : α) :
    (piCongrLeft P e).symm g a = g (e a) :=
  piCongrLeft'_apply P e.symm g a

/-- Note: the "obvious" statement `(piCongrLeft P e) f b = f (e.symm b)` doesn't typecheck: the
LHS would have type `P b` while the RHS would have type `P (e (e.symm b))`. This lemma is a way
around it in the case where `b` is of the form `e a`, so we can use `f a` instead of
`f (e.symm (e a))`. -/
lemma piCongrLeft_apply_apply (f : ∀ a, P (e a)) (a : α) :
    (piCongrLeft P e) f (e a) = f a :=
  piCongrLeft'_symm_apply_apply P e.symm f a

open Sum

lemma piCongrLeft_apply_eq_cast {P : β → Sort v} {e : α ≃ β}
    (f : (a : α) → P (e a)) (b : β) :
    piCongrLeft P e f b = cast (congr_arg P (e.apply_symm_apply b)) (f (e.symm b)) :=
  Eq.rec_eq_cast _ _

theorem piCongrLeft_sum_inl {ι ι' ι''} (π : ι'' → Type*) (e : ι ⊕ ι' ≃ ι'') (f : ∀ i, π (e (inl i)))
    (g : ∀ i, π (e (inr i))) (i : ι) :
    piCongrLeft π e (sumPiEquivProdPi (fun x => π (e x)) |>.symm (f, g)) (e (inl i)) = f i := by
  simp_rw [piCongrLeft_apply_eq_cast, sumPiEquivProdPi_symm_apply,
    sum_rec_congr _ _ _ (e.symm_apply_apply (inl i)), cast_cast, cast_eq]

theorem piCongrLeft_sum_inr {ι ι' ι''} (π : ι'' → Type*) (e : ι ⊕ ι' ≃ ι'') (f : ∀ i, π (e (inl i)))
    (g : ∀ i, π (e (inr i))) (j : ι') :
    piCongrLeft π e (sumPiEquivProdPi (fun x => π (e x)) |>.symm (f, g)) (e (inr j)) = g j := by
  simp_rw [piCongrLeft_apply_eq_cast, sumPiEquivProdPi_symm_apply,
    sum_rec_congr _ _ _ (e.symm_apply_apply (inr j)), cast_cast, cast_eq]

end

section

variable {W : α → Sort w} {Z : β → Sort z} (h₁ : α ≃ β) (h₂ : ∀ a : α, W a ≃ Z (h₁ a))

/-- Transport dependent functions through
an equivalence of the base spaces and a family
of equivalences of the matching fibers.
-/
def piCongr : (∀ a, W a) ≃ ∀ b, Z b :=
  (Equiv.piCongrRight h₂).trans (Equiv.piCongrLeft _ h₁)

@[simp]
theorem coe_piCongr_symm : ((h₁.piCongr h₂).symm :
    (∀ b, Z b) → ∀ a, W a) = fun f a => (h₂ a).symm (f (h₁ a)) :=
  rfl

theorem piCongr_symm_apply (f : ∀ b, Z b) :
    (h₁.piCongr h₂).symm f = fun a => (h₂ a).symm (f (h₁ a)) :=
  rfl

@[simp]
theorem piCongr_apply_apply (f : ∀ a, W a) (a : α) : h₁.piCongr h₂ f (h₁ a) = h₂ a (f a) := by
  simp only [piCongr, piCongrRight, trans_apply, coe_fn_mk, piCongrLeft_apply_apply, Pi.map_apply]

end

section

variable {W : α → Sort w} {Z : β → Sort z} (h₁ : α ≃ β) (h₂ : ∀ b : β, W (h₁.symm b) ≃ Z b)

/-- Transport dependent functions through
an equivalence of the base spaces and a family
of equivalences of the matching fibres.
-/
def piCongr' : (∀ a, W a) ≃ ∀ b, Z b :=
  (piCongr h₁.symm fun b => (h₂ b).symm).symm

@[simp]
theorem coe_piCongr' :
    (h₁.piCongr' h₂ : (∀ a, W a) → ∀ b, Z b) = fun f b => h₂ b <| f <| h₁.symm b :=
  rfl

theorem piCongr'_apply (f : ∀ a, W a) : h₁.piCongr' h₂ f = fun b => h₂ b <| f <| h₁.symm b :=
  rfl

@[simp]
theorem piCongr'_symm_apply_symm_apply (f : ∀ b, Z b) (b : β) :
    (h₁.piCongr' h₂).symm f (h₁.symm b) = (h₂ b).symm (f b) := by
  simp [piCongr', piCongr_apply_apply]

end

section BinaryOp

variable {α₁ β₁ : Type*} (e : α₁ ≃ β₁) (f : α₁ → α₁ → α₁)

theorem semiconj_conj (f : α₁ → α₁) : Semiconj e f (e.conj f) := fun x => by simp

theorem semiconj₂_conj : Semiconj₂ e f (e.arrowCongr e.conj f) := fun x y => by simp [arrowCongr]

instance [Std.Associative f] : Std.Associative (e.arrowCongr (e.arrowCongr e) f) :=
  (e.semiconj₂_conj f).isAssociative_right e.surjective

instance [Std.IdempotentOp f] : Std.IdempotentOp (e.arrowCongr (e.arrowCongr e) f) :=
  (e.semiconj₂_conj f).isIdempotent_right e.surjective

end BinaryOp

section ULift

@[simp]
theorem ulift_symm_down {α} (x : α) : (Equiv.ulift.{u, v}.symm x).down = x :=
  rfl

end ULift

end Equiv

theorem Function.Injective.swap_apply
    [DecidableEq α] [DecidableEq β] {f : α → β} (hf : Function.Injective f) (x y z : α) :
    Equiv.swap (f x) (f y) (f z) = f (Equiv.swap x y z) := by
  by_cases hx : z = x
  · simp [hx]

  by_cases hy : z = y
  · simp [hy]

  rw [Equiv.swap_apply_of_ne_of_ne hx hy, Equiv.swap_apply_of_ne_of_ne (hf.ne hx) (hf.ne hy)]

theorem Function.Injective.swap_comp
    [DecidableEq α] [DecidableEq β] {f : α → β} (hf : Function.Injective f) (x y : α) :
    Equiv.swap (f x) (f y) ∘ f = f ∘ Equiv.swap x y :=
  funext fun _ => hf.swap_apply _ _ _

/-- If `α` is a subsingleton, then it is equivalent to `α × α`. -/
def subsingletonProdSelfEquiv {α} [Subsingleton α] : α × α ≃ α where
  toFun p := p.1
  invFun a := (a, a)
  left_inv _ := Subsingleton.elim _ _
  right_inv _ := Subsingleton.elim _ _

/-- To give an equivalence between two subsingleton types, it is sufficient to give any two
    functions between them. -/
def equivOfSubsingletonOfSubsingleton [Subsingleton α] [Subsingleton β] (f : α → β) (g : β → α) :
    α ≃ β where
  toFun := f
  invFun := g
  left_inv _ := Subsingleton.elim _ _
  right_inv _ := Subsingleton.elim _ _

/-- A nonempty subsingleton type is (noncomputably) equivalent to `PUnit`. -/
noncomputable def Equiv.punitOfNonemptyOfSubsingleton [h : Nonempty α] [Subsingleton α] :
    α ≃ PUnit :=
  equivOfSubsingletonOfSubsingleton (fun _ => PUnit.unit) fun _ => h.some

/-- `Unique (Unique α)` is equivalent to `Unique α`. -/
def uniqueUniqueEquiv : Unique (Unique α) ≃ Unique α :=
  equivOfSubsingletonOfSubsingleton (fun h => h.default) fun h =>
    { default := h, uniq := fun _ => Subsingleton.elim _ _ }

/-- If `Unique β`, then `Unique α` is equivalent to `α ≃ β`. -/
def uniqueEquivEquivUnique (α : Sort u) (β : Sort v) [Unique β] : Unique α ≃ (α ≃ β) :=
  equivOfSubsingletonOfSubsingleton (fun _ => Equiv.equivOfUnique _ _) Equiv.unique

namespace Function

variable {α' : Sort*}

theorem update_comp_equiv [DecidableEq α'] [DecidableEq α] (f : α → β)
    (g : α' ≃ α) (a : α) (v : β) :
    update f a v ∘ g = update (f ∘ g) (g.symm a) v := by
  rw [← update_comp_eq_of_injective _ g.injective, g.apply_symm_apply]

theorem update_apply_equiv_apply [DecidableEq α'] [DecidableEq α] (f : α → β)
    (g : α' ≃ α) (a : α) (v : β) (a' : α') : update f a v (g a') = update (f ∘ g) (g.symm a) v a' :=
  congr_fun (update_comp_equiv f g a v) a'

-- Porting note: EmbeddingLike.apply_eq_iff_eq broken here too
theorem piCongrLeft'_update [DecidableEq α] [DecidableEq β] (P : α → Sort*) (e : α ≃ β)
    (f : ∀ a, P a) (b : β) (x : P (e.symm b)) :
    e.piCongrLeft' P (update f (e.symm b) x) = update (e.piCongrLeft' P f) b x := by
  ext b'
  rcases eq_or_ne b' b with (rfl | h)
  · simp
  · simp only [Equiv.piCongrLeft'_apply, ne_eq, h, not_false_iff, update_noteq]
    rw [update_noteq _]
    rw [ne_eq]
    intro h'
    /- an example of something that should work, or also putting `EmbeddingLike.apply_eq_iff_eq`
      in the `simp` should too:
    have := (EmbeddingLike.apply_eq_iff_eq e).mp h' -/
    cases e.symm.injective h' |> h

theorem piCongrLeft'_symm_update [DecidableEq α] [DecidableEq β] (P : α → Sort*) (e : α ≃ β)
    (f : ∀ b, P (e.symm b)) (b : β) (x : P (e.symm b)) :
    (e.piCongrLeft' P).symm (update f b x) = update ((e.piCongrLeft' P).symm f) (e.symm b) x := by
  simp [(e.piCongrLeft' P).symm_apply_eq, piCongrLeft'_update]

end Function

set_option linter.style.longFile 2000
