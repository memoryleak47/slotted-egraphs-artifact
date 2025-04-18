import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2022 Anatole Dedecker. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anatole Dedecker
-/
import Mathlib.Analysis.Convex.Topology

/-!
# Locally convex topological modules

A `LocallyConvexSpace` is a topological semimodule over an ordered semiring in which any point
admits a neighborhood basis made of convex sets, or equivalently, in which convex neighborhoods of
a point form a neighborhood basis at that point.

In a module, this is equivalent to `0` satisfying such properties.

## Main results

- `locallyConvexSpace_iff_zero` : in a module, local convexity at zero gives
  local convexity everywhere
- `WithSeminorms.locallyConvexSpace` : a topology generated by a family of seminorms is locally
  convex (in `Analysis.LocallyConvex.WithSeminorms`)
- `NormedSpace.locallyConvexSpace` : a normed space is locally convex
  (in `Analysis.LocallyConvex.WithSeminorms`)

## TODO

- define a structure `LocallyConvexFilterBasis`, extending `ModuleFilterBasis`, for filter
  bases generating a locally convex topology

-/


open TopologicalSpace Filter Set

open Topology Pointwise

section Semimodule

/-- A `LocallyConvexSpace` is a topological semimodule over an ordered semiring in which convex
neighborhoods of a point form a neighborhood basis at that point. -/
class LocallyConvexSpace (𝕜 E : Type*) [OrderedSemiring 𝕜] [AddCommMonoid E] [Module 𝕜 E]
    [TopologicalSpace E] : Prop where
  convex_basis : ∀ x : E, (𝓝 x).HasBasis (fun s : Set E => s ∈ 𝓝 x ∧ Convex 𝕜 s) id

variable (𝕜 E : Type*) [OrderedSemiring 𝕜] [AddCommMonoid E] [Module 𝕜 E] [TopologicalSpace E]

theorem locallyConvexSpace_iff :
    LocallyConvexSpace 𝕜 E ↔ ∀ x : E, (𝓝 x).HasBasis (fun s : Set E => s ∈ 𝓝 x ∧ Convex 𝕜 s) id :=
  ⟨@LocallyConvexSpace.convex_basis _ _ _ _ _ _, LocallyConvexSpace.mk⟩

theorem LocallyConvexSpace.ofBases {ι : Type*} (b : E → ι → Set E) (p : E → ι → Prop)
    (hbasis : ∀ x : E, (𝓝 x).HasBasis (p x) (b x)) (hconvex : ∀ x i, p x i → Convex 𝕜 (b x i)) :
    LocallyConvexSpace 𝕜 E :=
  ⟨fun x =>
    (hbasis x).to_hasBasis
      (fun i hi => ⟨b x i, ⟨⟨(hbasis x).mem_of_mem hi, hconvex x i hi⟩, le_refl (b x i)⟩⟩)
      fun s hs =>
      ⟨(hbasis x).index s hs.1, ⟨(hbasis x).property_index hs.1, (hbasis x).set_index_subset hs.1⟩⟩⟩

theorem LocallyConvexSpace.convex_basis_zero [LocallyConvexSpace 𝕜 E] :
    (𝓝 0 : Filter E).HasBasis (fun s => s ∈ (𝓝 0 : Filter E) ∧ Convex 𝕜 s) id :=
  LocallyConvexSpace.convex_basis 0

theorem locallyConvexSpace_iff_exists_convex_subset :
    LocallyConvexSpace 𝕜 E ↔ ∀ x : E, ∀ U ∈ 𝓝 x, ∃ S ∈ 𝓝 x, Convex 𝕜 S ∧ S ⊆ U :=
  (locallyConvexSpace_iff 𝕜 E).trans (forall_congr' fun _ => hasBasis_self)

end Semimodule

section Module

variable (𝕜 E : Type*) [OrderedSemiring 𝕜] [AddCommGroup E] [Module 𝕜 E] [TopologicalSpace E]
  [TopologicalAddGroup E]

theorem LocallyConvexSpace.ofBasisZero {ι : Type*} (b : ι → Set E) (p : ι → Prop)
    (hbasis : (𝓝 0).HasBasis p b) (hconvex : ∀ i, p i → Convex 𝕜 (b i)) :
    LocallyConvexSpace 𝕜 E := by
  refine LocallyConvexSpace.ofBases 𝕜 E (fun (x : E) (i : ι) => (x + ·) '' b i) (fun _ => p)
    (fun x => ?_) fun x i hi => (hconvex i hi).translate x
  rw [← map_add_left_nhds_zero]
  exact hbasis.map _

theorem locallyConvexSpace_iff_zero : LocallyConvexSpace 𝕜 E ↔
    (𝓝 0 : Filter E).HasBasis (fun s : Set E => s ∈ (𝓝 0 : Filter E) ∧ Convex 𝕜 s) id :=
  ⟨fun h => @LocallyConvexSpace.convex_basis _ _ _ _ _ _ h 0, fun h =>
    LocallyConvexSpace.ofBasisZero 𝕜 E _ _ h fun _ => And.right⟩

theorem locallyConvexSpace_iff_exists_convex_subset_zero :
    LocallyConvexSpace 𝕜 E ↔ ∀ U ∈ (𝓝 0 : Filter E), ∃ S ∈ (𝓝 0 : Filter E), Convex 𝕜 S ∧ S ⊆ U :=
  (locallyConvexSpace_iff_zero 𝕜 E).trans hasBasis_self

-- see Note [lower instance priority]
instance (priority := 100) LocallyConvexSpace.toLocallyConnectedSpace [Module ℝ E]
    [ContinuousSMul ℝ E] [LocallyConvexSpace ℝ E] : LocallyConnectedSpace E :=
  locallyConnectedSpace_of_connected_bases _ _
    (fun x => @LocallyConvexSpace.convex_basis ℝ _ _ _ _ _ _ x) fun _ _ hs => hs.2.isPreconnected

end Module

section LinearOrderedField

variable (𝕜 E : Type*) [LinearOrderedField 𝕜] [AddCommGroup E] [Module 𝕜 E] [TopologicalSpace E]
  [TopologicalAddGroup E] [ContinuousConstSMul 𝕜 E]

theorem LocallyConvexSpace.convex_open_basis_zero [LocallyConvexSpace 𝕜 E] :
    (𝓝 0 : Filter E).HasBasis (fun s => (0 : E) ∈ s ∧ IsOpen s ∧ Convex 𝕜 s) id :=
  (LocallyConvexSpace.convex_basis_zero 𝕜 E).to_hasBasis
    (fun s hs =>
      ⟨interior s, ⟨mem_interior_iff_mem_nhds.mpr hs.1, isOpen_interior, hs.2.interior⟩,
        interior_subset⟩)
    fun s hs => ⟨s, ⟨hs.2.1.mem_nhds hs.1, hs.2.2⟩, subset_rfl⟩

variable {𝕜 E}

/-- In a locally convex space, if `s`, `t` are disjoint convex sets, `s` is compact and `t` is
closed, then we can find open disjoint convex sets containing them. -/
theorem Disjoint.exists_open_convexes [LocallyConvexSpace 𝕜 E] {s t : Set E} (disj : Disjoint s t)
    (hs₁ : Convex 𝕜 s) (hs₂ : IsCompact s) (ht₁ : Convex 𝕜 t) (ht₂ : IsClosed t) :
    ∃ u v, IsOpen u ∧ IsOpen v ∧ Convex 𝕜 u ∧ Convex 𝕜 v ∧ s ⊆ u ∧ t ⊆ v ∧ Disjoint u v := by
  letI : UniformSpace E := TopologicalAddGroup.toUniformSpace E
  haveI : UniformAddGroup E := comm_topologicalAddGroup_is_uniform
  have := (LocallyConvexSpace.convex_open_basis_zero 𝕜 E).comap fun x : E × E => x.2 - x.1
  rw [← uniformity_eq_comap_nhds_zero] at this
  rcases disj.exists_uniform_thickening_of_basis this hs₂ ht₂ with ⟨V, ⟨hV0, hVopen, hVconvex⟩, hV⟩
  refine ⟨s + V, t + V, hVopen.add_left, hVopen.add_left, hs₁.add hVconvex, ht₁.add hVconvex,
    subset_add_left _ hV0, subset_add_left _ hV0, ?_⟩
  simp_rw [← iUnion_add_left_image, image_add_left]
  simp_rw [UniformSpace.ball, ← preimage_comp, sub_eq_neg_add] at hV
  exact hV

end LinearOrderedField

section LatticeOps

variable {ι : Sort*} {𝕜 E F : Type*} [OrderedSemiring 𝕜] [AddCommMonoid E] [Module 𝕜 E]
  [AddCommMonoid F] [Module 𝕜 F]

theorem locallyConvexSpace_sInf {ts : Set (TopologicalSpace E)}
    (h : ∀ t ∈ ts, @LocallyConvexSpace 𝕜 E _ _ _ t) : @LocallyConvexSpace 𝕜 E _ _ _ (sInf ts) := by
  letI : TopologicalSpace E := sInf ts
  refine
    LocallyConvexSpace.ofBases 𝕜 E (fun _ => fun If : Set ts × (ts → Set E) => ⋂ i ∈ If.1, If.2 i)
      (fun x => fun If : Set ts × (ts → Set E) =>
        If.1.Finite ∧ ∀ i ∈ If.1, If.2 i ∈ @nhds _ (↑i) x ∧ Convex 𝕜 (If.2 i))
      (fun x => ?_) fun x If hif => convex_iInter fun i => convex_iInter fun hi => (hif.2 i hi).2
  rw [nhds_sInf, ← iInf_subtype'']
  exact hasBasis_iInf' fun i : ts => (@locallyConvexSpace_iff 𝕜 E _ _ _ ↑i).mp (h (↑i) i.2) x

theorem locallyConvexSpace_iInf {ts' : ι → TopologicalSpace E}
    (h' : ∀ i, @LocallyConvexSpace 𝕜 E _ _ _ (ts' i)) :
    @LocallyConvexSpace 𝕜 E _ _ _ (⨅ i, ts' i) := by
  refine locallyConvexSpace_sInf ?_
  rwa [forall_mem_range]

theorem locallyConvexSpace_inf {t₁ t₂ : TopologicalSpace E} (h₁ : @LocallyConvexSpace 𝕜 E _ _ _ t₁)
    (h₂ : @LocallyConvexSpace 𝕜 E _ _ _ t₂) : @LocallyConvexSpace 𝕜 E _ _ _ (t₁ ⊓ t₂) := by
  rw [inf_eq_iInf]
  refine locallyConvexSpace_iInf fun b => ?_
  cases b <;> assumption

theorem locallyConvexSpace_induced {t : TopologicalSpace F} [LocallyConvexSpace 𝕜 F]
    (f : E →ₗ[𝕜] F) : @LocallyConvexSpace 𝕜 E _ _ _ (t.induced f) := by
  letI : TopologicalSpace E := t.induced f
  refine LocallyConvexSpace.ofBases 𝕜 E (fun _ => preimage f)
    (fun x => fun s : Set F => s ∈ 𝓝 (f x) ∧ Convex 𝕜 s) (fun x => ?_) fun x s ⟨_, hs⟩ =>
    hs.linear_preimage f
  rw [nhds_induced]
  exact (LocallyConvexSpace.convex_basis <| f x).comap f

instance Pi.locallyConvexSpace {ι : Type*} {X : ι → Type*} [∀ i, AddCommMonoid (X i)]
    [∀ i, TopologicalSpace (X i)] [∀ i, Module 𝕜 (X i)] [∀ i, LocallyConvexSpace 𝕜 (X i)] :
    LocallyConvexSpace 𝕜 (∀ i, X i) :=
  locallyConvexSpace_iInf fun i => locallyConvexSpace_induced (LinearMap.proj i)

instance Prod.locallyConvexSpace [TopologicalSpace E] [TopologicalSpace F] [LocallyConvexSpace 𝕜 E]
    [LocallyConvexSpace 𝕜 F] : LocallyConvexSpace 𝕜 (E × F) :=
-- Porting note: had to specify `t₁` and `t₂`
  locallyConvexSpace_inf (t₁ := induced Prod.fst _) (t₂ := induced Prod.snd _)
    (locallyConvexSpace_induced (LinearMap.fst _ _ _))
    (locallyConvexSpace_induced (LinearMap.snd _ _ _))

end LatticeOps
