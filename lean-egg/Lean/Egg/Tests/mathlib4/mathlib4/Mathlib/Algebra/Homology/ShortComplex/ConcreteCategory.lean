import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2023 Joël Riou. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joël Riou
-/
import Mathlib.Algebra.Homology.ShortComplex.Ab
import Mathlib.Algebra.Homology.ShortComplex.ExactFunctor
import Mathlib.Algebra.Homology.ShortComplex.SnakeLemma
import Mathlib.CategoryTheory.Limits.Shapes.ConcreteCategory

/-!
# Exactness of short complexes in concrete abelian categories

If an additive concrete category `C` has an additive forgetful functor to `Ab`
which preserves homology, then a short complex `S` in `C` is exact
if and only if it is so after applying the functor `forget₂ C Ab`.

-/

universe w v u

namespace CategoryTheory

open Limits

section

variable {C : Type u} [Category.{v} C] [ConcreteCategory.{w} C] [HasForget₂ C Ab]

@[simp]
lemma ShortComplex.zero_apply
    [Limits.HasZeroMorphisms C] [(forget₂ C Ab).PreservesZeroMorphisms]
    (S : ShortComplex C) (x : (forget₂ C Ab).obj S.X₁) :
    ((forget₂ C Ab).map S.g) (((forget₂ C Ab).map S.f) x) = 0 := by
  rw [← comp_apply, ← Functor.map_comp, S.zero, Functor.map_zero]
  rfl

section preadditive

variable [Preadditive C] [(forget₂ C Ab).Additive] [(forget₂ C Ab).PreservesHomology]
  (S : ShortComplex C)

section
variable [HasZeroObject C]

lemma Preadditive.mono_iff_injective {X Y : C} (f : X ⟶ Y) :
    Mono f ↔ Function.Injective ((forget₂ C Ab).map f) := by
  rw [← AddCommGrp.mono_iff_injective]
  constructor
  · intro
    infer_instance
  · apply Functor.mono_of_mono_map

lemma Preadditive.mono_iff_injective' {X Y : C} (f : X ⟶ Y) :
    Mono f ↔ Function.Injective ((forget C).map f) := by
  simp only [mono_iff_injective, ← CategoryTheory.mono_iff_injective]
  apply (MorphismProperty.monomorphisms (Type w)).arrow_mk_iso_iff
  have e : forget₂ C Ab ⋙ forget Ab ≅ forget C := eqToIso (HasForget₂.forget_comp)
  exact Arrow.isoOfNatIso e (Arrow.mk f)

lemma Preadditive.epi_iff_surjective {X Y : C} (f : X ⟶ Y) :
    Epi f ↔ Function.Surjective ((forget₂ C Ab).map f) := by
  rw [← AddCommGrp.epi_iff_surjective]
  constructor
  · intro
    infer_instance
  · apply Functor.epi_of_epi_map

lemma Preadditive.epi_iff_surjective' {X Y : C} (f : X ⟶ Y) :
    Epi f ↔ Function.Surjective ((forget C).map f) := by
  simp only [epi_iff_surjective, ← CategoryTheory.epi_iff_surjective]
  apply (MorphismProperty.epimorphisms (Type w)).arrow_mk_iso_iff
  have e : forget₂ C Ab ⋙ forget Ab ≅ forget C := eqToIso (HasForget₂.forget_comp)
  exact Arrow.isoOfNatIso e (Arrow.mk f)

end

namespace ShortComplex

lemma exact_iff_exact_map_forget₂ [S.HasHomology] :
    S.Exact ↔ (S.map (forget₂ C Ab)).Exact :=
  (S.exact_map_iff_of_faithful (forget₂ C Ab)).symm

lemma exact_iff_of_concreteCategory [S.HasHomology] :
    S.Exact ↔ ∀ (x₂ : (forget₂ C Ab).obj S.X₂) (_ : ((forget₂ C Ab).map S.g) x₂ = 0),
      ∃ (x₁ : (forget₂ C Ab).obj S.X₁), ((forget₂ C Ab).map S.f) x₁ = x₂ := by
  rw [S.exact_iff_exact_map_forget₂, ab_exact_iff]
  rfl

variable {S}

lemma ShortExact.injective_f [HasZeroObject C] (hS : S.ShortExact) :
    Function.Injective ((forget₂ C Ab).map S.f) := by
  rw [← Preadditive.mono_iff_injective]
  exact hS.mono_f

lemma ShortExact.surjective_g [HasZeroObject C] (hS : S.ShortExact) :
    Function.Surjective ((forget₂ C Ab).map S.g) := by
  rw [← Preadditive.epi_iff_surjective]
  exact hS.epi_g

variable (S)

/-- Constructor for cycles of short complexes in a concrete category. -/
noncomputable def cyclesMk [S.HasHomology] (x₂ : (forget₂ C Ab).obj S.X₂)
    (hx₂ : ((forget₂ C Ab).map S.g) x₂ = 0) :
    (forget₂ C Ab).obj S.cycles :=
  (S.mapCyclesIso (forget₂ C Ab)).hom ((ShortComplex.abCyclesIso _).inv ⟨x₂, hx₂⟩)

@[simp]
lemma i_cyclesMk [S.HasHomology] (x₂ : (forget₂ C Ab).obj S.X₂)
    (hx₂ : ((forget₂ C Ab).map S.g) x₂ = 0) :
    (forget₂ C Ab).map S.iCycles (S.cyclesMk x₂ hx₂) = x₂ := by
  dsimp [cyclesMk]
  erw [← comp_apply, S.mapCyclesIso_hom_iCycles (forget₂ C Ab),
    ← comp_apply, abCyclesIso_inv_apply_iCycles ]

end ShortComplex

end preadditive

end

section abelian

variable {C : Type u} [Category.{v} C] [ConcreteCategory.{v} C] [HasForget₂ C Ab]
  [Abelian C] [(forget₂ C Ab).Additive] [(forget₂ C Ab).PreservesHomology]

attribute [local instance] ConcreteCategory.instFunLike ConcreteCategory.hasCoeToSort

namespace ShortComplex

namespace SnakeInput

variable (D : SnakeInput C)

/-- This lemma allows the computation of the connecting homomorphism
`D.δ` when `D : SnakeInput C` and `C` is a concrete category. -/
lemma δ_apply (x₃ : D.L₀.X₃) (x₂ : D.L₁.X₂) (x₁ : D.L₂.X₁)
    (h₂ : D.L₁.g x₂ = D.v₀₁.τ₃ x₃) (h₁ : D.L₂.f x₁ = D.v₁₂.τ₂ x₂) :
    D.δ x₃ = D.v₂₃.τ₁ x₁ := by
  have := (forget₂ C Ab).preservesFiniteLimitsOfPreservesHomology
  have : PreservesFiniteLimits (forget C) := by
    have : forget₂ C Ab ⋙ forget Ab = forget C := HasForget₂.forget_comp
    simpa only [← this] using compPreservesFiniteLimits _ _
  have eq := congr_fun ((forget C).congr_map D.snd_δ)
    (Limits.Concrete.pullbackMk D.L₁.g D.v₀₁.τ₃ x₂ x₃ h₂)
  have eq₁ := Concrete.pullbackMk_fst D.L₁.g D.v₀₁.τ₃ x₂ x₃ h₂
  have eq₂ := Concrete.pullbackMk_snd D.L₁.g D.v₀₁.τ₃ x₂ x₃ h₂
  dsimp [DFunLike.coe] at eq₁ eq₂
  rw [Functor.map_comp, types_comp_apply, FunctorToTypes.map_comp_apply] at eq
  rw [eq₂] at eq
  refine eq.trans (congr_arg ((forget C).map D.v₂₃.τ₁) ?_)
  apply (Preadditive.mono_iff_injective' D.L₂.f).1 inferInstance
  rw [← FunctorToTypes.map_comp_apply, φ₁_L₂_f]
  dsimp [φ₂]
  rw [Functor.map_comp, types_comp_apply, eq₁]
  exact h₁.symm

/-- This lemma allows the computation of the connecting homomorphism
`D.δ` when `D : SnakeInput C` and `C` is a concrete category. -/
lemma δ_apply' (x₃ : (forget₂ C Ab).obj D.L₀.X₃)
    (x₂ : (forget₂ C Ab).obj D.L₁.X₂) (x₁ : (forget₂ C Ab).obj D.L₂.X₁)
    (h₂ : (forget₂ C Ab).map D.L₁.g x₂ = (forget₂ C Ab).map D.v₀₁.τ₃ x₃)
    (h₁ : (forget₂ C Ab).map D.L₂.f x₁ = (forget₂ C Ab).map D.v₁₂.τ₂ x₂) :
    (forget₂ C Ab).map D.δ x₃ = (forget₂ C Ab).map D.v₂₃.τ₁ x₁ := by
  have e : forget₂ C Ab ⋙ forget Ab ≅ forget C := eqToIso (HasForget₂.forget_comp)
  apply (mono_iff_injective (e.hom.app _)).1 inferInstance
  refine (congr_hom (e.hom.naturality D.δ) x₃).trans
    ((D.δ_apply (e.hom.app _ x₃) (e.hom.app _ x₂) (e.hom.app _ x₁) ?_ ?_ ).trans
    (congr_hom (e.hom.naturality D.v₂₃.τ₁).symm x₁))
  · refine ((congr_hom (e.hom.naturality D.L₁.g) x₂).symm.trans ?_).trans
      (congr_hom (e.hom.naturality D.v₀₁.τ₃) x₃)
    dsimp
    rw [comp_apply, comp_apply]
    erw [h₂]
    rfl
  · refine ((congr_hom (e.hom.naturality D.L₂.f) x₁).symm.trans ?_).trans
      (congr_hom (e.hom.naturality D.v₁₂.τ₂) x₂)
    dsimp
    rw [comp_apply, comp_apply]
    erw [h₁]
    rfl

end SnakeInput

end ShortComplex

end abelian

end CategoryTheory
