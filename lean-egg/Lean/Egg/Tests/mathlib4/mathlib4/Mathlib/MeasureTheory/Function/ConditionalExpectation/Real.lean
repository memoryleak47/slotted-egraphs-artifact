import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2022 Rémy Degenne. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rémy Degenne, Kexing Ying
-/
import Mathlib.MeasureTheory.Function.ConditionalExpectation.Indicator
import Mathlib.MeasureTheory.Function.UniformIntegrable
import Mathlib.MeasureTheory.Decomposition.RadonNikodym

/-!

# Conditional expectation of real-valued functions

This file proves some results regarding the conditional expectation of real-valued functions.

## Main results

* `MeasureTheory.rnDeriv_ae_eq_condexp`: the conditional expectation `μ[f | m]` is equal to the
  Radon-Nikodym derivative of `fμ` restricted on `m` with respect to `μ` restricted on `m`.
* `MeasureTheory.Integrable.uniformIntegrable_condexp`: the conditional expectation of a function
  form a uniformly integrable class.
* `MeasureTheory.condexp_stronglyMeasurable_mul`: the pull-out property of the conditional
  expectation.

-/


noncomputable section

open TopologicalSpace MeasureTheory.Lp Filter ContinuousLinearMap

open scoped NNReal ENNReal Topology MeasureTheory

namespace MeasureTheory

variable {α : Type*} {m m0 : MeasurableSpace α} {μ : Measure α}

theorem rnDeriv_ae_eq_condexp {hm : m ≤ m0} [hμm : SigmaFinite (μ.trim hm)] {f : α → ℝ}
    (hf : Integrable f μ) :
    SignedMeasure.rnDeriv ((μ.withDensityᵥ f).trim hm) (μ.trim hm) =ᵐ[μ] μ[f|m] := by
  refine ae_eq_condexp_of_forall_setIntegral_eq hm hf ?_ ?_ ?_
  · exact fun _ _ _ => (integrable_of_integrable_trim hm
      (SignedMeasure.integrable_rnDeriv ((μ.withDensityᵥ f).trim hm) (μ.trim hm))).integrableOn
  · intro s hs _
    conv_rhs => rw [← hf.withDensityᵥ_trim_eq_integral hm hs,
      ← SignedMeasure.withDensityᵥ_rnDeriv_eq ((μ.withDensityᵥ f).trim hm) (μ.trim hm)
        (hf.withDensityᵥ_trim_absolutelyContinuous hm)]
    rw [withDensityᵥ_apply
      (SignedMeasure.integrable_rnDeriv ((μ.withDensityᵥ f).trim hm) (μ.trim hm)) hs,
      ← setIntegral_trim hm _ hs]
    exact (SignedMeasure.measurable_rnDeriv _ _).stronglyMeasurable
  · exact (SignedMeasure.measurable_rnDeriv _ _).stronglyMeasurable.aeStronglyMeasurable'

-- TODO: the following couple of lemmas should be generalized and proved using Jensen's inequality
-- for the conditional expectation (not in mathlib yet) .
theorem eLpNorm_one_condexp_le_eLpNorm (f : α → ℝ) : eLpNorm (μ[f|m]) 1 μ ≤ eLpNorm f 1 μ := by
  by_cases hf : Integrable f μ
  swap; · rw [condexp_undef hf, eLpNorm_zero]; exact zero_le _
  by_cases hm : m ≤ m0
  swap; · rw [condexp_of_not_le hm, eLpNorm_zero]; exact zero_le _
  by_cases hsig : SigmaFinite (μ.trim hm)
  swap; · rw [condexp_of_not_sigmaFinite hm hsig, eLpNorm_zero]; exact zero_le _
  calc
    eLpNorm (μ[f|m]) 1 μ ≤ eLpNorm (μ[(|f|)|m]) 1 μ := by
      refine eLpNorm_mono_ae ?_
      filter_upwards [condexp_mono hf hf.abs
        (ae_of_all μ (fun x => le_abs_self (f x) : ∀ x, f x ≤ |f x|)),
        EventuallyLE.trans (condexp_neg f).symm.le
          (condexp_mono hf.neg hf.abs
          (ae_of_all μ (fun x => neg_le_abs (f x) : ∀ x, -f x ≤ |f x|)))] with x hx₁ hx₂
      exact abs_le_abs hx₁ hx₂
    _ = eLpNorm f 1 μ := by
      rw [eLpNorm_one_eq_lintegral_nnnorm, eLpNorm_one_eq_lintegral_nnnorm, ←
        ENNReal.toReal_eq_toReal (ne_of_lt integrable_condexp.2) (ne_of_lt hf.2), ←
        integral_norm_eq_lintegral_nnnorm
          (stronglyMeasurable_condexp.mono hm).aestronglyMeasurable,
        ← integral_norm_eq_lintegral_nnnorm hf.1]
      simp_rw [Real.norm_eq_abs]
      rw (config := {occs := .pos [2]}) [← integral_condexp hm]
      refine integral_congr_ae ?_
      have : 0 ≤ᵐ[μ] μ[(|f|)|m] := by
        rw [← condexp_zero]
        exact condexp_mono (integrable_zero _ _ _) hf.abs
          (ae_of_all μ (fun x => abs_nonneg (f x) : ∀ x, 0 ≤ |f x|))
      filter_upwards [this] with x hx
      exact abs_eq_self.2 hx

@[deprecated (since := "2024-07-27")]
alias snorm_one_condexp_le_snorm := eLpNorm_one_condexp_le_eLpNorm

theorem integral_abs_condexp_le (f : α → ℝ) : ∫ x, |(μ[f|m]) x| ∂μ ≤ ∫ x, |f x| ∂μ := by
  by_cases hm : m ≤ m0
  swap
  · simp_rw [condexp_of_not_le hm, Pi.zero_apply, abs_zero, integral_zero]
    positivity
  by_cases hfint : Integrable f μ
  swap
  · simp only [condexp_undef hfint, Pi.zero_apply, abs_zero, integral_const, Algebra.id.smul_eq_mul,
      mul_zero]
    positivity
  rw [integral_eq_lintegral_of_nonneg_ae, integral_eq_lintegral_of_nonneg_ae]
  · rw [ENNReal.toReal_le_toReal] <;> simp_rw [← Real.norm_eq_abs, ofReal_norm_eq_coe_nnnorm]
    · rw [← eLpNorm_one_eq_lintegral_nnnorm, ← eLpNorm_one_eq_lintegral_nnnorm]
      exact eLpNorm_one_condexp_le_eLpNorm _
    · exact integrable_condexp.2.ne
    · exact hfint.2.ne
  · filter_upwards with x using abs_nonneg _
  · simp_rw [← Real.norm_eq_abs]
    exact hfint.1.norm
  · filter_upwards with x using abs_nonneg _
  · simp_rw [← Real.norm_eq_abs]
    exact (stronglyMeasurable_condexp.mono hm).aestronglyMeasurable.norm

theorem setIntegral_abs_condexp_le {s : Set α} (hs : MeasurableSet[m] s) (f : α → ℝ) :
    ∫ x in s, |(μ[f|m]) x| ∂μ ≤ ∫ x in s, |f x| ∂μ := by
  by_cases hnm : m ≤ m0
  swap
  · simp_rw [condexp_of_not_le hnm, Pi.zero_apply, abs_zero, integral_zero]
    positivity
  by_cases hfint : Integrable f μ
  swap
  · simp only [condexp_undef hfint, Pi.zero_apply, abs_zero, integral_const, Algebra.id.smul_eq_mul,
      mul_zero]
    positivity
  have : ∫ x in s, |(μ[f|m]) x| ∂μ = ∫ x, |(μ[s.indicator f|m]) x| ∂μ := by
    rw [← integral_indicator (hnm _ hs)]
    refine integral_congr_ae ?_
    have : (fun x => |(μ[s.indicator f|m]) x|) =ᵐ[μ] fun x => |s.indicator (μ[f|m]) x| :=
      (condexp_indicator hfint hs).fun_comp abs
    refine EventuallyEq.trans (Eventually.of_forall fun x => ?_) this.symm
    rw [← Real.norm_eq_abs, norm_indicator_eq_indicator_norm]
    simp only [Real.norm_eq_abs]
  rw [this, ← integral_indicator (hnm _ hs)]
  refine (integral_abs_condexp_le _).trans
    (le_of_eq <| integral_congr_ae <| Eventually.of_forall fun x => ?_)
  simp_rw [← Real.norm_eq_abs, norm_indicator_eq_indicator_norm]

@[deprecated (since := "2024-04-17")]
alias set_integral_abs_condexp_le := setIntegral_abs_condexp_le

/-- If the real valued function `f` is bounded almost everywhere by `R`, then so is its conditional
expectation. -/
theorem ae_bdd_condexp_of_ae_bdd {R : ℝ≥0} {f : α → ℝ} (hbdd : ∀ᵐ x ∂μ, |f x| ≤ R) :
    ∀ᵐ x ∂μ, |(μ[f|m]) x| ≤ R := by
  by_cases hnm : m ≤ m0
  swap
  · simp_rw [condexp_of_not_le hnm, Pi.zero_apply, abs_zero]
    exact Eventually.of_forall fun _ => R.coe_nonneg
  by_cases hfint : Integrable f μ
  swap
  · simp_rw [condexp_undef hfint]
    filter_upwards [hbdd] with x hx
    rw [Pi.zero_apply, abs_zero]
    exact (abs_nonneg _).trans hx
  by_contra h
  change μ _ ≠ 0 at h
  simp only [← zero_lt_iff, Set.compl_def, Set.mem_setOf_eq, not_le] at h
  suffices (μ {x | ↑R < |(μ[f|m]) x|}).toReal * ↑R < (μ {x | ↑R < |(μ[f|m]) x|}).toReal * ↑R by
    exact this.ne rfl
  refine lt_of_lt_of_le (setIntegral_gt_gt R.coe_nonneg ?_ h.ne') ?_
  · exact integrable_condexp.abs.integrableOn
  refine (setIntegral_abs_condexp_le ?_ _).trans ?_
  · simp_rw [← Real.norm_eq_abs]
    exact @measurableSet_lt _ _ _ _ _ m _ _ _ _ _ measurable_const
      stronglyMeasurable_condexp.norm.measurable
  simp only [← smul_eq_mul, ← setIntegral_const, NNReal.val_eq_coe, RCLike.ofReal_real_eq_id,
    _root_.id]
  refine setIntegral_mono_ae hfint.abs.integrableOn ?_ hbdd
  refine ⟨aestronglyMeasurable_const, lt_of_le_of_lt ?_
    (integrable_condexp.integrableOn : IntegrableOn (μ[f|m]) {x | ↑R < |(μ[f|m]) x|} μ).2⟩
  refine setLIntegral_mono
    (stronglyMeasurable_condexp.mono hnm).measurable.nnnorm.coe_nnreal_ennreal fun x hx => ?_
  rw [ENNReal.coe_le_coe, Real.nnnorm_of_nonneg R.coe_nonneg]
  exact Subtype.mk_le_mk.2 (le_of_lt hx)

/-- Given an integrable function `g`, the conditional expectations of `g` with respect to
a sequence of sub-σ-algebras is uniformly integrable. -/
theorem Integrable.uniformIntegrable_condexp {ι : Type*} [IsFiniteMeasure μ] {g : α → ℝ}
    (hint : Integrable g μ) {ℱ : ι → MeasurableSpace α} (hℱ : ∀ i, ℱ i ≤ m0) :
    UniformIntegrable (fun i => μ[g|ℱ i]) 1 μ := by
  let A : MeasurableSpace α := m0
  have hmeas : ∀ n, ∀ C, MeasurableSet {x | C ≤ ‖(μ[g|ℱ n]) x‖₊} := fun n C =>
    measurableSet_le measurable_const (stronglyMeasurable_condexp.mono (hℱ n)).measurable.nnnorm
  have hg : Memℒp g 1 μ := memℒp_one_iff_integrable.2 hint
  refine uniformIntegrable_of le_rfl ENNReal.one_ne_top
    (fun n => (stronglyMeasurable_condexp.mono (hℱ n)).aestronglyMeasurable) fun ε hε => ?_
  by_cases hne : eLpNorm g 1 μ = 0
  · rw [eLpNorm_eq_zero_iff hg.1 one_ne_zero] at hne
    refine ⟨0, fun n => (le_of_eq <|
      (eLpNorm_eq_zero_iff ((stronglyMeasurable_condexp.mono (hℱ n)).aestronglyMeasurable.indicator
        (hmeas n 0)) one_ne_zero).2 ?_).trans (zero_le _)⟩
    filter_upwards [condexp_congr_ae (m := ℱ n) hne] with x hx
    simp only [zero_le', Set.setOf_true, Set.indicator_univ, Pi.zero_apply, hx, condexp_zero]
  obtain ⟨δ, hδ, h⟩ := hg.eLpNorm_indicator_le le_rfl ENNReal.one_ne_top hε
  set C : ℝ≥0 := ⟨δ, hδ.le⟩⁻¹ * (eLpNorm g 1 μ).toNNReal with hC
  have hCpos : 0 < C := mul_pos (inv_pos.2 hδ) (ENNReal.toNNReal_pos hne hg.eLpNorm_lt_top.ne)
  have : ∀ n, μ {x : α | C ≤ ‖(μ[g|ℱ n]) x‖₊} ≤ ENNReal.ofReal δ := by
    intro n
    have := mul_meas_ge_le_pow_eLpNorm' μ one_ne_zero ENNReal.one_ne_top
      ((stronglyMeasurable_condexp (m := ℱ n) (μ := μ) (f := g)).mono (hℱ n)).aestronglyMeasurable C
    rw [ENNReal.one_toReal, ENNReal.rpow_one, ENNReal.rpow_one, mul_comm, ←
      ENNReal.le_div_iff_mul_le (Or.inl (ENNReal.coe_ne_zero.2 hCpos.ne'))
        (Or.inl ENNReal.coe_lt_top.ne)] at this
    simp_rw [ENNReal.coe_le_coe] at this
    refine this.trans ?_
    rw [ENNReal.div_le_iff_le_mul (Or.inl (ENNReal.coe_ne_zero.2 hCpos.ne'))
        (Or.inl ENNReal.coe_lt_top.ne),
      hC, Nonneg.inv_mk, ENNReal.coe_mul, ENNReal.coe_toNNReal hg.eLpNorm_lt_top.ne, ← mul_assoc, ←
      ENNReal.ofReal_eq_coe_nnreal, ← ENNReal.ofReal_mul hδ.le, mul_inv_cancel₀ hδ.ne',
      ENNReal.ofReal_one, one_mul]
    exact eLpNorm_one_condexp_le_eLpNorm _
  refine ⟨C, fun n => le_trans ?_ (h {x : α | C ≤ ‖(μ[g|ℱ n]) x‖₊} (hmeas n C) (this n))⟩
  have hmeasℱ : MeasurableSet[ℱ n] {x : α | C ≤ ‖(μ[g|ℱ n]) x‖₊} :=
    @measurableSet_le _ _ _ _ _ (ℱ n) _ _ _ _ _ measurable_const
      (@Measurable.nnnorm _ _ _ _ _ (ℱ n) _ stronglyMeasurable_condexp.measurable)
  rw [← eLpNorm_congr_ae (condexp_indicator hint hmeasℱ)]
  exact eLpNorm_one_condexp_le_eLpNorm _

section PullOut

-- TODO: this section could be generalized beyond multiplication, to any bounded bilinear map.
/-- Auxiliary lemma for `condexp_stronglyMeasurable_mul`. -/
theorem condexp_stronglyMeasurable_simpleFunc_mul (hm : m ≤ m0) (f : @SimpleFunc α m ℝ) {g : α → ℝ}
    (hg : Integrable g μ) : μ[(f * g : α → ℝ)|m] =ᵐ[μ] f * μ[g|m] := by
  have : ∀ (s c) (f : α → ℝ), Set.indicator s (Function.const α c) * f = s.indicator (c • f) := by
    intro s c f
    ext1 x
    by_cases hx : x ∈ s
    · simp only [hx, Pi.mul_apply, Set.indicator_of_mem, Pi.smul_apply, Algebra.id.smul_eq_mul,
        Function.const_apply]
    · simp only [hx, Pi.mul_apply, Set.indicator_of_not_mem, not_false_iff, zero_mul]
  apply @SimpleFunc.induction _ _ m _ (fun f => _)
    (fun c s hs => ?_) (fun g₁ g₂ _ h_eq₁ h_eq₂ => ?_) f
  · -- Porting note: if not classical, `DecidablePred fun x ↦ x ∈ s` cannot be synthesised
    -- for `Set.piecewise_eq_indicator`
    classical simp only [@SimpleFunc.const_zero _ _ m, @SimpleFunc.coe_piecewise _ _ m,
      @SimpleFunc.coe_const _ _ m, @SimpleFunc.coe_zero _ _ m, Set.piecewise_eq_indicator]
    rw [this, this]
    refine (condexp_indicator (hg.smul c) hs).trans ?_
    filter_upwards [condexp_smul (m := m) (m0 := m0) c g] with x hx
    classical simp_rw [Set.indicator_apply, hx]
  · have h_add := @SimpleFunc.coe_add _ _ m _ g₁ g₂
    calc
      μ[⇑(g₁ + g₂) * g|m] =ᵐ[μ] μ[(⇑g₁ + ⇑g₂) * g|m] := by
        refine condexp_congr_ae (EventuallyEq.mul ?_ EventuallyEq.rfl); rw [h_add]
      _ =ᵐ[μ] μ[⇑g₁ * g|m] + μ[⇑g₂ * g|m] := by
        rw [add_mul]; exact condexp_add (hg.simpleFunc_mul' hm _) (hg.simpleFunc_mul' hm _)
      _ =ᵐ[μ] ⇑g₁ * μ[g|m] + ⇑g₂ * μ[g|m] := EventuallyEq.add h_eq₁ h_eq₂
      _ =ᵐ[μ] ⇑(g₁ + g₂) * μ[g|m] := by rw [h_add, add_mul]

theorem condexp_stronglyMeasurable_mul_of_bound (hm : m ≤ m0) [IsFiniteMeasure μ] {f g : α → ℝ}
    (hf : StronglyMeasurable[m] f) (hg : Integrable g μ) (c : ℝ) (hf_bound : ∀ᵐ x ∂μ, ‖f x‖ ≤ c) :
    μ[f * g|m] =ᵐ[μ] f * μ[g|m] := by
  let fs := hf.approxBounded c
  have hfs_tendsto : ∀ᵐ x ∂μ, Tendsto (fs · x) atTop (𝓝 (f x)) :=
    hf.tendsto_approxBounded_ae hf_bound
  by_cases hμ : μ = 0
  · simp only [hμ, ae_zero]; norm_cast
  have : (ae μ).NeBot := ae_neBot.2 hμ
  have hc : 0 ≤ c := by
    rcases hf_bound.exists with ⟨_x, hx⟩
    exact (norm_nonneg _).trans hx
  have hfs_bound : ∀ n x, ‖fs n x‖ ≤ c := hf.norm_approxBounded_le hc
  have : μ[f * μ[g|m]|m] = f * μ[g|m] := by
    refine condexp_of_stronglyMeasurable hm (hf.mul stronglyMeasurable_condexp) ?_
    exact integrable_condexp.bdd_mul' (hf.mono hm).aestronglyMeasurable hf_bound
  rw [← this]
  refine tendsto_condexp_unique (fun n x => fs n x * g x) (fun n x => fs n x * (μ[g|m]) x) (f * g)
    (f * μ[g|m]) ?_ ?_ ?_ ?_ (c * ‖g ·‖) ?_ (c * ‖(μ[g|m]) ·‖) ?_ ?_ ?_ ?_
  · exact fun n => hg.bdd_mul' ((SimpleFunc.stronglyMeasurable (fs n)).mono hm).aestronglyMeasurable
      (Eventually.of_forall (hfs_bound n))
  · exact fun n => integrable_condexp.bdd_mul'
      ((SimpleFunc.stronglyMeasurable (fs n)).mono hm).aestronglyMeasurable
      (Eventually.of_forall (hfs_bound n))
  · filter_upwards [hfs_tendsto] with x hx
    exact hx.mul tendsto_const_nhds
  · filter_upwards [hfs_tendsto] with x hx
    exact hx.mul tendsto_const_nhds
  · exact hg.norm.const_mul c
  · exact integrable_condexp.norm.const_mul c
  · refine fun n => Eventually.of_forall fun x => ?_
    exact (norm_mul_le _ _).trans (mul_le_mul_of_nonneg_right (hfs_bound n x) (norm_nonneg _))
  · refine fun n => Eventually.of_forall fun x => ?_
    exact (norm_mul_le _ _).trans (mul_le_mul_of_nonneg_right (hfs_bound n x) (norm_nonneg _))
  · intro n
    simp_rw [← Pi.mul_apply]
    refine (condexp_stronglyMeasurable_simpleFunc_mul hm _ hg).trans ?_
    rw [condexp_of_stronglyMeasurable hm
      ((SimpleFunc.stronglyMeasurable _).mul stronglyMeasurable_condexp) _]
    exact integrable_condexp.bdd_mul'
      ((SimpleFunc.stronglyMeasurable (fs n)).mono hm).aestronglyMeasurable
      (Eventually.of_forall (hfs_bound n))

theorem condexp_stronglyMeasurable_mul_of_bound₀ (hm : m ≤ m0) [IsFiniteMeasure μ] {f g : α → ℝ}
    (hf : AEStronglyMeasurable' m f μ) (hg : Integrable g μ) (c : ℝ)
    (hf_bound : ∀ᵐ x ∂μ, ‖f x‖ ≤ c) : μ[f * g|m] =ᵐ[μ] f * μ[g|m] := by
  have : μ[f * g|m] =ᵐ[μ] μ[hf.mk f * g|m] :=
    condexp_congr_ae (EventuallyEq.mul hf.ae_eq_mk EventuallyEq.rfl)
  refine this.trans ?_
  have : f * μ[g|m] =ᵐ[μ] hf.mk f * μ[g|m] := EventuallyEq.mul hf.ae_eq_mk EventuallyEq.rfl
  refine EventuallyEq.trans ?_ this.symm
  refine condexp_stronglyMeasurable_mul_of_bound hm hf.stronglyMeasurable_mk hg c ?_
  filter_upwards [hf_bound, hf.ae_eq_mk] with x hxc hx_eq
  rwa [← hx_eq]

/-- Pull-out property of the conditional expectation. -/
theorem condexp_stronglyMeasurable_mul {f g : α → ℝ} (hf : StronglyMeasurable[m] f)
    (hfg : Integrable (f * g) μ) (hg : Integrable g μ) : μ[f * g|m] =ᵐ[μ] f * μ[g|m] := by
  by_cases hm : m ≤ m0; swap; · simp_rw [condexp_of_not_le hm]; rw [mul_zero]
  by_cases hμm : SigmaFinite (μ.trim hm)
  swap; · simp_rw [condexp_of_not_sigmaFinite hm hμm]; rw [mul_zero]
  haveI : SigmaFinite (μ.trim hm) := hμm
  obtain ⟨sets, sets_prop, h_univ⟩ := hf.exists_spanning_measurableSet_norm_le hm μ
  simp_rw [forall_and] at sets_prop
  obtain ⟨h_meas, h_finite, h_norm⟩ := sets_prop
  suffices ∀ n, ∀ᵐ x ∂μ, x ∈ sets n → (μ[f * g|m]) x = f x * (μ[g|m]) x by
    rw [← ae_all_iff] at this
    filter_upwards [this] with x hx
    obtain ⟨i, hi⟩ : ∃ i, x ∈ sets i := by
      have h_mem : x ∈ ⋃ i, sets i := by rw [h_univ]; exact Set.mem_univ _
      simpa using h_mem
    exact hx i hi
  refine fun n => ae_imp_of_ae_restrict ?_
  suffices (μ.restrict (sets n))[f * g|m] =ᵐ[μ.restrict (sets n)] f * (μ.restrict (sets n))[g|m] by
    refine (condexp_restrict_ae_eq_restrict hm (h_meas n) hfg).symm.trans ?_
    exact this.trans (EventuallyEq.rfl.mul (condexp_restrict_ae_eq_restrict hm (h_meas n) hg))
  suffices (μ.restrict (sets n))[(sets n).indicator f * g|m] =ᵐ[μ.restrict (sets n)]
      (sets n).indicator f * (μ.restrict (sets n))[g|m] by
    refine EventuallyEq.trans ?_ (this.trans ?_)
    · exact
        condexp_congr_ae ((indicator_ae_eq_restrict <| hm _ <| h_meas n).symm.mul EventuallyEq.rfl)
    · exact (indicator_ae_eq_restrict <| hm _ <| h_meas n).mul EventuallyEq.rfl
  have : IsFiniteMeasure (μ.restrict (sets n)) := by
    constructor
    rw [Measure.restrict_apply_univ]
    exact h_finite n
  refine condexp_stronglyMeasurable_mul_of_bound hm (hf.indicator (h_meas n)) hg.integrableOn n ?_
  filter_upwards with x
  by_cases hxs : x ∈ sets n
  · simpa only [hxs, Set.indicator_of_mem] using h_norm n x hxs
  · simp only [hxs, Set.indicator_of_not_mem, not_false_iff, _root_.norm_zero, Nat.cast_nonneg]

/-- Pull-out property of the conditional expectation. -/
theorem condexp_stronglyMeasurable_mul₀ {f g : α → ℝ} (hf : AEStronglyMeasurable' m f μ)
    (hfg : Integrable (f * g) μ) (hg : Integrable g μ) : μ[f * g|m] =ᵐ[μ] f * μ[g|m] := by
  have : μ[f * g|m] =ᵐ[μ] μ[hf.mk f * g|m] :=
    condexp_congr_ae (hf.ae_eq_mk.mul EventuallyEq.rfl)
  refine this.trans ?_
  have : f * μ[g|m] =ᵐ[μ] hf.mk f * μ[g|m] := hf.ae_eq_mk.mul EventuallyEq.rfl
  refine (condexp_stronglyMeasurable_mul hf.stronglyMeasurable_mk ?_ hg).trans this.symm
  refine (integrable_congr ?_).mp hfg
  exact hf.ae_eq_mk.mul EventuallyEq.rfl

end PullOut

end MeasureTheory
