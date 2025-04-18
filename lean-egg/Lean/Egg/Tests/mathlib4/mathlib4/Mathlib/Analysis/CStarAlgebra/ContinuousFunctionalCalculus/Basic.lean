import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2022 Jireh Loreaux. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jireh Loreaux
-/
import Mathlib.Analysis.CStarAlgebra.GelfandDuality
import Mathlib.Topology.Algebra.StarSubalgebra

/-! # Continuous functional calculus

In this file we construct the `continuousFunctionalCalculus` for a normal element `a` of a
(unital) C⋆-algebra over `ℂ`. This is a star algebra equivalence
`C(spectrum ℂ a, ℂ) ≃⋆ₐ[ℂ] elementalStarAlgebra ℂ a` which sends the (restriction of) the
identity map `ContinuousMap.id ℂ` to the (unique) preimage of `a` under the coercion of
`elementalStarAlgebra ℂ a` to `A`.

Being a star algebra equivalence between C⋆-algebras, this map is continuous (even an isometry),
and by the Stone-Weierstrass theorem it is the unique star algebra equivalence which extends the
polynomial functional calculus (i.e., `Polynomial.aeval`).

For any continuous function `f : spectrum ℂ a → ℂ`, this makes it possible to define an element
`f a` (not valid notation) in the original algebra, which heuristically has the same eigenspaces as
`a` and acts on eigenvector of `a` for an eigenvalue `λ` as multiplication by `f λ`. This
description is perfectly accurate in finite dimension, but only heuristic in infinite dimension as
there might be no genuine eigenvector. In particular, when `f` is a polynomial `∑ cᵢ Xⁱ`, then
`f a` is `∑ cᵢ aⁱ`. Also, `id a = a`.

The result we have established here is the strongest possible, but it is not the version which is
most useful in practice. The generic API for the continuous functional calculus can be found in
`Analysis.CStarAlgebra.ContinuousFunctionalCalculus` in the `Unital` and `NonUnital` files. The
relevant instances on C⋆-algebra can be found in the `Instances` file.

## Main definitions

* `continuousFunctionalCalculus : C(spectrum ℂ a, ℂ) ≃⋆ₐ[ℂ] elementalStarAlgebra ℂ a`: this
  is the composition of the inverse of the `gelfandStarTransform` with the natural isomorphism
  induced by the homeomorphism `elementalStarAlgebra.characterSpaceHomeo`.
* `elementalStarAlgebra.characterSpaceHomeo` :
  `characterSpace ℂ (elementalStarAlgebra ℂ a) ≃ₜ spectrum ℂ a`: this homeomorphism is defined
  by evaluating a character `φ` at `a`, and noting that `φ a ∈ spectrum ℂ a` since `φ` is an
  algebra homomorphism. Moreover, this map is continuous and bijective and since the spaces involved
  are compact Hausdorff, it is a homeomorphism.

 -/


open scoped Pointwise ENNReal NNReal ComplexOrder

open WeakDual WeakDual.CharacterSpace elementalStarAlgebra

variable {A : Type*} [CStarAlgebra A]

instance {R A : Type*} [CommRing R] [StarRing R] [NormedRing A] [Algebra R A] [StarRing A]
    [ContinuousStar A] [StarModule R A] (a : A) [IsStarNormal a] :
    NormedCommRing (elementalStarAlgebra R a) :=
  { SubringClass.toNormedRing (elementalStarAlgebra R a) with
    mul_comm := mul_comm }

noncomputable instance (a : A) [IsStarNormal a] : CommCStarAlgebra (elementalStarAlgebra ℂ a) where
  mul_comm := mul_comm

variable (a : A) [IsStarNormal a]

/-- The natural map from `characterSpace ℂ (elementalStarAlgebra ℂ x)` to `spectrum ℂ x` given
by evaluating `φ` at `x`. This is essentially just evaluation of the `gelfandTransform` of `x`,
but because we want something in `spectrum ℂ x`, as opposed to
`spectrum ℂ ⟨x, elementalStarAlgebra.self_mem ℂ x⟩` there is slightly more work to do. -/
@[simps]
noncomputable def elementalStarAlgebra.characterSpaceToSpectrum (x : A)
    (φ : characterSpace ℂ (elementalStarAlgebra ℂ x)) : spectrum ℂ x where
  val := φ ⟨x, self_mem ℂ x⟩
  property := by
    simpa only [StarSubalgebra.spectrum_eq (hS := elementalStarAlgebra.isClosed ℂ x)
      (a := ⟨x, self_mem ℂ x⟩)] using AlgHom.apply_mem_spectrum φ ⟨x, self_mem ℂ x⟩

#adaptation_note /-- nightly-2024-04-01
The simpNF linter now times out on this lemma.
See https://github.com/leanprover-community/mathlib4/issues/12227 -/
attribute [nolint simpNF] elementalStarAlgebra.characterSpaceToSpectrum_coe

theorem elementalStarAlgebra.continuous_characterSpaceToSpectrum (x : A) :
    Continuous (elementalStarAlgebra.characterSpaceToSpectrum x) :=
  continuous_induced_rng.2
    (map_continuous <| gelfandTransform ℂ (elementalStarAlgebra ℂ x) ⟨x, self_mem ℂ x⟩)

theorem elementalStarAlgebra.bijective_characterSpaceToSpectrum :
    Function.Bijective (elementalStarAlgebra.characterSpaceToSpectrum a) := by
  refine ⟨fun φ ψ h => starAlgHomClass_ext ℂ ?_ ?_ ?_, ?_⟩
  · exact (map_continuous φ)
  · exact (map_continuous ψ)
  · simpa only [elementalStarAlgebra.characterSpaceToSpectrum, Subtype.mk_eq_mk,
      ContinuousMap.coe_mk] using h
  · rintro ⟨z, hz⟩
    have hz' := (StarSubalgebra.spectrum_eq (hS := elementalStarAlgebra.isClosed ℂ a)
      (a := ⟨a, self_mem ℂ a⟩) ▸ hz)
    rw [CharacterSpace.mem_spectrum_iff_exists] at hz'
    obtain ⟨φ, rfl⟩ := hz'
    exact ⟨φ, rfl⟩

/-- The homeomorphism between the character space of the unital C⋆-subalgebra generated by a
single normal element `a : A` and `spectrum ℂ a`. -/
noncomputable def elementalStarAlgebra.characterSpaceHomeo :
    characterSpace ℂ (elementalStarAlgebra ℂ a) ≃ₜ spectrum ℂ a :=
  @Continuous.homeoOfEquivCompactToT2 _ _ _ _ _ _
    (Equiv.ofBijective (elementalStarAlgebra.characterSpaceToSpectrum a)
      (elementalStarAlgebra.bijective_characterSpaceToSpectrum a))
    (elementalStarAlgebra.continuous_characterSpaceToSpectrum a)

/-- **Continuous functional calculus.** Given a normal element `a : A` of a unital C⋆-algebra,
the continuous functional calculus is a `StarAlgEquiv` from the complex-valued continuous
functions on the spectrum of `a` to the unital C⋆-subalgebra generated by `a`. Moreover, this
equivalence identifies `(ContinuousMap.id ℂ).restrict (spectrum ℂ a))` with `a`; see
`continuousFunctionalCalculus_map_id`. As such it extends the polynomial functional calculus. -/
noncomputable def continuousFunctionalCalculus :
    C(spectrum ℂ a, ℂ) ≃⋆ₐ[ℂ] elementalStarAlgebra ℂ a :=
  ((elementalStarAlgebra.characterSpaceHomeo a).compStarAlgEquiv' ℂ ℂ).trans
    (gelfandStarTransform (elementalStarAlgebra ℂ a)).symm

theorem continuousFunctionalCalculus_map_id :
    continuousFunctionalCalculus a ((ContinuousMap.id ℂ).restrict (spectrum ℂ a)) =
      ⟨a, self_mem ℂ a⟩ :=
  (gelfandStarTransform (elementalStarAlgebra ℂ a)).symm_apply_apply _
