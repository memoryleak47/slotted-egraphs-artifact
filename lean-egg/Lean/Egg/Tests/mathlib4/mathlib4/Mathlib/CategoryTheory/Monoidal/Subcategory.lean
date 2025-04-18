import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2022 Antoine Labelle. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antoine Labelle
-/
import Mathlib.CategoryTheory.Monoidal.Braided.Basic
import Mathlib.CategoryTheory.Monoidal.Linear
import Mathlib.CategoryTheory.Monoidal.Transport
import Mathlib.CategoryTheory.Preadditive.AdditiveFunctor
import Mathlib.CategoryTheory.Linear.LinearFunctor
import Mathlib.CategoryTheory.Closed.Monoidal

/-!
# Full monoidal subcategories

Given a monoidal category `C` and a monoidal predicate on `C`, that is a function `P : C → Prop`
closed under `𝟙_` and `⊗`, we can put a monoidal structure on `{X : C // P X}` (the category
structure is defined in `Mathlib.CategoryTheory.FullSubcategory`).

When `C` is also braided/symmetric, the full monoidal subcategory also inherits the
braided/symmetric structure.

## TODO
* Add monoidal/braided versions of `CategoryTheory.FullSubcategory.Lift`
-/


universe u v

namespace CategoryTheory

namespace MonoidalCategory

open Iso

variable {C : Type u} [Category.{v} C] [MonoidalCategory C] (P : C → Prop)

/-- A property `C → Prop` is a monoidal predicate if it is closed under `𝟙_` and `⊗`.
-/
class MonoidalPredicate : Prop where
  prop_id : P (𝟙_ C) := by aesop_cat
  prop_tensor : ∀ {X Y}, P X → P Y → P (X ⊗ Y) := by aesop_cat

open MonoidalPredicate

variable [MonoidalPredicate P]

@[simps]
instance : MonoidalCategoryStruct (FullSubcategory P) where
  tensorObj X Y := ⟨X.1 ⊗ Y.1, prop_tensor X.2 Y.2⟩
  whiskerLeft X _ _ f := X.1 ◁ f
  whiskerRight {X₁ X₂} (f : X₁.1 ⟶ X₂.1) Y := (f ▷ Y.1 :)
  tensorHom f g := f ⊗ g
  tensorUnit := ⟨𝟙_ C, prop_id⟩
  associator X Y Z :=
    ⟨(α_ X.1 Y.1 Z.1).hom, (α_ X.1 Y.1 Z.1).inv, hom_inv_id (α_ X.1 Y.1 Z.1),
      inv_hom_id (α_ X.1 Y.1 Z.1)⟩
  leftUnitor X := ⟨(λ_ X.1).hom, (λ_ X.1).inv, hom_inv_id (λ_ X.1), inv_hom_id (λ_ X.1)⟩
  rightUnitor X := ⟨(ρ_ X.1).hom, (ρ_ X.1).inv, hom_inv_id (ρ_ X.1), inv_hom_id (ρ_ X.1)⟩

/--
When `P` is a monoidal predicate, the full subcategory for `P` inherits the monoidal structure of
  `C`.
-/
instance fullMonoidalSubcategory : MonoidalCategory (FullSubcategory P) :=
  Monoidal.induced (fullSubcategoryInclusion P)
    { μIso := fun _ _ => eqToIso rfl
      εIso := eqToIso rfl }

/-- The forgetful monoidal functor from a full monoidal subcategory into the original category
("forgetting" the condition).
-/
@[simps]
def fullMonoidalSubcategoryInclusion : MonoidalFunctor (FullSubcategory P) C where
  toFunctor := fullSubcategoryInclusion P
  ε := 𝟙 _
  μ _ _ := 𝟙 _

instance fullMonoidalSubcategory.full : (fullMonoidalSubcategoryInclusion P).Full :=
  FullSubcategory.full P

instance fullMonoidalSubcategory.faithful :
    (fullMonoidalSubcategoryInclusion P).Faithful :=
  FullSubcategory.faithful P

section

variable [Preadditive C]

instance fullMonoidalSubcategoryInclusion_additive :
    (fullMonoidalSubcategoryInclusion P).toFunctor.Additive :=
  Functor.fullSubcategoryInclusion_additive _

instance [MonoidalPreadditive C] : MonoidalPreadditive (FullSubcategory P) :=
  monoidalPreadditive_of_faithful (fullMonoidalSubcategoryInclusion P)

variable (R : Type*) [Ring R] [Linear R C]

instance fullMonoidalSubcategoryInclusion_linear :
    (fullMonoidalSubcategoryInclusion P).toFunctor.Linear R :=
  Functor.fullSubcategoryInclusionLinear R _

instance [MonoidalPreadditive C] [MonoidalLinear R C] : MonoidalLinear R (FullSubcategory P) :=
  monoidalLinearOfFaithful R (fullMonoidalSubcategoryInclusion P)

end

variable {P} {P' : C → Prop} [MonoidalPredicate P']

-- needed for `aesop_cat`
attribute [local simp] FullSubcategory.comp_def FullSubcategory.id_def in
/-- An implication of predicates `P → P'` induces a monoidal functor between full monoidal
subcategories. -/
@[simps]
def fullMonoidalSubcategory.map (h : ∀ ⦃X⦄, P X → P' X) :
    MonoidalFunctor (FullSubcategory P) (FullSubcategory P') where
  toFunctor := FullSubcategory.map h
  ε := 𝟙 _
  μ _ _ := 𝟙 _

instance fullMonoidalSubcategory.map_full (h : ∀ ⦃X⦄, P X → P' X) :
    (fullMonoidalSubcategory.map h).Full where
  map_surjective f := ⟨f, rfl⟩

instance fullMonoidalSubcategory.map_faithful (h : ∀ ⦃X⦄, P X → P' X) :
    (fullMonoidalSubcategory.map h).Faithful where

section Braided

variable (P) [BraidedCategory C]

/-- The braided structure on a full subcategory inherited by the braided structure on `C`.
-/
instance fullBraidedSubcategory : BraidedCategory (FullSubcategory P) :=
  braidedCategoryOfFaithful (fullMonoidalSubcategoryInclusion P)
    (fun X Y =>
      ⟨(β_ X.1 Y.1).hom, (β_ X.1 Y.1).inv, (β_ X.1 Y.1).hom_inv_id, (β_ X.1 Y.1).inv_hom_id⟩)
    fun X Y => by aesop_cat

/-- The forgetful braided functor from a full braided subcategory into the original category
("forgetting" the condition).
-/
@[simps!]
def fullBraidedSubcategoryInclusion : BraidedFunctor (FullSubcategory P) C where
  toMonoidalFunctor := fullMonoidalSubcategoryInclusion P
  braided X Y := by rw [IsIso.eq_inv_comp]; aesop_cat

instance fullBraidedSubcategory.full : (fullBraidedSubcategoryInclusion P).Full :=
  fullMonoidalSubcategory.full P

instance fullBraidedSubcategory.faithful : (fullBraidedSubcategoryInclusion P).Faithful :=
  fullMonoidalSubcategory.faithful P

variable {P}

/-- An implication of predicates `P → P'` induces a braided functor between full braided
subcategories. -/
@[simps!]
def fullBraidedSubcategory.map (h : ∀ ⦃X⦄, P X → P' X) :
    BraidedFunctor (FullSubcategory P) (FullSubcategory P') where
  toMonoidalFunctor := fullMonoidalSubcategory.map h
  braided X Y := by rw [IsIso.eq_inv_comp]; aesop_cat

instance fullBraidedSubcategory.mapFull (h : ∀ ⦃X⦄, P X → P' X) :
    (fullBraidedSubcategory.map h).Full :=
  fullMonoidalSubcategory.map_full h

instance fullBraidedSubcategory.map_faithful (h : ∀ ⦃X⦄, P X → P' X) :
    (fullBraidedSubcategory.map h).Faithful :=
  fullMonoidalSubcategory.map_faithful h

end Braided

section Symmetric

variable (P) [SymmetricCategory C]

instance fullSymmetricSubcategory : SymmetricCategory (FullSubcategory P) :=
  symmetricCategoryOfFaithful (fullBraidedSubcategoryInclusion P)

end Symmetric

section Closed

variable (P) [MonoidalClosed C]

/-- A property `C → Prop` is a closed predicate if it is closed under taking internal homs
-/
class ClosedPredicate : Prop where
  prop_ihom : ∀ {X Y}, P X → P Y → P ((ihom X).obj Y) := by aesop_cat

open ClosedPredicate

variable [ClosedPredicate P]

instance fullMonoidalClosedSubcategory : MonoidalClosed (FullSubcategory P) where
  closed X :=
    { rightAdj := FullSubcategory.lift P (fullSubcategoryInclusion P ⋙ ihom X.1)
        fun Y => prop_ihom X.2 Y.2
      adj :=
        { unit :=
          { app := fun Y => (ihom.coev X.1).app Y.1
            naturality := fun _ _ f => ihom.coev_naturality X.1 f }
          counit :=
          { app := fun Y => (ihom.ev X.1).app Y.1
            naturality := fun _ _ f => ihom.ev_naturality X.1 f }
          left_triangle_components := fun X ↦
            by simp [FullSubcategory.comp_def, FullSubcategory.id_def]
          right_triangle_components := fun Y ↦
            by simp [FullSubcategory.comp_def, FullSubcategory.id_def] } }

@[simp]
theorem fullMonoidalClosedSubcategory_ihom_obj (X Y : FullSubcategory P) :
    ((ihom X).obj Y).obj = (ihom X.obj).obj Y.obj :=
  rfl

@[simp]
theorem fullMonoidalClosedSubcategory_ihom_map (X : FullSubcategory P) {Y Z : FullSubcategory P}
    (f : Y ⟶ Z) : (ihom X).map f = (ihom X.obj).map f :=
  rfl

end Closed

end MonoidalCategory

end CategoryTheory
