import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2024 Christian Merten. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Christian Merten
-/
import Mathlib.CategoryTheory.MorphismProperty.Limits
import Mathlib.CategoryTheory.Sites.Pretopology

/-!
# The site induced by a morphism property

Let `C` be a category with pullbacks and `P` be a multiplicative morphism property which is
stable under base change. Then `P` induces a pretopology, where coverings are given by presieves
whose elements satisfy `P`.

Standard examples of pretopologies in algebraic geometry, such as the étale site, are obtained from
this construction by intersecting with the pretopology of surjective families.

-/

namespace CategoryTheory

open Limits

variable {C : Type*} [Category C] [HasPullbacks C]

namespace MorphismProperty

/-- If `P` is a multiplicative morphism property which is stable under base change on a category
`C` with pullbacks, then `P` induces a pretopology, where coverings are given by presieves whose
elements satisfy `P`. -/
def pretopology (P : MorphismProperty C) [P.IsMultiplicative] (hPb : P.StableUnderBaseChange) :
    Pretopology C where
  coverings X S := ∀ {Y : C} {f : Y ⟶ X}, S f → P f
  has_isos X Y f h Z g hg := by
    cases hg
    haveI : P.RespectsIso := hPb.respectsIso
    exact P.of_isIso f
  pullbacks X Y f S hS Z g hg := by
    obtain ⟨Z, g, hg⟩ := hg
    apply hPb.snd g f (hS hg)
  transitive X S Ti hS hTi Y f hf := by
    obtain ⟨Z, g, h, H, H', rfl⟩ := hf
    exact comp_mem _ _ _ (hTi h H H') (hS H)

/-- To a morphism property `P` satisfying the conditions of `MorphismProperty.pretopology`, we
associate the Grothendieck topology generated by `P.pretopology`. -/
abbrev grothendieckTopology (P : MorphismProperty C) [P.IsMultiplicative]
    (hPb : P.StableUnderBaseChange) : GrothendieckTopology C :=
  (P.pretopology hPb).toGrothendieck

variable {P Q : MorphismProperty C}
  [P.IsMultiplicative] (hPb : P.StableUnderBaseChange)
  [Q.IsMultiplicative] (hQb : Q.StableUnderBaseChange)

lemma pretopology_le (hPQ : P ≤ Q) : P.pretopology hPb ≤ Q.pretopology hQb :=
  fun _ _ hS _ f hf ↦ hPQ f (hS hf)

variable (P Q) in
lemma pretopology_inf :
    (P ⊓ Q).pretopology (hPb.inf hQb) = P.pretopology hPb ⊓ Q.pretopology hQb := by
  ext X S
  exact ⟨fun hS ↦ ⟨fun hf ↦ (hS hf).left, fun hf ↦ (hS hf).right⟩,
    fun h ↦ fun hf ↦ ⟨h.left hf, h.right hf⟩⟩

end CategoryTheory.MorphismProperty
