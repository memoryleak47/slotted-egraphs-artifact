import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies
-/
import Mathlib.Order.Category.HeytAlg
import Mathlib.Order.Hom.CompleteLattice

/-!
# The category of boolean algebras

This defines `BoolAlg`, the category of boolean algebras.
-/


open OrderDual Opposite Set

universe u

open CategoryTheory

/-- The category of boolean algebras. -/
def BoolAlg :=
  Bundled BooleanAlgebra

namespace BoolAlg

instance : CoeSort BoolAlg Type* :=
  Bundled.coeSort

instance instBooleanAlgebra (X : BoolAlg) : BooleanAlgebra X :=
  X.str

/-- Construct a bundled `BoolAlg` from a `BooleanAlgebra`. -/
def of (α : Type*) [BooleanAlgebra α] : BoolAlg :=
  Bundled.of α

@[simp]
theorem coe_of (α : Type*) [BooleanAlgebra α] : ↥(of α) = α :=
  rfl

instance : Inhabited BoolAlg :=
  ⟨of PUnit⟩

/-- Turn a `BoolAlg` into a `BddDistLat` by forgetting its complement operation. -/
def toBddDistLat (X : BoolAlg) : BddDistLat :=
  BddDistLat.of X

@[simp]
theorem coe_toBddDistLat (X : BoolAlg) : ↥X.toBddDistLat = ↥X :=
  rfl

instance : LargeCategory.{u} BoolAlg :=
  InducedCategory.category toBddDistLat

instance : ConcreteCategory BoolAlg :=
  InducedCategory.concreteCategory toBddDistLat

instance hasForgetToBddDistLat : HasForget₂ BoolAlg BddDistLat :=
  InducedCategory.hasForget₂ toBddDistLat

section

attribute [local instance] BoundedLatticeHomClass.toBiheytingHomClass

@[simps]
instance hasForgetToHeytAlg : HasForget₂ BoolAlg HeytAlg where
  forget₂ :=
    { obj := fun X => {α := X}
      -- Porting note: was `fun {X Y} f => show BoundedLatticeHom X Y from f`
      -- which already looks like a hack, but I don't understand why this hack works now and
      -- the old one didn't
      map := fun {X Y} (f : BoundedLatticeHom X Y) => show HeytingHom X Y from f }

end

/-- Constructs an equivalence between Boolean algebras from an order isomorphism between them. -/
@[simps]
def Iso.mk {α β : BoolAlg.{u}} (e : α ≃o β) : α ≅ β where
  hom := (e : BoundedLatticeHom α β)
  inv := (e.symm : BoundedLatticeHom β α)
  hom_inv_id := by ext; exact e.symm_apply_apply _
  inv_hom_id := by ext; exact e.apply_symm_apply _

/-- `OrderDual` as a functor. -/
@[simps]
def dual : BoolAlg ⥤ BoolAlg where
  obj X := of Xᵒᵈ
  map {_ _} := BoundedLatticeHom.dual

/-- The equivalence between `BoolAlg` and itself induced by `OrderDual` both ways. -/
@[simps functor inverse]
def dualEquiv : BoolAlg ≌ BoolAlg where
  functor := dual
  inverse := dual
  unitIso := NatIso.ofComponents fun X => Iso.mk <| OrderIso.dualDual X
  counitIso := NatIso.ofComponents fun X => Iso.mk <| OrderIso.dualDual X

end BoolAlg

theorem boolAlg_dual_comp_forget_to_bddDistLat :
    BoolAlg.dual ⋙ forget₂ BoolAlg BddDistLat =
    forget₂ BoolAlg BddDistLat ⋙ BddDistLat.dual :=
  rfl

/-- The powerset functor. `Set` as a contravariant functor. -/
@[simps]
def typeToBoolAlgOp : Type u ⥤ BoolAlgᵒᵖ where
  obj X := op <| BoolAlg.of (Set X)
  map {X Y} f := Quiver.Hom.op
    (CompleteLatticeHom.setPreimage f : BoundedLatticeHom (Set Y) (Set X))
