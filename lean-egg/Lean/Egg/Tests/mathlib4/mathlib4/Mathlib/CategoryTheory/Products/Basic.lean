import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2017 Kim Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Stephen Morgan, Kim Morrison
-/
import Mathlib.CategoryTheory.Functor.Const
import Mathlib.CategoryTheory.Opposites
import Mathlib.Data.Prod.Basic

/-!
# Cartesian products of categories

We define the category instance on `C × D` when `C` and `D` are categories.

We define:
* `sectl C Z` : the functor `C ⥤ C × D` given by `X ↦ ⟨X, Z⟩`
* `sectr Z D` : the functor `D ⥤ C × D` given by `Y ↦ ⟨Z, Y⟩`
* `fst`       : the functor `⟨X, Y⟩ ↦ X`
* `snd`       : the functor `⟨X, Y⟩ ↦ Y`
* `swap`      : the functor `C × D ⥤ D × C` given by `⟨X, Y⟩ ↦ ⟨Y, X⟩`
    (and the fact this is an equivalence)

We further define `evaluation : C ⥤ (C ⥤ D) ⥤ D` and `evaluationUncurried : C × (C ⥤ D) ⥤ D`,
and products of functors and natural transformations, written `F.prod G` and `α.prod β`.
-/


namespace CategoryTheory

-- declare the `v`'s first; see `CategoryTheory.Category` for an explanation
universe v₁ v₂ v₃ v₄ u₁ u₂ u₃ u₄

section

variable (C : Type u₁) [Category.{v₁} C] (D : Type u₂) [Category.{v₂} D]

-- the generates simp lemmas like `id_fst` and `comp_snd`
/-- `prod C D` gives the cartesian product of two categories.

See <https://stacks.math.columbia.edu/tag/001K>.
-/
@[simps (config := { notRecursive := [] }) Hom id_fst id_snd comp_fst comp_snd]
instance prod : Category.{max v₁ v₂} (C × D) where
  Hom X Y := (X.1 ⟶ Y.1) × (X.2 ⟶ Y.2)
  id X := ⟨𝟙 X.1, 𝟙 X.2⟩
  comp f g := (f.1 ≫ g.1, f.2 ≫ g.2)

@[ext]
lemma prod.hom_ext {X Y : C × D} {f g : X ⟶ Y} (h₁ : f.1 = g.1) (h₂ : f.2 = g.2) : f = g := by
  dsimp
  ext <;> assumption

/-- Two rfl lemmas that cannot be generated by `@[simps]`. -/
@[simp]
theorem prod_id (X : C) (Y : D) : 𝟙 (X, Y) = (𝟙 X, 𝟙 Y) :=
  rfl

@[simp]
theorem prod_comp {P Q R : C} {S T U : D} (f : (P, S) ⟶ (Q, T)) (g : (Q, T) ⟶ (R, U)) :
    f ≫ g = (f.1 ≫ g.1, f.2 ≫ g.2) :=
  rfl

theorem isIso_prod_iff {P Q : C} {S T : D} {f : (P, S) ⟶ (Q, T)} :
    IsIso f ↔ IsIso f.1 ∧ IsIso f.2 := by
  constructor
  · rintro ⟨g, hfg, hgf⟩
    simp? at hfg hgf says simp only [prod_Hom, prod_comp, prod_id, Prod.mk.injEq] at hfg hgf
    rcases hfg with ⟨hfg₁, hfg₂⟩
    rcases hgf with ⟨hgf₁, hgf₂⟩
    exact ⟨⟨⟨g.1, hfg₁, hgf₁⟩⟩, ⟨⟨g.2, hfg₂, hgf₂⟩⟩⟩
  · rintro ⟨⟨g₁, hfg₁, hgf₁⟩, ⟨g₂, hfg₂, hgf₂⟩⟩
    dsimp at hfg₁ hgf₁ hfg₂ hgf₂
    refine ⟨⟨(g₁, g₂), ?_, ?_⟩⟩
    repeat { simp; constructor; assumption; assumption }

section

variable {C D}

/-- The isomorphism between `(X.1, X.2)` and `X`. -/
@[simps]
def prod.etaIso (X : C × D) : (X.1, X.2) ≅ X where
  hom := (𝟙 _, 𝟙 _)
  inv := (𝟙 _, 𝟙 _)

/-- Construct an isomorphism in `C × D` out of two isomorphisms in `C` and `D`. -/
@[simps]
def Iso.prod {P Q : C} {S T : D} (f : P ≅ Q) (g : S ≅ T) : (P, S) ≅ (Q, T) where
  hom := (f.hom, g.hom)
  inv := (f.inv, g.inv)

end

end

section

variable (C : Type u₁) [Category.{v₁} C] (D : Type u₁) [Category.{v₁} D]

/-- `Category.uniformProd C D` is an additional instance specialised so both factors have the same
universe levels. This helps typeclass resolution.
-/
instance uniformProd : Category (C × D) :=
  CategoryTheory.prod C D

end

-- Next we define the natural functors into and out of product categories. For now this doesn't
-- address the universal properties.
namespace Prod

/-- `sectl C Z` is the functor `C ⥤ C × D` given by `X ↦ (X, Z)`. -/
@[simps]
def sectl (C : Type u₁) [Category.{v₁} C] {D : Type u₂} [Category.{v₂} D] (Z : D) : C ⥤ C × D where
  obj X := (X, Z)
  map f := (f, 𝟙 Z)

/-- `sectr Z D` is the functor `D ⥤ C × D` given by `Y ↦ (Z, Y)` . -/
@[simps]
def sectr {C : Type u₁} [Category.{v₁} C] (Z : C) (D : Type u₂) [Category.{v₂} D] : D ⥤ C × D where
  obj X := (Z, X)
  map f := (𝟙 Z, f)

variable (C : Type u₁) [Category.{v₁} C] (D : Type u₂) [Category.{v₂} D]

/-- `fst` is the functor `(X, Y) ↦ X`. -/
@[simps]
def fst : C × D ⥤ C where
  obj X := X.1
  map f := f.1

/-- `snd` is the functor `(X, Y) ↦ Y`. -/
@[simps]
def snd : C × D ⥤ D where
  obj X := X.2
  map f := f.2

/-- The functor swapping the factors of a cartesian product of categories, `C × D ⥤ D × C`. -/
@[simps]
def swap : C × D ⥤ D × C where
  obj X := (X.2, X.1)
  map f := (f.2, f.1)

/-- Swapping the factors of a cartesian product of categories twice is naturally isomorphic
to the identity functor.
-/
@[simps]
def symmetry : swap C D ⋙ swap D C ≅ 𝟭 (C × D) where
  hom := { app := fun X => 𝟙 X }
  inv := { app := fun X => 𝟙 X }

/-- The equivalence, given by swapping factors, between `C × D` and `D × C`.
-/
@[simps]
def braiding : C × D ≌ D × C where
  functor := swap C D
  inverse := swap D C
  unitIso := Iso.refl _
  counitIso := Iso.refl _

instance swapIsEquivalence : (swap C D).IsEquivalence :=
  (by infer_instance : (braiding C D).functor.IsEquivalence)

end Prod

section

variable (C : Type u₁) [Category.{v₁} C] (D : Type u₂) [Category.{v₂} D]

/-- The "evaluation at `X`" functor, such that
`(evaluation.obj X).obj F = F.obj X`,
which is functorial in both `X` and `F`.
-/
@[simps]
def evaluation : C ⥤ (C ⥤ D) ⥤ D where
  obj X :=
    { obj := fun F => F.obj X
      map := fun α => α.app X }
  map {_} {_} f :=
    { app := fun F => F.map f
      naturality := fun {_} {_} α => Eq.symm (α.naturality f) }

/-- The "evaluation of `F` at `X`" functor,
as a functor `C × (C ⥤ D) ⥤ D`.
-/
@[simps]
def evaluationUncurried : C × (C ⥤ D) ⥤ D where
  obj p := p.2.obj p.1
  map := fun {x} {y} f => x.2.map f.1 ≫ f.2.app y.1
  map_comp := fun {X} {Y} {Z} f g => by
    cases g; cases f; cases Z; cases Y; cases X
    simp only [prod_comp, NatTrans.comp_app, Functor.map_comp, Category.assoc]
    rw [← NatTrans.comp_app, NatTrans.naturality, NatTrans.comp_app, Category.assoc,
      NatTrans.naturality]

variable {C}

/-- The constant functor followed by the evaluation functor is just the identity. -/
@[simps!]
def Functor.constCompEvaluationObj (X : C) : Functor.const C ⋙ (evaluation C D).obj X ≅ 𝟭 D :=
  NatIso.ofComponents fun _ => Iso.refl _

end

variable {A : Type u₁} [Category.{v₁} A] {B : Type u₂} [Category.{v₂} B] {C : Type u₃}
  [Category.{v₃} C] {D : Type u₄} [Category.{v₄} D]

namespace Functor

/-- The cartesian product of two functors. -/
@[simps]
def prod (F : A ⥤ B) (G : C ⥤ D) : A × C ⥤ B × D where
  obj X := (F.obj X.1, G.obj X.2)
  map f := (F.map f.1, G.map f.2)

/- Because of limitations in Lean 3's handling of notations, we do not setup a notation `F × G`.
   You can use `F.prod G` as a "poor man's infix", or just write `functor.prod F G`. -/
/-- Similar to `prod`, but both functors start from the same category `A` -/
@[simps]
def prod' (F : A ⥤ B) (G : A ⥤ C) : A ⥤ B × C where
  obj a := (F.obj a, G.obj a)
  map f := (F.map f, G.map f)

/-- The product `F.prod' G` followed by projection on the first component is isomorphic to `F` -/
@[simps!]
def prod'CompFst (F : A ⥤ B) (G : A ⥤ C) : F.prod' G ⋙ CategoryTheory.Prod.fst B C ≅ F :=
  NatIso.ofComponents fun _ => Iso.refl _

/-- The product `F.prod' G` followed by projection on the second component is isomorphic to `G` -/
@[simps!]
def prod'CompSnd (F : A ⥤ B) (G : A ⥤ C) : F.prod' G ⋙ CategoryTheory.Prod.snd B C ≅ G :=
  NatIso.ofComponents fun _ => Iso.refl _

section

variable (C)

/-- The diagonal functor. -/
def diag : C ⥤ C × C :=
  (𝟭 C).prod' (𝟭 C)

@[simp]
theorem diag_obj (X : C) : (diag C).obj X = (X, X) :=
  rfl

@[simp]
theorem diag_map {X Y : C} (f : X ⟶ Y) : (diag C).map f = (f, f) :=
  rfl

end

end Functor

namespace NatTrans

/-- The cartesian product of two natural transformations. -/
@[simps]
def prod {F G : A ⥤ B} {H I : C ⥤ D} (α : F ⟶ G) (β : H ⟶ I) : F.prod H ⟶ G.prod I where
  app X := (α.app X.1, β.app X.2)
  naturality {X} {Y} f := by
    cases X; cases Y
    simp only [Functor.prod_map, prod_comp]
    rw [Prod.mk.inj_iff]
    constructor
    repeat {rw [naturality]}

/- Again, it is inadvisable in Lean 3 to setup a notation `α × β`;
   use instead `α.prod β` or `NatTrans.prod α β`. -/
end NatTrans

/-- The cartesian product functor between functor categories -/
@[simps]
def prodFunctor : (A ⥤ B) × (C ⥤ D) ⥤ A × C ⥤ B × D where
  obj FG := FG.1.prod FG.2
  map nm := NatTrans.prod nm.1 nm.2

namespace NatIso

/-- The cartesian product of two natural isomorphisms. -/
@[simps]
def prod {F F' : A ⥤ B} {G G' : C ⥤ D} (e₁ : F ≅ F') (e₂ : G ≅ G') :
    F.prod G ≅ F'.prod G' where
  hom := NatTrans.prod e₁.hom e₂.hom
  inv := NatTrans.prod e₁.inv e₂.inv

end NatIso

namespace Equivalence

/-- The cartesian product of two equivalences of categories. -/
@[simps]
def prod (E₁ : A ≌ B) (E₂ : C ≌ D) : A × C ≌ B × D where
  functor := E₁.functor.prod E₂.functor
  inverse := E₁.inverse.prod E₂.inverse
  unitIso := NatIso.prod E₁.unitIso E₂.unitIso
  counitIso := NatIso.prod E₁.counitIso E₂.counitIso

end Equivalence

/-- `F.flip` composed with evaluation is the same as evaluating `F`. -/
@[simps!]
def flipCompEvaluation (F : A ⥤ B ⥤ C) (a) : F.flip ⋙ (evaluation _ _).obj a ≅ F.obj a :=
  NatIso.ofComponents fun b => Iso.refl _

theorem flip_comp_evaluation (F : A ⥤ B ⥤ C) (a) : F.flip ⋙ (evaluation _ _).obj a = F.obj a :=
  rfl

/-- `F` composed with evaluation is the same as evaluating `F.flip`. -/
@[simps!]
def compEvaluation (F : A ⥤ B ⥤ C) (b) : F ⋙ (evaluation _ _).obj b ≅ F.flip.obj b :=
  NatIso.ofComponents fun a => Iso.refl _

theorem comp_evaluation (F : A ⥤ B ⥤ C) (b) : F ⋙ (evaluation _ _).obj b = F.flip.obj b :=
  rfl

/-- Whiskering by `F` and then evaluating at `a` is the same as evaluating at `F.obj a`. -/
@[simps!]
def whiskeringLeftCompEvaluation (F : A ⥤ B) (a : A) :
    (whiskeringLeft A B C).obj F ⋙ (evaluation A C).obj a ≅ (evaluation B C).obj (F.obj a) :=
  Iso.refl _

/-- Whiskering by `F` and then evaluating at `a` is the same as evaluating at `F.obj a`. -/
@[simp]
theorem whiskeringLeft_comp_evaluation (F : A ⥤ B) (a : A) :
    (whiskeringLeft A B C).obj F ⋙ (evaluation A C).obj a = (evaluation B C).obj (F.obj a) :=
  rfl

/-- Whiskering by `F` and then evaluating at `a` is the same as evaluating at `F` and then
applying `F`. -/
@[simps!]
def whiskeringRightCompEvaluation (F : B ⥤ C) (a : A) :
    (whiskeringRight A B C).obj F ⋙ (evaluation _ _).obj a ≅ (evaluation _ _).obj a ⋙ F :=
  Iso.refl _

/-- Whiskering by `F` and then evaluating at `a` is the same as evaluating at `F` and then
applying `F`. -/
@[simp]
theorem whiskeringRight_comp_evaluation (F : B ⥤ C) (a : A) :
    (whiskeringRight A B C).obj F ⋙ (evaluation _ _).obj a = (evaluation _ _).obj a ⋙ F :=
  rfl

variable (A B C)

/-- The forward direction for `functorProdFunctorEquiv` -/
@[simps]
def prodFunctorToFunctorProd : (A ⥤ B) × (A ⥤ C) ⥤ A ⥤ B × C where
  obj F := F.1.prod' F.2
  map f := { app := fun X => (f.1.app X, f.2.app X) }

/-- The backward direction for `functorProdFunctorEquiv` -/
@[simps]
def functorProdToProdFunctor : (A ⥤ B × C) ⥤ (A ⥤ B) × (A ⥤ C) where
  obj F := ⟨F ⋙ CategoryTheory.Prod.fst B C, F ⋙ CategoryTheory.Prod.snd B C⟩
  map α :=
    ⟨{  app := fun X => (α.app X).1
        naturality := fun X Y f => by
          simp only [Functor.comp_map, Prod.fst_map, ← prod_comp_fst, α.naturality] },
      { app := fun X => (α.app X).2
        naturality := fun X Y f => by
          simp only [Functor.comp_map, Prod.snd_map, ← prod_comp_snd, α.naturality] }⟩

/-- The unit isomorphism for `functorProdFunctorEquiv` -/
@[simps!]
def functorProdFunctorEquivUnitIso :
    𝟭 _ ≅ prodFunctorToFunctorProd A B C ⋙ functorProdToProdFunctor A B C :=
  NatIso.ofComponents fun F =>
    (((Functor.prod'CompFst F.fst F.snd).prod (Functor.prod'CompSnd F.fst F.snd)).trans
      (prod.etaIso F)).symm

/-- The counit isomorphism for `functorProdFunctorEquiv` -/
@[simps!]
def functorProdFunctorEquivCounitIso :
    functorProdToProdFunctor A B C ⋙ prodFunctorToFunctorProd A B C ≅ 𝟭 _ :=
  NatIso.ofComponents fun F => NatIso.ofComponents fun X => prod.etaIso (F.obj X)

/-- The equivalence of categories between `(A ⥤ B) × (A ⥤ C)` and `A ⥤ (B × C)` -/
@[simps]
def functorProdFunctorEquiv : (A ⥤ B) × (A ⥤ C) ≌ A ⥤ B × C :=
  { functor := prodFunctorToFunctorProd A B C,
    inverse := functorProdToProdFunctor A B C,
    unitIso := functorProdFunctorEquivUnitIso A B C,
    counitIso := functorProdFunctorEquivCounitIso A B C, }

section Opposite

open Opposite

/-- The equivalence between the opposite of a product and the product of the opposites. -/
@[simps]
def prodOpEquiv : (C × D)ᵒᵖ ≌ Cᵒᵖ × Dᵒᵖ where
  functor :=
    { obj := fun X ↦ ⟨op X.unop.1, op X.unop.2⟩,
      map := fun f ↦ ⟨f.unop.1.op, f.unop.2.op⟩ }
  inverse :=
    { obj := fun ⟨X,Y⟩ ↦ op ⟨X.unop, Y.unop⟩,
      map := fun ⟨f,g⟩ ↦ op ⟨f.unop, g.unop⟩ }
  unitIso := Iso.refl _
  counitIso := Iso.refl _
  functor_unitIso_comp := fun ⟨X, Y⟩ => by
    dsimp
    ext <;> apply Category.id_comp

end Opposite

end CategoryTheory
