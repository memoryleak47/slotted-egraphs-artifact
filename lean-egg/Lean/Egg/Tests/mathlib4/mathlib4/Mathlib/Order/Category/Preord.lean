import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin
-/
import Mathlib.CategoryTheory.Category.Cat
import Mathlib.CategoryTheory.Category.Preorder
import Mathlib.CategoryTheory.ConcreteCategory.BundledHom
import Mathlib.Order.Hom.Basic
import Mathlib.Order.CompleteBooleanAlgebra

/-!
# Category of preorders

This defines `Preord`, the category of preorders with monotone maps.
-/


universe u

open CategoryTheory

/-- The category of preorders. -/
def Preord :=
  Bundled Preorder

namespace Preord

instance : BundledHom @OrderHom where
  toFun := @OrderHom.toFun
  id := @OrderHom.id
  comp := @OrderHom.comp
  hom_ext := @OrderHom.ext

deriving instance LargeCategory for Preord

-- Porting note: probably see https://github.com/leanprover-community/mathlib4/issues/5020
instance : ConcreteCategory Preord :=
  BundledHom.concreteCategory _

instance : CoeSort Preord Type* :=
  Bundled.coeSort

/-- Construct a bundled Preord from the underlying type and typeclass. -/
def of (α : Type*) [Preorder α] : Preord :=
  Bundled.of α

@[simp]
theorem coe_of (α : Type*) [Preorder α] : ↥(of α) = α :=
  rfl

instance : Inhabited Preord :=
  ⟨of PUnit⟩

instance (α : Preord) : Preorder α :=
  α.str

/-- Constructs an equivalence between preorders from an order isomorphism between them. -/
@[simps]
def Iso.mk {α β : Preord.{u}} (e : α ≃o β) : α ≅ β where
  hom := (e : OrderHom α β)
  inv := (e.symm : OrderHom β α)
  hom_inv_id := by
    ext x
    exact e.symm_apply_apply x
  inv_hom_id := by
    ext x
    exact e.apply_symm_apply x

/-- `OrderDual` as a functor. -/
@[simps]
def dual : Preord ⥤ Preord where
  obj X := of Xᵒᵈ
  map := OrderHom.dual

/-- The equivalence between `Preord` and itself induced by `OrderDual` both ways. -/
@[simps functor inverse]
def dualEquiv : Preord ≌ Preord where
  functor := dual
  inverse := dual
  unitIso := NatIso.ofComponents fun X => Iso.mk <| OrderIso.dualDual X
  counitIso := NatIso.ofComponents fun X => Iso.mk <| OrderIso.dualDual X

end Preord

/-- The embedding of `Preord` into `Cat`.
-/
@[simps]
def preordToCat : Preord.{u} ⥤ Cat where
  obj X := Cat.of X.1
  map f := f.monotone.functor

instance : preordToCat.{u}.Faithful where
  map_injective h := by ext x; exact Functor.congr_obj h x

instance : preordToCat.{u}.Full where
  map_surjective {X Y} f := ⟨⟨f.obj, @CategoryTheory.Functor.monotone X Y _ _ f⟩, rfl⟩
