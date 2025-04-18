import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin
-/
import Mathlib.RingTheory.KrullDimension.Basic
import Mathlib.Topology.KrullDimension
import Mathlib.Topology.Sober
import Mathlib.RingTheory.Ideal.MinimalPrime
import Mathlib.RingTheory.Ideal.Over
import Mathlib.RingTheory.Localization.Away.Basic
import Mathlib.RingTheory.LocalRing.ResidueField.Defs
import Mathlib.RingTheory.LocalRing.RingHom.Basic

/-!
# The Zariski topology on the prime spectrum of a commutative (semi)ring

## Conventions

We denote subsets of (semi)rings with `s`, `s'`, etc...
whereas we denote subsets of prime spectra with `t`, `t'`, etc...

## Inspiration/contributors

The contents of this file draw inspiration from <https://github.com/ramonfmir/lean-scheme>
which has contributions from Ramon Fernandez Mir, Kevin Buzzard, Kenny Lau,
and Chris Hughes (on an earlier repository).
-/


noncomputable section

universe u v

variable (R : Type u) (S : Type v)

namespace PrimeSpectrum

section CommSemiRing

variable [CommSemiring R] [CommSemiring S]
variable {R S}

/-- The Zariski topology on the prime spectrum of a commutative (semi)ring is defined
via the closed sets of the topology: they are exactly those sets that are the zero locus
of a subset of the ring. -/
instance zariskiTopology : TopologicalSpace (PrimeSpectrum R) :=
  TopologicalSpace.ofClosed (Set.range PrimeSpectrum.zeroLocus) ⟨Set.univ, by simp⟩
    (by
      intro Zs h
      rw [Set.sInter_eq_iInter]
      choose f hf using fun i : Zs => h i.prop
      simp only [← hf]
      exact ⟨_, zeroLocus_iUnion _⟩)
    (by
      rintro _ ⟨s, rfl⟩ _ ⟨t, rfl⟩
      exact ⟨_, (union_zeroLocus s t).symm⟩)

theorem isOpen_iff (U : Set (PrimeSpectrum R)) : IsOpen U ↔ ∃ s, Uᶜ = zeroLocus s := by
  simp only [@eq_comm _ Uᶜ]; rfl

theorem isClosed_iff_zeroLocus (Z : Set (PrimeSpectrum R)) : IsClosed Z ↔ ∃ s, Z = zeroLocus s := by
  rw [← isOpen_compl_iff, isOpen_iff, compl_compl]

theorem isClosed_iff_zeroLocus_ideal (Z : Set (PrimeSpectrum R)) :
    IsClosed Z ↔ ∃ I : Ideal R, Z = zeroLocus I :=
  (isClosed_iff_zeroLocus _).trans
    ⟨fun ⟨s, hs⟩ => ⟨_, (zeroLocus_span s).substr hs⟩, fun ⟨I, hI⟩ => ⟨I, hI⟩⟩

theorem isClosed_iff_zeroLocus_radical_ideal (Z : Set (PrimeSpectrum R)) :
    IsClosed Z ↔ ∃ I : Ideal R, I.IsRadical ∧ Z = zeroLocus I :=
  (isClosed_iff_zeroLocus_ideal _).trans
    ⟨fun ⟨I, hI⟩ => ⟨_, I.radical_isRadical, (zeroLocus_radical I).substr hI⟩, fun ⟨I, _, hI⟩ =>
      ⟨I, hI⟩⟩

theorem isClosed_zeroLocus (s : Set R) : IsClosed (zeroLocus s) := by
  rw [isClosed_iff_zeroLocus]
  exact ⟨s, rfl⟩

theorem zeroLocus_vanishingIdeal_eq_closure (t : Set (PrimeSpectrum R)) :
    zeroLocus (vanishingIdeal t : Set R) = closure t := by
  rcases isClosed_iff_zeroLocus (closure t) |>.mp isClosed_closure with ⟨I, hI⟩
  rw [subset_antisymm_iff, (isClosed_zeroLocus _).closure_subset_iff, hI,
      subset_zeroLocus_iff_subset_vanishingIdeal, (gc R).u_l_u_eq_u,
      ← subset_zeroLocus_iff_subset_vanishingIdeal, ← hI]
  exact ⟨subset_closure, subset_zeroLocus_vanishingIdeal t⟩

theorem vanishingIdeal_closure (t : Set (PrimeSpectrum R)) :
    vanishingIdeal (closure t) = vanishingIdeal t :=
  zeroLocus_vanishingIdeal_eq_closure t ▸ (gc R).u_l_u_eq_u t

theorem closure_singleton (x) : closure ({x} : Set (PrimeSpectrum R)) = zeroLocus x.asIdeal := by
  rw [← zeroLocus_vanishingIdeal_eq_closure, vanishingIdeal_singleton]

theorem isClosed_singleton_iff_isMaximal (x : PrimeSpectrum R) :
    IsClosed ({x} : Set (PrimeSpectrum R)) ↔ x.asIdeal.IsMaximal := by
  rw [← closure_subset_iff_isClosed, ← zeroLocus_vanishingIdeal_eq_closure,
      vanishingIdeal_singleton]
  constructor <;> intro H
  · rcases x.asIdeal.exists_le_maximal x.2.1 with ⟨m, hm, hxm⟩
    exact (congr_arg asIdeal (@H ⟨m, hm.isPrime⟩ hxm)) ▸ hm
  · exact fun p hp ↦ PrimeSpectrum.ext (H.eq_of_le p.2.1 hp).symm

theorem isRadical_vanishingIdeal (s : Set (PrimeSpectrum R)) : (vanishingIdeal s).IsRadical := by
  rw [← vanishingIdeal_closure, ← zeroLocus_vanishingIdeal_eq_closure,
    vanishingIdeal_zeroLocus_eq_radical]
  apply Ideal.radical_isRadical

theorem zeroLocus_eq_iff {I J : Ideal R} :
    zeroLocus (I : Set R) = zeroLocus J ↔ I.radical = J.radical := by
  constructor
  · intro h; simp_rw [← vanishingIdeal_zeroLocus_eq_radical, h]
  · intro h; rw [← zeroLocus_radical, h, zeroLocus_radical]

theorem vanishingIdeal_anti_mono_iff {s t : Set (PrimeSpectrum R)} (ht : IsClosed t) :
    s ⊆ t ↔ vanishingIdeal t ≤ vanishingIdeal s :=
  ⟨vanishingIdeal_anti_mono, fun h => by
    rw [← ht.closure_subset_iff, ← ht.closure_eq]
    convert ← zeroLocus_anti_mono_ideal h <;> apply zeroLocus_vanishingIdeal_eq_closure⟩

theorem vanishingIdeal_strict_anti_mono_iff {s t : Set (PrimeSpectrum R)} (hs : IsClosed s)
    (ht : IsClosed t) : s ⊂ t ↔ vanishingIdeal t < vanishingIdeal s := by
  rw [Set.ssubset_def, vanishingIdeal_anti_mono_iff hs, vanishingIdeal_anti_mono_iff ht,
    lt_iff_le_not_le]

/-- The antitone order embedding of closed subsets of `Spec R` into ideals of `R`. -/
def closedsEmbedding (R : Type*) [CommSemiring R] :
    (TopologicalSpace.Closeds <| PrimeSpectrum R)ᵒᵈ ↪o Ideal R :=
  OrderEmbedding.ofMapLEIff (fun s => vanishingIdeal ↑(OrderDual.ofDual s)) fun s _ =>
    (vanishingIdeal_anti_mono_iff s.2).symm

theorem t1Space_iff_isField [IsDomain R] : T1Space (PrimeSpectrum R) ↔ IsField R := by
  refine ⟨?_, fun h => ?_⟩
  · intro h
    have hbot : Ideal.IsPrime (⊥ : Ideal R) := Ideal.bot_prime
    exact
      Classical.not_not.1
        (mt
          (Ring.ne_bot_of_isMaximal_of_not_isField <|
            (isClosed_singleton_iff_isMaximal _).1 (T1Space.t1 ⟨⊥, hbot⟩))
          (by aesop))
  · refine ⟨fun x => (isClosed_singleton_iff_isMaximal x).2 ?_⟩
    by_cases hx : x.asIdeal = ⊥
    · letI := h.toSemifield
      exact hx.symm ▸ Ideal.bot_isMaximal
    · exact absurd h (Ring.not_isField_iff_exists_prime.2 ⟨x.asIdeal, ⟨hx, x.2⟩⟩)

local notation "Z(" a ")" => zeroLocus (a : Set R)

theorem isIrreducible_zeroLocus_iff_of_radical (I : Ideal R) (hI : I.IsRadical) :
    IsIrreducible (zeroLocus (I : Set R)) ↔ I.IsPrime := by
  rw [Ideal.isPrime_iff, IsIrreducible]
  apply and_congr
  · rw [Set.nonempty_iff_ne_empty, Ne, zeroLocus_empty_iff_eq_top]
  · trans ∀ x y : Ideal R, Z(I) ⊆ Z(x) ∪ Z(y) → Z(I) ⊆ Z(x) ∨ Z(I) ⊆ Z(y)
    · simp_rw [isPreirreducible_iff_closed_union_closed, isClosed_iff_zeroLocus_ideal]
      constructor
      · rintro h x y
        exact h _ _ ⟨x, rfl⟩ ⟨y, rfl⟩
      · rintro h _ _ ⟨x, rfl⟩ ⟨y, rfl⟩
        exact h x y
    · simp_rw [← zeroLocus_inf, subset_zeroLocus_iff_le_vanishingIdeal,
        vanishingIdeal_zeroLocus_eq_radical, hI.radical]
      constructor
      · simp_rw [← SetLike.mem_coe, ← Set.singleton_subset_iff, ← Ideal.span_le, ←
          Ideal.span_singleton_mul_span_singleton]
        refine fun h x y h' => h _ _ ?_
        rw [← hI.radical_le_iff] at h' ⊢
        simpa only [Ideal.radical_inf, Ideal.radical_mul] using h'
      · simp_rw [or_iff_not_imp_left, SetLike.not_le_iff_exists]
        rintro h s t h' ⟨x, hx, hx'⟩ y hy
        exact h (h' ⟨Ideal.mul_mem_right _ _ hx, Ideal.mul_mem_left _ _ hy⟩) hx'

theorem isIrreducible_zeroLocus_iff (I : Ideal R) :
    IsIrreducible (zeroLocus (I : Set R)) ↔ I.radical.IsPrime :=
  zeroLocus_radical I ▸ isIrreducible_zeroLocus_iff_of_radical _ I.radical_isRadical

theorem isIrreducible_iff_vanishingIdeal_isPrime {s : Set (PrimeSpectrum R)} :
    IsIrreducible s ↔ (vanishingIdeal s).IsPrime := by
  rw [← isIrreducible_iff_closure, ← zeroLocus_vanishingIdeal_eq_closure,
    isIrreducible_zeroLocus_iff_of_radical _ (isRadical_vanishingIdeal s)]

lemma vanishingIdeal_isIrreducible :
    vanishingIdeal (R := R) '' {s | IsIrreducible s} = {P | P.IsPrime} :=
  Set.ext fun I ↦ ⟨fun ⟨_, hs, e⟩ ↦ e ▸ isIrreducible_iff_vanishingIdeal_isPrime.mp hs,
    fun h ↦ ⟨zeroLocus I, (isIrreducible_zeroLocus_iff_of_radical _ h.isRadical).mpr h,
      (vanishingIdeal_zeroLocus_eq_radical I).trans h.radical⟩⟩

lemma vanishingIdeal_isClosed_isIrreducible :
    vanishingIdeal (R := R) '' {s | IsClosed s ∧ IsIrreducible s} = {P | P.IsPrime} := by
  refine (subset_antisymm ?_ ?_).trans vanishingIdeal_isIrreducible
  · exact Set.image_subset _ fun _ ↦ And.right
  rintro _ ⟨s, hs, rfl⟩
  exact ⟨closure s, ⟨isClosed_closure, hs.closure⟩, vanishingIdeal_closure s⟩

instance irreducibleSpace [IsDomain R] : IrreducibleSpace (PrimeSpectrum R) := by
  rw [irreducibleSpace_def, Set.top_eq_univ, ← zeroLocus_bot, isIrreducible_zeroLocus_iff]
  simpa using Ideal.bot_prime

instance quasiSober : QuasiSober (PrimeSpectrum R) :=
  ⟨fun {S} h₁ h₂ =>
    ⟨⟨_, isIrreducible_iff_vanishingIdeal_isPrime.1 h₁⟩, by
      rw [IsGenericPoint, closure_singleton, zeroLocus_vanishingIdeal_eq_closure, h₂.closure_eq]⟩⟩

/-- The prime spectrum of a commutative (semi)ring is a compact topological space. -/
instance compactSpace : CompactSpace (PrimeSpectrum R) := by
  refine compactSpace_of_finite_subfamily_closed fun S S_closed S_empty ↦ ?_
  choose I hI using fun i ↦ (isClosed_iff_zeroLocus_ideal (S i)).mp (S_closed i)
  simp_rw [hI, ← zeroLocus_iSup, zeroLocus_empty_iff_eq_top, ← top_le_iff] at S_empty ⊢
  exact Ideal.isCompactElement_top.exists_finset_of_le_iSup _ _ S_empty

section Comap

variable {S' : Type*} [CommSemiring S']

/-- The continuous function between prime spectra of commutative (semi)rings induced by a ring
homomorphism. -/
def comap (f : R →+* S) : C(PrimeSpectrum S, PrimeSpectrum R) where
  toFun := f.specComap
  continuous_toFun := by
    simp only [continuous_iff_isClosed, isClosed_iff_zeroLocus]
    rintro _ ⟨s, rfl⟩
    exact ⟨_, preimage_specComap_zeroLocus_aux f s⟩

variable (f : R →+* S)

@[simp]
theorem comap_asIdeal (y : PrimeSpectrum S) : (comap f y).asIdeal = Ideal.comap f y.asIdeal :=
  rfl

@[simp]
theorem comap_id : comap (RingHom.id R) = ContinuousMap.id _ := by
  ext
  rfl

@[simp]
theorem comap_comp (f : R →+* S) (g : S →+* S') : comap (g.comp f) = (comap f).comp (comap g) :=
  rfl

theorem comap_comp_apply (f : R →+* S) (g : S →+* S') (x : PrimeSpectrum S') :
    PrimeSpectrum.comap (g.comp f) x = (PrimeSpectrum.comap f) (PrimeSpectrum.comap g x) :=
  rfl

@[simp]
theorem preimage_comap_zeroLocus (s : Set R) : comap f ⁻¹' zeroLocus s = zeroLocus (f '' s) :=
  preimage_specComap_zeroLocus_aux f s

theorem comap_injective_of_surjective (f : R →+* S) (hf : Function.Surjective f) :
    Function.Injective (comap f) := fun _ _ h => specComap_injective_of_surjective _ hf h

variable (S)

theorem localization_comap_isInducing [Algebra R S] (M : Submonoid R) [IsLocalization M S] :
    IsInducing (comap (algebraMap R S)) := by
  refine ⟨TopologicalSpace.ext_isClosed fun Z ↦ ?_⟩
  simp_rw [isClosed_induced_iff, isClosed_iff_zeroLocus, @eq_comm _ _ (zeroLocus _),
    exists_exists_eq_and, preimage_comap_zeroLocus]
  constructor
  · rintro ⟨s, rfl⟩
    refine ⟨(Ideal.span s).comap (algebraMap R S), ?_⟩
    rw [← zeroLocus_span, ← zeroLocus_span s, ← Ideal.map, IsLocalization.map_comap M S]
  · rintro ⟨s, rfl⟩
    exact ⟨_, rfl⟩

@[deprecated (since := "2024-10-28")]
alias localization_comap_inducing := localization_comap_isInducing

theorem localization_comap_injective [Algebra R S] (M : Submonoid R) [IsLocalization M S] :
    Function.Injective (comap (algebraMap R S)) :=
  fun _ _ h => localization_specComap_injective S M h

theorem localization_comap_isEmbedding [Algebra R S] (M : Submonoid R) [IsLocalization M S] :
    IsEmbedding (comap (algebraMap R S)) :=
  ⟨localization_comap_isInducing S M, localization_comap_injective S M⟩

@[deprecated (since := "2024-10-26")]
alias localization_comap_embedding := localization_comap_isEmbedding

theorem localization_comap_range [Algebra R S] (M : Submonoid R) [IsLocalization M S] :
    Set.range (comap (algebraMap R S)) = { p | Disjoint (M : Set R) p.asIdeal } :=
  localization_specComap_range ..

open Function RingHom

theorem comap_isInducing_of_surjective (hf : Surjective f) : IsInducing (comap f) where
  eq_induced := by
    simp only [TopologicalSpace.ext_iff, ← isClosed_compl_iff, isClosed_iff_zeroLocus,
      isClosed_induced_iff]
    refine fun s =>
      ⟨fun ⟨F, hF⟩ =>
        ⟨zeroLocus (f ⁻¹' F), ⟨f ⁻¹' F, rfl⟩, by
          rw [preimage_comap_zeroLocus, Function.Surjective.image_preimage hf, hF]⟩,
        ?_⟩
    rintro ⟨-, ⟨F, rfl⟩, hF⟩
    exact ⟨f '' F, hF.symm.trans (preimage_comap_zeroLocus f F)⟩

@[deprecated (since := "2024-10-28")]
alias comap_inducing_of_surjective := comap_isInducing_of_surjective


end Comap
end CommSemiRing

section SpecOfSurjective

/-! The comap of a surjective ring homomorphism is a closed embedding between the prime spectra. -/


open Function RingHom

variable [CommRing R] [CommRing S]
variable (f : R →+* S)
variable {R}

theorem comap_singleton_isClosed_of_surjective (f : R →+* S) (hf : Function.Surjective f)
    (x : PrimeSpectrum S) (hx : IsClosed ({x} : Set (PrimeSpectrum S))) :
    IsClosed ({comap f x} : Set (PrimeSpectrum R)) :=
  haveI : x.asIdeal.IsMaximal := (isClosed_singleton_iff_isMaximal x).1 hx
  (isClosed_singleton_iff_isMaximal _).2 (Ideal.comap_isMaximal_of_surjective f hf)

theorem comap_singleton_isClosed_of_isIntegral (f : R →+* S) (hf : f.IsIntegral)
    (x : PrimeSpectrum S) (hx : IsClosed ({x} : Set (PrimeSpectrum S))) :
    IsClosed ({comap f x} : Set (PrimeSpectrum R)) :=
  have := (isClosed_singleton_iff_isMaximal x).1 hx
  (isClosed_singleton_iff_isMaximal _).2
    (Ideal.isMaximal_comap_of_isIntegral_of_isMaximal' f hf x.asIdeal)

theorem image_comap_zeroLocus_eq_zeroLocus_comap (hf : Surjective f) (I : Ideal S) :
    comap f '' zeroLocus I = zeroLocus (I.comap f) :=
  image_specComap_zeroLocus_eq_zeroLocus_comap _ f hf I

theorem range_comap_of_surjective (hf : Surjective f) :
    Set.range (comap f) = zeroLocus (ker f) :=
  range_specComap_of_surjective _ f hf

theorem isClosed_range_comap_of_surjective (hf : Surjective f) :
    IsClosed (Set.range (comap f)) := by
  rw [range_comap_of_surjective _ f hf]
  exact isClosed_zeroLocus _

lemma isClosedEmbedding_comap_of_surjective (hf : Surjective f) : IsClosedEmbedding (comap f) where
  toIsInducing := comap_isInducing_of_surjective S f hf
  inj := comap_injective_of_surjective f hf
  isClosed_range := isClosed_range_comap_of_surjective S f hf

@[deprecated (since := "2024-10-20")]
alias closedEmbedding_comap_of_surjective := isClosedEmbedding_comap_of_surjective

end SpecOfSurjective

section SpecProd

variable {R S} [CommRing R] [CommRing S]

lemma primeSpectrumProd_symm_inl (x) :
    (primeSpectrumProd R S).symm (.inl x) = comap (RingHom.fst R S) x := by
  ext; simp [Ideal.prod]

lemma primeSpectrumProd_symm_inr (x) :
    (primeSpectrumProd R S).symm (.inr x) = comap (RingHom.snd R S) x := by
  ext; simp [Ideal.prod]

/-- The prime spectrum of `R × S` is homeomorphic
to the disjoint union of `PrimeSpectrum R` and `PrimeSpectrum S`. -/
noncomputable
def primeSpectrumProdHomeo :
    PrimeSpectrum (R × S) ≃ₜ PrimeSpectrum R ⊕ PrimeSpectrum S := by
  refine ((primeSpectrumProd R S).symm.toHomeomorphOfIsInducing ?_).symm
  refine (IsClosedEmbedding.of_continuous_injective_isClosedMap ?_
    (Equiv.injective _) ?_).isInducing
  · rw [continuous_sum_dom]
    simp only [Function.comp_def, primeSpectrumProd_symm_inl, primeSpectrumProd_symm_inr]
    exact ⟨(comap _).2, (comap _).2⟩
  · rw [isClosedMap_sum]
    constructor
    · simp_rw [primeSpectrumProd_symm_inl]
      refine (isClosedEmbedding_comap_of_surjective _ _ ?_).isClosedMap
      exact Prod.fst_surjective
    · simp_rw [primeSpectrumProd_symm_inr]
      refine (isClosedEmbedding_comap_of_surjective _ _ ?_).isClosedMap
      exact Prod.snd_surjective

end SpecProd

section CommSemiRing

variable [CommSemiring R] [CommSemiring S]
variable {R S}

section BasicOpen

/-- `basicOpen r` is the open subset containing all prime ideals not containing `r`. -/
def basicOpen (r : R) : TopologicalSpace.Opens (PrimeSpectrum R) where
  carrier := { x | r ∉ x.asIdeal }
  is_open' := ⟨{r}, Set.ext fun _ => Set.singleton_subset_iff.trans <| Classical.not_not.symm⟩

@[simp]
theorem mem_basicOpen (f : R) (x : PrimeSpectrum R) : x ∈ basicOpen f ↔ f ∉ x.asIdeal :=
  Iff.rfl

theorem isOpen_basicOpen {a : R} : IsOpen (basicOpen a : Set (PrimeSpectrum R)) :=
  (basicOpen a).isOpen

@[simp]
theorem basicOpen_eq_zeroLocus_compl (r : R) :
    (basicOpen r : Set (PrimeSpectrum R)) = (zeroLocus {r})ᶜ :=
  Set.ext fun x => by simp only [SetLike.mem_coe, mem_basicOpen, Set.mem_compl_iff, mem_zeroLocus,
    Set.singleton_subset_iff]

@[simp]
theorem basicOpen_one : basicOpen (1 : R) = ⊤ :=
  TopologicalSpace.Opens.ext <| by simp

@[simp]
theorem basicOpen_zero : basicOpen (0 : R) = ⊥ :=
  TopologicalSpace.Opens.ext <| by simp

theorem basicOpen_le_basicOpen_iff (f g : R) :
    basicOpen f ≤ basicOpen g ↔ f ∈ (Ideal.span ({g} : Set R)).radical := by
  rw [← SetLike.coe_subset_coe, basicOpen_eq_zeroLocus_compl, basicOpen_eq_zeroLocus_compl,
    Set.compl_subset_compl, zeroLocus_subset_zeroLocus_singleton_iff]

theorem basicOpen_mul (f g : R) : basicOpen (f * g) = basicOpen f ⊓ basicOpen g :=
  TopologicalSpace.Opens.ext <| by simp [zeroLocus_singleton_mul]

theorem basicOpen_mul_le_left (f g : R) : basicOpen (f * g) ≤ basicOpen f := by
  rw [basicOpen_mul f g]
  exact inf_le_left

theorem basicOpen_mul_le_right (f g : R) : basicOpen (f * g) ≤ basicOpen g := by
  rw [basicOpen_mul f g]
  exact inf_le_right

@[simp]
theorem basicOpen_pow (f : R) (n : ℕ) (hn : 0 < n) : basicOpen (f ^ n) = basicOpen f :=
  TopologicalSpace.Opens.ext <| by simpa using zeroLocus_singleton_pow f n hn

theorem isTopologicalBasis_basic_opens :
    TopologicalSpace.IsTopologicalBasis
      (Set.range fun r : R => (basicOpen r : Set (PrimeSpectrum R))) := by
  apply TopologicalSpace.isTopologicalBasis_of_isOpen_of_nhds
  · rintro _ ⟨r, rfl⟩
    exact isOpen_basicOpen
  · rintro p U hp ⟨s, hs⟩
    rw [← compl_compl U, Set.mem_compl_iff, ← hs, mem_zeroLocus, Set.not_subset] at hp
    obtain ⟨f, hfs, hfp⟩ := hp
    refine ⟨basicOpen f, ⟨f, rfl⟩, hfp, ?_⟩
    rw [← Set.compl_subset_compl, ← hs, basicOpen_eq_zeroLocus_compl, compl_compl]
    exact zeroLocus_anti_mono (Set.singleton_subset_iff.mpr hfs)

theorem isBasis_basic_opens : TopologicalSpace.Opens.IsBasis (Set.range (@basicOpen R _)) := by
  unfold TopologicalSpace.Opens.IsBasis
  convert isTopologicalBasis_basic_opens (R := R)
  rw [← Set.range_comp]
  rfl

@[simp]
theorem basicOpen_eq_bot_iff (f : R) : basicOpen f = ⊥ ↔ IsNilpotent f := by
  rw [← TopologicalSpace.Opens.coe_inj, basicOpen_eq_zeroLocus_compl]
  simp only [Set.eq_univ_iff_forall, Set.singleton_subset_iff, TopologicalSpace.Opens.coe_bot,
    nilpotent_iff_mem_prime, Set.compl_empty_iff, mem_zeroLocus, SetLike.mem_coe]
  exact ⟨fun h I hI => h ⟨I, hI⟩, fun h ⟨I, hI⟩ => h I hI⟩

theorem localization_away_comap_range (S : Type v) [CommSemiring S] [Algebra R S] (r : R)
    [IsLocalization.Away r S] : Set.range (comap (algebraMap R S)) = basicOpen r := by
  rw [localization_comap_range S (Submonoid.powers r)]
  ext x
  simp only [mem_zeroLocus, basicOpen_eq_zeroLocus_compl, SetLike.mem_coe, Set.mem_setOf_eq,
    Set.singleton_subset_iff, Set.mem_compl_iff, disjoint_iff_inf_le]
  constructor
  · intro h₁ h₂
    exact h₁ ⟨Submonoid.mem_powers r, h₂⟩
  · rintro h₁ _ ⟨⟨n, rfl⟩, h₃⟩
    exact h₁ (x.2.mem_of_pow_mem _ h₃)

theorem localization_away_isOpenEmbedding (S : Type v) [CommSemiring S] [Algebra R S] (r : R)
    [IsLocalization.Away r S] : IsOpenEmbedding (comap (algebraMap R S)) where
  toIsEmbedding := localization_comap_isEmbedding S (Submonoid.powers r)
  isOpen_range := by
    rw [localization_away_comap_range S r]
    exact isOpen_basicOpen

@[deprecated (since := "2024-10-18")]
alias localization_away_openEmbedding := localization_away_isOpenEmbedding

theorem isCompact_basicOpen (f : R) : IsCompact (basicOpen f : Set (PrimeSpectrum R)) := by
  rw [← localization_away_comap_range (Localization (Submonoid.powers f))]
  exact isCompact_range (map_continuous _)

lemma comap_basicOpen (f : R →+* S) (x : R) :
    TopologicalSpace.Opens.comap (comap f) (basicOpen x) = basicOpen (f x) :=
  rfl

open TopologicalSpace in
lemma iSup_basicOpen_eq_top_iff {ι : Type*} {f : ι → R} :
    (⨆ i : ι, PrimeSpectrum.basicOpen (f i)) = ⊤ ↔ Ideal.span (Set.range f) = ⊤ := by
  rw [SetLike.ext'_iff, Opens.coe_iSup]
  simp only [PrimeSpectrum.basicOpen_eq_zeroLocus_compl, Opens.coe_top, ← Set.compl_iInter,
    ← PrimeSpectrum.zeroLocus_iUnion]
  rw [← PrimeSpectrum.zeroLocus_empty_iff_eq_top, compl_involutive.eq_iff]
  simp only [Set.iUnion_singleton_eq_range,  Set.compl_univ, PrimeSpectrum.zeroLocus_span]

lemma iSup_basicOpen_eq_top_iff' {s : Set R} :
    (⨆ i ∈ s, PrimeSpectrum.basicOpen i) = ⊤ ↔ Ideal.span s = ⊤ := by
  conv_rhs => rw [← Subtype.range_val (s := s), ← iSup_basicOpen_eq_top_iff]
  simp

end BasicOpen

section Order

/-!
## The specialization order

We endow `PrimeSpectrum R` with a partial order, where `x ≤ y` if and only if `y ∈ closure {x}`.
-/

theorem le_iff_mem_closure (x y : PrimeSpectrum R) :
    x ≤ y ↔ y ∈ closure ({x} : Set (PrimeSpectrum R)) := by
  rw [← asIdeal_le_asIdeal, ← zeroLocus_vanishingIdeal_eq_closure, mem_zeroLocus,
    vanishingIdeal_singleton, SetLike.coe_subset_coe]

theorem le_iff_specializes (x y : PrimeSpectrum R) : x ≤ y ↔ x ⤳ y :=
  (le_iff_mem_closure x y).trans specializes_iff_mem_closure.symm

/-- `nhds` as an order embedding. -/
@[simps!]
def nhdsOrderEmbedding : PrimeSpectrum R ↪o Filter (PrimeSpectrum R) :=
  OrderEmbedding.ofMapLEIff nhds fun a b => (le_iff_specializes a b).symm

instance : T0Space (PrimeSpectrum R) :=
  ⟨nhdsOrderEmbedding.inj'⟩

end Order

/-- If `x` specializes to `y`, then there is a natural map from the localization of `y` to the
localization of `x`. -/
def localizationMapOfSpecializes {x y : PrimeSpectrum R} (h : x ⤳ y) :
    Localization.AtPrime y.asIdeal →+* Localization.AtPrime x.asIdeal :=
  @IsLocalization.lift _ _ _ _ _ _ _ _ Localization.isLocalization
    (algebraMap R (Localization.AtPrime x.asIdeal))
    (by
      rintro ⟨a, ha⟩
      rw [← PrimeSpectrum.le_iff_specializes, ← asIdeal_le_asIdeal, ← SetLike.coe_subset_coe, ←
        Set.compl_subset_compl] at h
      exact (IsLocalization.map_units (Localization.AtPrime x.asIdeal)
        ⟨a, show a ∈ x.asIdeal.primeCompl from h ha⟩ : _))

variable (R) in
/--
Zero loci of prime ideals are closed irreducible sets in the Zariski topology and any closed
irreducible set is a zero locus of some prime ideal.
-/
protected def pointsEquivIrreducibleCloseds :
    PrimeSpectrum R ≃o (TopologicalSpace.IrreducibleCloseds (PrimeSpectrum R))ᵒᵈ where
  __ := irreducibleSetEquivPoints.toEquiv.symm.trans OrderDual.toDual
  map_rel_iff' {p q} :=
    (RelIso.symm irreducibleSetEquivPoints).map_rel_iff.trans (le_iff_specializes p q).symm

/-- Also see `PrimeSpectrum.isClosed_singleton_iff_isMaximal` -/
lemma isMax_iff {x : PrimeSpectrum R} :
    IsMax x ↔ x.asIdeal.IsMaximal := by
  refine ⟨fun hx ↦ ⟨⟨x.2.ne_top, fun I hI ↦ ?_⟩⟩, fun hx y e ↦ (hx.eq_of_le y.2.ne_top e).ge⟩
  by_contra e
  obtain ⟨m, hm, hm'⟩ := Ideal.exists_le_maximal I e
  exact hx.not_lt (show x < ⟨m, hm.isPrime⟩ from hI.trans_le hm')

lemma stableUnderSpecialization_singleton {x : PrimeSpectrum R} :
    StableUnderSpecialization {x} ↔ x.asIdeal.IsMaximal := by
  simp_rw [← isMax_iff, StableUnderSpecialization, ← le_iff_specializes, Set.mem_singleton_iff,
    @forall_comm _ (_ = _), forall_eq]
  exact ⟨fun H a h ↦ (H a h).le, fun H a h ↦ le_antisymm (H h) h⟩

lemma isMin_iff {x : PrimeSpectrum R} :
    IsMin x ↔ x.asIdeal ∈ minimalPrimes R := by
  show IsMin _ ↔ Minimal (fun q : Ideal R ↦ q.IsPrime ∧ ⊥ ≤ q) _
  simp only [IsMin, Minimal, x.2, bot_le, and_self, and_true, true_and]
  exact ⟨fun H y hy e ↦ @H ⟨y, hy⟩ e, fun H y e ↦ H y.2 e⟩

lemma stableUnderGeneralization_singleton {x : PrimeSpectrum R} :
    StableUnderGeneralization {x} ↔ x.asIdeal ∈ minimalPrimes R := by
  simp_rw [← isMin_iff, StableUnderGeneralization, ← le_iff_specializes, Set.mem_singleton_iff,
    @forall_comm _ (_ = _), forall_eq]
  exact ⟨fun H a h ↦ (H a h).ge, fun H a h ↦ le_antisymm h (H h)⟩

lemma isCompact_isOpen_iff {s : Set (PrimeSpectrum R)} :
    IsCompact s ∧ IsOpen s ↔ ∃ t : Finset R, (zeroLocus t)ᶜ = s := by
  rw [isCompact_open_iff_eq_finite_iUnion_of_isTopologicalBasis _
    isTopologicalBasis_basic_opens isCompact_basicOpen]
  simp only [basicOpen_eq_zeroLocus_compl, ← Set.compl_iInter₂, ← zeroLocus_iUnion₂,
    Set.biUnion_of_singleton]
  exact ⟨fun ⟨s, hs, e⟩ ↦ ⟨hs.toFinset, by simpa using e.symm⟩,
    fun ⟨s, e⟩ ↦ ⟨s, s.finite_toSet, by simpa using e.symm⟩⟩

lemma isCompact_isOpen_iff_ideal {s : Set (PrimeSpectrum R)} :
    IsCompact s ∧ IsOpen s ↔
      ∃ I : Ideal R, I.FG ∧ (PrimeSpectrum.zeroLocus (I : Set R))ᶜ = s := by
  rw [isCompact_isOpen_iff]
  exact ⟨fun ⟨s, e⟩ ↦ ⟨.span s, ⟨s, rfl⟩, by simpa using e⟩,
    fun ⟨I, ⟨s, hs⟩, e⟩ ↦ ⟨s, by simpa [hs.symm] using e⟩⟩

lemma exists_idempotent_basicOpen_eq_of_is_clopen {s : Set (PrimeSpectrum R)}
    (hs : IsClopen s) : ∃ e : R, IsIdempotentElem e ∧ s = basicOpen e := by
  cases subsingleton_or_nontrivial R
  · exact ⟨0, Subsingleton.elim _ _, Subsingleton.elim _ _⟩
  obtain ⟨I, hI, hI'⟩ := isCompact_isOpen_iff_ideal.mp ⟨hs.1.isCompact, hs.2⟩
  obtain ⟨J, hJ, hJ'⟩ := isCompact_isOpen_iff_ideal.mp
    ⟨hs.2.isClosed_compl.isCompact, hs.1.isOpen_compl⟩
  simp only [compl_eq_iff_isCompl, ← eq_compl_iff_isCompl, compl_compl] at hI' hJ'
  have : I * J ≤ nilradical R := by
    refine Ideal.radical_le_radical_iff.mp (le_of_eq ?_)
    rw [← zeroLocus_eq_iff, Ideal.zero_eq_bot, zeroLocus_bot,
      zeroLocus_mul, hI', hJ', Set.compl_union_self]
  obtain ⟨n, hn⟩ := Ideal.exists_pow_le_of_le_radical_of_fg this (Submodule.FG.mul hI hJ)
  have hnz : n ≠ 0 := by rintro rfl; simp at hn
  rw [mul_pow, Ideal.zero_eq_bot] at hn
  have : I ^ n ⊔ J ^ n = ⊤ := by
    rw [eq_top_iff, ← Ideal.span_pow_eq_top (I ∪ J : Set R) _ n, Ideal.span_le, Set.image_union,
      Set.union_subset_iff]
    constructor
    · rintro _ ⟨x, hx, rfl⟩; exact Ideal.mem_sup_left (Ideal.pow_mem_pow hx n)
    · rintro _ ⟨x, hx, rfl⟩; exact Ideal.mem_sup_right (Ideal.pow_mem_pow hx n)
    · rw [Ideal.span_union, Ideal.span_eq, Ideal.span_eq, ← zeroLocus_empty_iff_eq_top,
        zeroLocus_sup, hI', hJ', Set.compl_inter_self]
  rw [Ideal.eq_top_iff_one, Submodule.mem_sup] at this
  obtain ⟨x, hx, y, hy, e⟩ := this
  refine ⟨x, ?_, subset_antisymm ?_ ?_⟩
  · replace e := congr(x * $e)
    rwa [mul_add, hn (Ideal.mul_mem_mul hx hy), add_zero, mul_one] at e
  · rw [PrimeSpectrum.basicOpen_eq_zeroLocus_compl, Set.subset_compl_iff_disjoint_left,
      Set.disjoint_iff_inter_eq_empty, ← hJ', ← zeroLocus_span,
      ← zeroLocus_sup, zeroLocus_empty_iff_eq_top,
      Ideal.eq_top_iff_one, ← e]
    exact Submodule.add_mem_sup (Ideal.subset_span (Set.mem_singleton _)) (Ideal.pow_le_self hnz hy)
  · rw [PrimeSpectrum.basicOpen_eq_zeroLocus_compl, Set.compl_subset_comm, ← hI']
    exact PrimeSpectrum.zeroLocus_anti_mono
      (Set.singleton_subset_iff.mpr <| Ideal.pow_le_self hnz hx)

section LocalizationAtMinimal

variable {I : Ideal R} [hI : I.IsPrime]

/--
Localizations at minimal primes have single-point prime spectra.
-/
def primeSpectrum_unique_of_localization_at_minimal (h : I ∈ minimalPrimes R) :
    Unique (PrimeSpectrum (Localization.AtPrime I)) where
  default :=
    ⟨LocalRing.maximalIdeal (Localization I.primeCompl),
    (LocalRing.maximalIdeal.isMaximal _).isPrime⟩
  uniq x := PrimeSpectrum.ext (Localization.AtPrime.prime_unique_of_minimal h x.asIdeal)

end LocalizationAtMinimal

end CommSemiRing

end PrimeSpectrum

section CommSemiring
variable [CommSemiring R]

open PrimeSpectrum in
/--
[Stacks: Lemma 00ES (3)](https://stacks.math.columbia.edu/tag/00ES)
Zero loci of minimal prime ideals of `R` are irreducible components in `Spec R` and any
irreducible component is a zero locus of some minimal prime ideal.
-/
protected def minimalPrimes.equivIrreducibleComponents :
    minimalPrimes R ≃o (irreducibleComponents <| PrimeSpectrum R)ᵒᵈ := by
  let e : {p : Ideal R | p.IsPrime ∧ ⊥ ≤ p} ≃o PrimeSpectrum R :=
    ⟨⟨fun x ↦ ⟨x.1, x.2.1⟩, fun x ↦ ⟨x.1, x.2, bot_le⟩, fun _ ↦ rfl, fun _ ↦ rfl⟩, Iff.rfl⟩
  rw [irreducibleComponents_eq_maximals_closed]
  exact OrderIso.setOfMinimalIsoSetOfMaximal
    (e.trans ((PrimeSpectrum.pointsEquivIrreducibleCloseds R).trans
    (TopologicalSpace.IrreducibleCloseds.orderIsoSubtype' (PrimeSpectrum R)).dual))

namespace PrimeSpectrum

lemma vanishingIdeal_irreducibleComponents :
    vanishingIdeal '' (irreducibleComponents <| PrimeSpectrum R) =
    minimalPrimes R := by
  rw [irreducibleComponents_eq_maximals_closed, minimalPrimes_eq_minimals,
    image_antitone_setOf_maximal (fun s t hs _ ↦ (vanishingIdeal_anti_mono_iff hs.1).symm),
    ← funext (@Set.mem_setOf_eq _ · Ideal.IsPrime), ← vanishingIdeal_isClosed_isIrreducible]
  rfl

lemma zeroLocus_minimalPrimes :
    zeroLocus ∘ (↑) '' minimalPrimes R =
    irreducibleComponents (PrimeSpectrum R) := by
  rw [← vanishingIdeal_irreducibleComponents, ← Set.image_comp, Set.EqOn.image_eq_self]
  intros s hs
  simpa [zeroLocus_vanishingIdeal_eq_closure, closure_eq_iff_isClosed]
    using isClosed_of_mem_irreducibleComponents s hs

variable {R}

lemma vanishingIdeal_mem_minimalPrimes {s : Set (PrimeSpectrum R)} :
    vanishingIdeal s ∈ minimalPrimes R ↔ closure s ∈ irreducibleComponents (PrimeSpectrum R) := by
  constructor
  · rw [← zeroLocus_minimalPrimes, ← zeroLocus_vanishingIdeal_eq_closure]
    exact Set.mem_image_of_mem _
  · rw [← vanishingIdeal_irreducibleComponents, ← vanishingIdeal_closure]
    exact Set.mem_image_of_mem _

lemma zeroLocus_ideal_mem_irreducibleComponents {I : Ideal R} :
    zeroLocus I ∈ irreducibleComponents (PrimeSpectrum R) ↔ I.radical ∈ minimalPrimes R := by
  rw [← vanishingIdeal_zeroLocus_eq_radical]
  conv_lhs => rw [← (isClosed_zeroLocus _).closure_eq]
  exact vanishingIdeal_mem_minimalPrimes.symm

end PrimeSpectrum

end CommSemiring

namespace LocalRing

variable [CommSemiring R] [LocalRing R]

/-- The closed point in the prime spectrum of a local ring. -/
def closedPoint : PrimeSpectrum R :=
  ⟨maximalIdeal R, (maximalIdeal.isMaximal R).isPrime⟩

variable {R}

theorem isLocalHom_iff_comap_closedPoint {S : Type v} [CommSemiring S] [LocalRing S]
    (f : R →+* S) : IsLocalHom f ↔ PrimeSpectrum.comap f (closedPoint S) = closedPoint R := by
  -- Porting note: inline `this` does **not** work
  have := (local_hom_TFAE f).out 0 4
  rw [this, PrimeSpectrum.ext_iff]
  rfl

@[deprecated (since := "2024-10-10")]
alias isLocalRingHom_iff_comap_closedPoint := isLocalHom_iff_comap_closedPoint

@[simp]
theorem comap_closedPoint {S : Type v} [CommSemiring S] [LocalRing S] (f : R →+* S)
    [IsLocalHom f] : PrimeSpectrum.comap f (closedPoint S) = closedPoint R :=
  (isLocalHom_iff_comap_closedPoint f).mp inferInstance

theorem specializes_closedPoint (x : PrimeSpectrum R) : x ⤳ closedPoint R :=
  (PrimeSpectrum.le_iff_specializes _ _).mp (LocalRing.le_maximalIdeal x.2.1)

theorem closedPoint_mem_iff (U : TopologicalSpace.Opens <| PrimeSpectrum R) :
    closedPoint R ∈ U ↔ U = ⊤ := by
  constructor
  · rw [eq_top_iff]
    exact fun h x _ => (specializes_closedPoint x).mem_open U.2 h
  · rintro rfl
    trivial

lemma closed_point_mem_iff {U : TopologicalSpace.Opens (PrimeSpectrum R)} :
    closedPoint R ∈ U ↔ U = ⊤ :=
  ⟨(eq_top_iff.mpr fun x _ ↦ (specializes_closedPoint x).mem_open U.2 ·), (· ▸ trivial)⟩

@[simp]
theorem PrimeSpectrum.comap_residue (T : Type u) [CommRing T] [LocalRing T]
    (x : PrimeSpectrum (ResidueField T)) : PrimeSpectrum.comap (residue T) x = closedPoint T := by
  rw [Subsingleton.elim x ⊥]
  ext1
  exact Ideal.mk_ker

end LocalRing

section KrullDimension

theorem PrimeSpectrum.topologicalKrullDim_eq_ringKrullDim [CommRing R] :
    topologicalKrullDim (PrimeSpectrum R) = ringKrullDim R :=
  Order.krullDim_orderDual.symm.trans <| Order.krullDim_eq_of_orderIso
  (PrimeSpectrum.pointsEquivIrreducibleCloseds R).symm

end KrullDimension

section Idempotent

variable {R} [CommRing R]

lemma PrimeSpectrum.basicOpen_eq_zeroLocus_of_isIdempotentElem
    (e : R) (he : IsIdempotentElem e) :
    basicOpen e = zeroLocus {1 - e} := by
  ext p
  suffices e ∉ p.asIdeal ↔ 1 - e ∈ p.asIdeal by simpa
  constructor
  · refine (p.2.mem_or_mem_of_mul_eq_zero ?_).resolve_left
    rw [mul_sub, mul_one, he.eq, sub_self]
  · refine fun h₁ h₂ ↦ p.2.1 ?_
    rw [Ideal.eq_top_iff_one, ← sub_add_cancel 1 e]
    exact add_mem h₁ h₂

lemma PrimeSpectrum.zeroLocus_eq_basicOpen_of_isIdempotentElem
    (e : R) (he : IsIdempotentElem e) :
    zeroLocus {e} = basicOpen (1 - e) := by
  rw [basicOpen_eq_zeroLocus_of_isIdempotentElem _ he.one_sub, sub_sub_cancel]

lemma PrimeSpectrum.isClopen_iff {s : Set (PrimeSpectrum R)} :
    IsClopen s ↔ ∃ e : R, IsIdempotentElem e ∧ s = basicOpen e := by
  refine ⟨PrimeSpectrum.exists_idempotent_basicOpen_eq_of_is_clopen, ?_⟩
  rintro ⟨e, he, rfl⟩
  refine ⟨?_, (basicOpen e).2⟩
  rw [PrimeSpectrum.basicOpen_eq_zeroLocus_of_isIdempotentElem e he]
  exact isClosed_zeroLocus _

lemma PrimeSpectrum.isClopen_iff_zeroLocus {s : Set (PrimeSpectrum R)} :
    IsClopen s ↔ ∃ e : R, IsIdempotentElem e ∧ s = zeroLocus {e} := by
  rw [isClopen_iff]
  refine ⟨fun ⟨e, he, h⟩ ↦ ⟨1 - e, he.one_sub,
    h.trans (basicOpen_eq_zeroLocus_of_isIdempotentElem e he)⟩, fun ⟨e, he, h⟩ ↦
    ⟨1 - e, he.one_sub, h.trans (zeroLocus_eq_basicOpen_of_isIdempotentElem e he)⟩⟩

end Idempotent
