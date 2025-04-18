import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2020 Kim Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kim Morrison
-/
import Mathlib.Algebra.Algebra.Subalgebra.Basic
import Mathlib.Algebra.FreeAlgebra
import Mathlib.Algebra.Category.Ring.Basic
import Mathlib.Algebra.Category.ModuleCat.Basic

/-!
# Category instance for algebras over a commutative ring

We introduce the bundled category `AlgebraCat` of algebras over a fixed commutative ring `R` along
with the forgetful functors to `RingCat` and `ModuleCat`. We furthermore show that the functor
associating to a type the free `R`-algebra on that type is left adjoint to the forgetful functor.
-/


open CategoryTheory Limits

universe v u

variable (R : Type u) [CommRing R]

/-- The category of R-algebras and their morphisms. -/
structure AlgebraCat where
  carrier : Type v
  [isRing : Ring carrier]
  [isAlgebra : Algebra R carrier]

-- Porting note: typemax hack to fix universe complaints
/-- An alias for `AlgebraCat.{max u₁ u₂}`, to deal around unification issues.
Since the universe the ring lives in can be inferred, we put that last. -/
@[nolint checkUnivs]
abbrev AlgebraCatMax.{v₁, v₂, u₁} (R : Type u₁) [CommRing R] := AlgebraCat.{max v₁ v₂} R

attribute [instance] AlgebraCat.isRing AlgebraCat.isAlgebra

initialize_simps_projections AlgebraCat (-isRing, -isAlgebra)

namespace AlgebraCat

instance : CoeSort (AlgebraCat R) (Type v) :=
  ⟨AlgebraCat.carrier⟩

attribute [coe] AlgebraCat.carrier

instance : Category (AlgebraCat.{v} R) where
  Hom A B := A →ₐ[R] B
  id A := AlgHom.id R A
  comp f g := g.comp f

instance {M N : AlgebraCat.{v} R} : FunLike (M ⟶ N) M N :=
  AlgHom.funLike

instance {M N : AlgebraCat.{v} R} : AlgHomClass (M ⟶ N) R M N :=
  AlgHom.algHomClass

instance : ConcreteCategory.{v} (AlgebraCat.{v} R) where
  forget :=
    { obj := fun R => R
      map := fun f => f.toFun }
  forget_faithful := ⟨fun h => AlgHom.ext (by intros x; dsimp at h; rw [h])⟩

instance {S : AlgebraCat.{v} R} : Ring ((forget (AlgebraCat R)).obj S) :=
  (inferInstance : Ring S.carrier)

instance {S : AlgebraCat.{v} R} : Algebra R ((forget (AlgebraCat R)).obj S) :=
  (inferInstance : Algebra R S.carrier)

instance hasForgetToRing : HasForget₂ (AlgebraCat.{v} R) RingCat.{v} where
  forget₂ :=
    { obj := fun A => RingCat.of A
      map := fun f => RingCat.ofHom f.toRingHom }

instance hasForgetToModule : HasForget₂ (AlgebraCat.{v} R) (ModuleCat.{v} R) where
  forget₂ :=
    { obj := fun M => ModuleCat.of R M
      map := fun f => ModuleCat.asHom f.toLinearMap }

@[simp]
lemma forget₂_module_obj (X : AlgebraCat.{v} R) :
    (forget₂ (AlgebraCat.{v} R) (ModuleCat.{v} R)).obj X = ModuleCat.of R X :=
  rfl

@[simp]
lemma forget₂_module_map {X Y : AlgebraCat.{v} R} (f : X ⟶ Y) :
    (forget₂ (AlgebraCat.{v} R) (ModuleCat.{v} R)).map f = ModuleCat.asHom f.toLinearMap :=
  rfl

/-- The object in the category of R-algebras associated to a type equipped with the appropriate
typeclasses. -/
def of (X : Type v) [Ring X] [Algebra R X] : AlgebraCat.{v} R :=
  ⟨X⟩

/-- Typecheck a `AlgHom` as a morphism in `AlgebraCat R`. -/
def ofHom {R : Type u} [CommRing R] {X Y : Type v} [Ring X] [Algebra R X] [Ring Y] [Algebra R Y]
    (f : X →ₐ[R] Y) : of R X ⟶ of R Y :=
  f

@[simp]
theorem ofHom_apply {R : Type u} [CommRing R] {X Y : Type v} [Ring X] [Algebra R X] [Ring Y]
    [Algebra R Y] (f : X →ₐ[R] Y) (x : X) : ofHom f x = f x :=
  rfl

instance : Inhabited (AlgebraCat R) :=
  ⟨of R R⟩

@[simp]
theorem coe_of (X : Type u) [Ring X] [Algebra R X] : (of R X : Type u) = X :=
  rfl

variable {R}

/-- Forgetting to the underlying type and then building the bundled object returns the original
algebra. -/
@[simps]
def ofSelfIso (M : AlgebraCat.{v} R) : AlgebraCat.of R M ≅ M where
  hom := 𝟙 M
  inv := 𝟙 M

variable {M N U : ModuleCat.{v} R}

@[simp]
theorem id_apply (m : M) : (𝟙 M : M → M) m = m :=
  rfl

@[simp]
theorem coe_comp (f : M ⟶ N) (g : N ⟶ U) : (f ≫ g : M → U) = g ∘ f :=
  rfl

variable (R)

/-- The "free algebra" functor, sending a type `S` to the free algebra on `S`. -/
@[simps!]
def free : Type u ⥤ AlgebraCat.{u} R where
  obj S :=
    { carrier := FreeAlgebra R S
      isRing := Algebra.semiringToRing R }
  map f := FreeAlgebra.lift _ <| FreeAlgebra.ι _ ∘ f
  -- Porting note (#11041): `apply FreeAlgebra.hom_ext` was `ext1`.
  map_id := by intro X; apply FreeAlgebra.hom_ext; simp only [FreeAlgebra.ι_comp_lift]; rfl
  map_comp := by
  -- Porting note (#11041): `apply FreeAlgebra.hom_ext` was `ext1`.
    intros; apply FreeAlgebra.hom_ext; simp only [FreeAlgebra.ι_comp_lift]; ext1
    -- Porting node: this ↓ `erw` used to be handled by the `simp` below it
    erw [CategoryTheory.coe_comp]
    simp only [CategoryTheory.coe_comp, Function.comp_apply, types_comp_apply]
    -- Porting node: this ↓ `erw` and `rfl` used to be handled by the `simp` above
    erw [FreeAlgebra.lift_ι_apply, FreeAlgebra.lift_ι_apply]
    rfl

/-- The free/forget adjunction for `R`-algebras. -/
def adj : free.{u} R ⊣ forget (AlgebraCat.{u} R) :=
  Adjunction.mkOfHomEquiv
    { homEquiv := fun _ _ => (FreeAlgebra.lift _).symm
      -- Relying on `obviously` to fill out these proofs is very slow :(
      homEquiv_naturality_left_symm := by
        -- Porting note (#11041): `apply FreeAlgebra.hom_ext` was `ext1`.
        intros; apply FreeAlgebra.hom_ext; simp only [FreeAlgebra.ι_comp_lift]; ext1
        simp only [free_map, Equiv.symm_symm, FreeAlgebra.lift_ι_apply, CategoryTheory.coe_comp,
          Function.comp_apply, types_comp_apply]
        -- Porting node: this ↓ `erw` and `rfl` used to be handled by the `simp` above
        erw [FreeAlgebra.lift_ι_apply, CategoryTheory.comp_apply, FreeAlgebra.lift_ι_apply,
          Function.comp_apply, FreeAlgebra.lift_ι_apply]
        rfl
      homEquiv_naturality_right := by
        intros; ext
        simp only [CategoryTheory.coe_comp, Function.comp_apply,
          FreeAlgebra.lift_symm_apply, types_comp_apply]
        -- Porting note: proof used to be done after this ↑ `simp`; added ↓ two lines
        erw [FreeAlgebra.lift_symm_apply, FreeAlgebra.lift_symm_apply]
        rfl }

instance : (forget (AlgebraCat.{u} R)).IsRightAdjoint := (adj R).isRightAdjoint

end AlgebraCat

variable {R}
variable {X₁ X₂ : Type u}

/-- Build an isomorphism in the category `AlgebraCat R` from a `AlgEquiv` between `Algebra`s. -/
@[simps]
def AlgEquiv.toAlgebraIso {g₁ : Ring X₁} {g₂ : Ring X₂} {m₁ : Algebra R X₁} {m₂ : Algebra R X₂}
    (e : X₁ ≃ₐ[R] X₂) : AlgebraCat.of R X₁ ≅ AlgebraCat.of R X₂ where
  hom := (e : X₁ →ₐ[R] X₂)
  inv := (e.symm : X₂ →ₐ[R] X₁)
  hom_inv_id := by ext x; exact e.left_inv x
  inv_hom_id := by ext x; exact e.right_inv x

namespace CategoryTheory.Iso

/-- Build a `AlgEquiv` from an isomorphism in the category `AlgebraCat R`. -/
@[simps]
def toAlgEquiv {X Y : AlgebraCat R} (i : X ≅ Y) : X ≃ₐ[R] Y :=
  { i.hom with
    toFun := i.hom
    invFun := i.inv
    left_inv := fun x => by
      -- Porting note: was `by tidy`
      change (i.hom ≫ i.inv) x = x
      simp only [hom_inv_id]
      -- This used to be `rw`, but we need `erw` after leanprover/lean4#2644
      erw [id_apply]
    right_inv := fun x => by
      -- Porting note: was `by tidy`
      change (i.inv ≫ i.hom) x = x
      simp only [inv_hom_id]
      -- This used to be `rw`, but we need `erw` after leanprover/lean4#2644
      erw [id_apply] }

end CategoryTheory.Iso

/-- Algebra equivalences between `Algebra`s are the same as (isomorphic to) isomorphisms in
`AlgebraCat`. -/
@[simps]
def algEquivIsoAlgebraIso {X Y : Type u} [Ring X] [Ring Y] [Algebra R X] [Algebra R Y] :
    (X ≃ₐ[R] Y) ≅ AlgebraCat.of R X ≅ AlgebraCat.of R Y where
  hom e := e.toAlgebraIso
  inv i := i.toAlgEquiv

instance AlgebraCat.forget_reflects_isos : (forget (AlgebraCat.{u} R)).ReflectsIsomorphisms where
  reflects {X Y} f _ := by
    let i := asIso ((forget (AlgebraCat.{u} R)).map f)
    let e : X ≃ₐ[R] Y := { f, i.toEquiv with }
    exact e.toAlgebraIso.isIso_hom

/-!
`@[simp]` lemmas for `AlgHom.comp` and categorical identities.
-/

@[simp] theorem AlgHom.comp_id_algebraCat
    {R} [CommRing R] {G : AlgebraCat.{u} R} {H : Type u} [Ring H] [Algebra R H] (f : G →ₐ[R] H) :
    f.comp (𝟙 G) = f :=
  Category.id_comp (AlgebraCat.ofHom f)
@[simp] theorem AlgHom.id_algebraCat_comp
    {R} [CommRing R] {G : Type u} [Ring G] [Algebra R G] {H : AlgebraCat.{u} R} (f : G →ₐ[R] H) :
    AlgHom.comp (𝟙 H) f = f :=
  Category.comp_id (AlgebraCat.ofHom f)
