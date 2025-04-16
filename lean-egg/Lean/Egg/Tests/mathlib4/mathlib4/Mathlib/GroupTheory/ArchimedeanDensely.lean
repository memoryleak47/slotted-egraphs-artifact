import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2024 Yakov Pechersky. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yakov Pechersky
-/
import Mathlib.GroupTheory.Archimedean
import Mathlib.Algebra.Group.Equiv.TypeTags
import Mathlib.Algebra.Group.Subgroup.Pointwise
import Mathlib.Algebra.Order.Group.TypeTags
import Mathlib.Algebra.Order.Hom.Monoid

/-!
# Archimedean groups are either discrete or densely ordered

This file proves a few additional facts about linearly ordered additive groups which satisfy the
  `Archimedean` property --
  they are either order-isomorphic and additvely isomorphic to the integers,
  or they are densely ordered.

They are placed here in a separate file (rather than incorporated as a continuation of
`GroupTheory.Archimedean`) because they rely on some imports from pointwise lemmas.
-/

open Multiplicative Set

-- no earlier file imports the necessary requirements for the next two

/-- The subgroup generated by an element of a group equals the set of
integer powers of the element, such that each power is a unique element.
This is the stronger version of `Subgroup.mem_closure_singleton`. -/
@[to_additive "The additive subgroup generated by an element of an additive group equals the set of
integer multiples of the element, such that each multiple is a unique element.
This is the stronger version of `AddSubgroup.mem_closure_singleton`."]
lemma Subgroup.mem_closure_singleton_iff_existsUnique_zpow {G : Type*}
    [LinearOrderedCommGroup G] {a b : G} (ha : a ≠ 1) :
    b ∈ closure {a} ↔ ∃! k : ℤ, a ^ k = b := by
  rw [mem_closure_singleton]
  constructor
  · suffices Function.Injective (a ^ · : ℤ → G) by
      rintro ⟨m, rfl⟩
      exact ⟨m, rfl, fun k hk ↦ this hk⟩
    rcases ha.lt_or_lt with ha | ha
    · exact (zpow_right_strictAnti ha).injective
    · exact (zpow_right_strictMono ha).injective
  · exact fun h ↦ h.exists

open Subgroup in
/-- In two linearly ordered groups, the closure of an element of one group
is isomorphic (and order-isomorphic) to the closure of an element in the other group. -/
@[to_additive "In two linearly ordered additive groups, the closure of an element of one group
is isomorphic (and order-isomorphic) to the closure of an element in the other group."]
noncomputable def LinearOrderedCommGroup.closure_equiv_closure {G G' : Type*}
    [LinearOrderedCommGroup G] [LinearOrderedCommGroup G'] (x : G) (y : G') (hxy : x = 1 ↔ y = 1) :
    closure ({x} : Set G) ≃*o closure ({y} : Set G') :=
  if hx : x = 1 then by
    refine ⟨⟨⟨fun _ ↦ ⟨1, by simp [hxy.mp hx]⟩, fun _ ↦ ⟨1, by simp [hx]⟩, ?_, ?_⟩, ?_⟩, ?_⟩
    · intro ⟨a, ha⟩
      simpa [hx, closure_singleton_one, eq_comm] using ha
    · intro ⟨a, ha⟩
      simpa [hxy.mp hx, closure_singleton_one, eq_comm] using ha
    · intros
      simp
    · intro ⟨a, ha⟩ ⟨b, hb⟩
      simp only [hx, closure_singleton_one, mem_bot] at ha hb
      simp [ha, hb]
  else by
    set x' := max x x⁻¹ with hx'
    have xpos : 1 < x' := by
      simp [hx', eq_comm, hx]
    set y' := max y y⁻¹ with hy'
    have ypos : 1 < y' := by
      simp [hy', eq_comm, ← hxy, hx]
    have hxc : closure {x} = closure {x'} := by
      rcases max_cases x x⁻¹ with H|H <;>
      simp [hx', H.left]
    have hyc : closure {y} = closure {y'} := by
      rcases max_cases y y⁻¹ with H|H <;>
      simp [hy', H.left]
    refine ⟨⟨⟨
      fun a ↦ ⟨y' ^ ((mem_closure_singleton).mp
        (by simpa [hxc] using a.prop)).choose, ?_⟩,
      fun a ↦ ⟨x' ^ ((mem_closure_singleton).mp
        (by simpa [hyc] using a.prop)).choose, ?_⟩,
        ?_, ?_⟩, ?_⟩, ?_⟩
    · rw [hyc, mem_closure_singleton]
      exact ⟨_, rfl⟩
    · rw [hxc, mem_closure_singleton]
      exact ⟨_, rfl⟩
    · intro a
      generalize_proofs A B C D
      rw [Subtype.ext_iff, ← (C a).choose_spec, zpow_right_inj xpos,
          ← zpow_right_inj ypos, (A ⟨_, D a⟩).choose_spec]
    · intro a
      generalize_proofs A B C D
      rw [Subtype.ext_iff, ← (C a).choose_spec, zpow_right_inj ypos,
          ← zpow_right_inj xpos, (A ⟨_, D a⟩).choose_spec]
    · intro a b
      generalize_proofs A B C D E F
      simp only [Submonoid.coe_mul, coe_toSubmonoid, Submonoid.mk_mul_mk, Subtype.mk.injEq,
                 coe_mul, MulMemClass.mk_mul_mk, Subtype.ext_iff]
      rw [← zpow_add, zpow_right_inj ypos, ← zpow_right_inj xpos, zpow_add,
          (A a).choose_spec, (A b).choose_spec, (A (a * b)).choose_spec]
      simp
    · intro a b
      simp only [MulEquiv.coe_mk, Equiv.coe_fn_mk, Subtype.mk_le_mk]
      generalize_proofs A B C D
      simp [zpow_le_zpow_iff ypos, ← zpow_le_zpow_iff xpos, A.choose_spec, B.choose_spec]

variable {G : Type*} [LinearOrderedCommGroup G] [MulArchimedean G]

@[to_additive]
lemma Subgroup.isLeast_of_closure_iff_eq_mabs {a b : G} :
    IsLeast {y : G | y ∈ closure ({a} : Set G) ∧ 1 < y} b ↔ b = |a|ₘ ∧ 1 < b := by
  constructor <;> intro h
  · have := Subgroup.cyclic_of_min h
    have ha : a ∈ closure ({b} : Set G) := by
      simp [← this]
    rw [mem_closure_singleton] at ha
    obtain ⟨n, rfl⟩ := ha
    have := h.left
    simp only [mem_closure_singleton, mem_setOf_eq, ← mul_zsmul] at this
    obtain ⟨m, hm⟩ := this.left
    have key : m * n = 1 := by
      rw [← zpow_right_inj this.right, zpow_mul', hm, zpow_one]
    rw [Int.mul_eq_one_iff_eq_one_or_neg_one] at key
    rw [eq_comm]
    rcases key with ⟨rfl, rfl⟩|⟨rfl, rfl⟩ <;>
    simp [this.right.le, this.right, mabs]
  · wlog ha : 1 ≤ a generalizing a
    · convert @this (a⁻¹) ?_ (by simpa using le_of_not_le ha) using 4
      · simp
      · rwa [mabs_inv]
    rw [mabs, sup_eq_left.mpr ((inv_le_one'.mpr ha).trans ha)] at h
    rcases h with ⟨rfl, h⟩
    refine ⟨?_, ?_⟩
    · simp [h]
    · intro x
      simp only [mem_closure_singleton, mem_setOf_eq, and_imp, forall_exists_index]
      rintro k rfl hk
      rw [← zpow_one b, ← zpow_mul, one_mul, zpow_le_zpow_iff h, ← zero_add 1,
          ← Int.lt_iff_add_one_le]
      contrapose! hk
      rw [← Left.one_le_inv_iff, ← zpow_neg]
      exact one_le_zpow ha (by simp [hk])

/-- If an element of a linearly ordered archimedean additive group is the least positive element,
then the whole group is isomorphic (and order-isomorphic) to the integers. -/
noncomputable def LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos {G : Type*}
    [LinearOrderedAddCommGroup G] [Archimedean G] {x : G}
    (h : IsLeast {y : G | 0 < y} x) : G ≃+o ℤ := by
  have : IsLeast {y : G | y ∈ (⊤ : AddSubgroup G) ∧ 0 < y} x := by simpa using h
  replace this := AddSubgroup.cyclic_of_min this
  let e : G ≃+o (⊤ : AddSubgroup G) := ⟨AddSubsemigroup.topEquiv.symm,
    (AddEquiv.strictMono_symm AddSubsemigroup.strictMono_topEquiv).le_iff_le⟩
  let e' : (⊤ : AddSubgroup G) ≃+o AddSubgroup.closure {x} :=
    ⟨AddEquiv.subsemigroupCongr (by simp [this]),
     (AddEquiv.strictMono_subsemigroupCongr _).le_iff_le⟩
  let g : (⊤ : AddSubgroup ℤ) ≃+o ℤ := ⟨AddSubsemigroup.topEquiv,
    (AddSubsemigroup.strictMono_topEquiv).le_iff_le⟩
  let g' : AddSubgroup.closure ({1} : Set ℤ) ≃+o (⊤ : AddSubgroup ℤ) :=
    ⟨(.subsemigroupCongr (by simp [AddSubgroup.closure_singleton_int_one_eq_top])),
     (AddEquiv.strictMono_subsemigroupCongr _).le_iff_le⟩
  let f := closure_equiv_closure x (1 : ℤ) (by simp [h.left.ne'])
  exact ((((e.trans e').trans f).trans g').trans g : G ≃+o ℤ)

/-- If an element of a linearly ordered mul-archimedean group is the least element greater than 1,
then the whole group is isomorphic (and order-isomorphic) to the multiplicative integers. -/
@[to_additive existing LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos]
noncomputable def LinearOrderedCommGroup.multiplicative_int_orderMonoidIso_of_isLeast_one_lt
    {x : G} (h : IsLeast {y : G | 1 < y} x) : G ≃*o Multiplicative ℤ := by
  have : IsLeast {y : Additive G | 0 < y} (.ofMul x) := h
  let f' := LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos (G := Additive G) this
  exact ⟨AddEquiv.toMultiplicative' f', by simp⟩

/-- Any linearly ordered archimedean additive group is either isomorphic (and order-isomorphic)
to the integers, or is densely ordered. -/
lemma LinearOrderedAddCommGroup.discrete_or_denselyOrdered (G : Type*)
    [LinearOrderedAddCommGroup G] [Archimedean G] :
    Nonempty (G ≃+o ℤ) ∨ DenselyOrdered G := by
  by_cases H : ∃ x, IsLeast {y : G | 0 < y} x
  · obtain ⟨x, hx⟩ := H
    exact Or.inl ⟨(int_orderAddMonoidIso_of_isLeast_pos hx)⟩
  · push_neg at H
    refine Or.inr ⟨?_⟩
    intro x y hxy
    specialize H (y - x)
    obtain ⟨z, hz⟩ : ∃ z : G, 0 < z ∧ z < y - x := by
      contrapose! H
      refine ⟨by simp [hxy], fun _ ↦ H _⟩
    refine ⟨x + z, ?_, ?_⟩
    · simp [hz.left]
    · simpa [lt_sub_iff_add_lt'] using hz.right

/-- Any linearly ordered archimedean additive group is either isomorphic (and order-isomorphic)
to the integers, or is densely ordered, exclusively. -/
lemma LinearOrderedAddCommGroup.discrete_iff_not_denselyOrdered (G : Type*)
    [LinearOrderedAddCommGroup G] [Archimedean G] :
    Nonempty (G ≃+o ℤ) ↔ ¬ DenselyOrdered G := by
  suffices ∀ (_ : G ≃+o ℤ), ¬ DenselyOrdered G by
    rcases LinearOrderedAddCommGroup.discrete_or_denselyOrdered G with ⟨⟨h⟩⟩|h
    · simpa [this h] using ⟨h⟩
    · simp only [h, not_true_eq_false, iff_false, not_nonempty_iff]
      exact ⟨fun H ↦ (this H) h⟩
  intro e H
  rw [denselyOrdered_iff_of_orderIsoClass e] at H
  obtain ⟨_, _⟩ := exists_between (one_pos (α := ℤ))
  linarith

variable (G) in
/-- Any linearly ordered mul-archimedean group is either isomorphic (and order-isomorphic)
to the multiplicative integers, or is densely ordered. -/
@[to_additive existing]
lemma LinearOrderedCommGroup.discrete_or_denselyOrdered :
    Nonempty (G ≃*o Multiplicative ℤ) ∨ DenselyOrdered G := by
  refine (LinearOrderedAddCommGroup.discrete_or_denselyOrdered (Additive G)).imp ?_ id
  rintro ⟨f, hf⟩
  exact ⟨AddEquiv.toMultiplicative' f, hf⟩

variable (G) in
/-- Any linearly ordered mul-archimedean group is either isomorphic (and order-isomorphic)
to the multiplicative integers, or is densely ordered, exclusively. -/
@[to_additive existing]
lemma LinearOrderedCommGroup.discrete_iff_not_denselyOrdered :
    Nonempty (G ≃*o Multiplicative ℤ) ↔ ¬ DenselyOrdered G := by
  let e : G ≃o Additive G := OrderIso.refl G
  rw [denselyOrdered_iff_of_orderIsoClass e,
    ← LinearOrderedAddCommGroup.discrete_iff_not_denselyOrdered (Additive G)]
  refine Nonempty.congr ?_ ?_ <;> intro f
  · exact ⟨MulEquiv.toAdditive' f, by simp⟩
  · exact ⟨MulEquiv.toAdditive'.symm f, by simp⟩

lemma denselyOrdered_units_iff {G₀ : Type*} [LinearOrderedCommGroupWithZero G₀] [Nontrivial G₀ˣ] :
    DenselyOrdered G₀ˣ ↔ DenselyOrdered G₀ := by
  constructor
  · intro H
    refine ⟨fun x y h ↦ ?_⟩
    rcases (zero_le' (a := x)).eq_or_lt with rfl|hx
    · lift y to G₀ˣ using h.ne'.isUnit
      obtain ⟨z, hz⟩ := exists_ne (1 : G₀ˣ)
      refine ⟨(y * |z|ₘ⁻¹ : G₀ˣ), ?_, ?_⟩
      · simp [zero_lt_iff]
      · rw [Units.val_lt_val]
        simp [hz]
    · obtain ⟨z, hz, hz'⟩ := H.dense (Units.mk0 x hx.ne') (Units.mk0 y (hx.trans h).ne')
        (by simp [← Units.val_lt_val, h])
      refine ⟨z, ?_, ?_⟩ <;>
      simpa [← Units.val_lt_val]
  · intro H
    refine ⟨fun x y h ↦ ?_⟩
    obtain ⟨z, hz⟩ := exists_between (Units.val_lt_val.mpr h)
    rcases (zero_le' (a := z)).eq_or_lt with rfl|hz'
    · simp at hz
    refine ⟨Units.mk0 z hz'.ne', ?_⟩
    simp [← Units.val_lt_val, hz]

/-- Any nontrivial (has other than 0 and 1) linearly ordered mul-archimedean group with zero is
either isomorphic (and order-isomorphic) to `ℤₘ₀`, or is densely ordered. -/
lemma LinearOrderedCommGroupWithZero.discrete_or_denselyOrdered (G : Type*)
    [LinearOrderedCommGroupWithZero G] [Nontrivial Gˣ] [MulArchimedean G] :
    Nonempty (G ≃*o WithZero (Multiplicative ℤ)) ∨ DenselyOrdered G := by
  classical
  rw [← denselyOrdered_units_iff]
  refine (LinearOrderedCommGroup.discrete_or_denselyOrdered Gˣ).imp_left ?_
  intro ⟨f⟩
  refine ⟨OrderMonoidIso.trans
    ⟨WithZero.withZeroUnitsEquiv.symm, ?_⟩ ⟨f.withZero, ?_⟩⟩
  · intro
    simp only [WithZero.withZeroUnitsEquiv, MulEquiv.symm_mk,
      MulEquiv.toEquiv_eq_coe, Equiv.toFun_as_coe, EquivLike.coe_coe, MulEquiv.coe_mk,
      Equiv.coe_fn_symm_mk ]
    split_ifs <;>
    simp_all [← Units.val_le_val]
  · intro a b
    induction a <;> induction b <;>
    simp [MulEquiv.withZero]

open WithZero in
/-- Any nontrivial (has other than 0 and 1) linearly ordered mul-archimedean group with zero is
either isomorphic (and order-isomorphic) to `ℤₘ₀`, or is densely ordered, exclusively -/
lemma LinearOrderedCommGroupWithZero.discrete_iff_not_denselyOrdered (G : Type*)
    [LinearOrderedCommGroupWithZero G] [Nontrivial Gˣ] [MulArchimedean G] :
    Nonempty (G ≃*o WithZero (Multiplicative ℤ)) ↔ ¬ DenselyOrdered G := by
  rw [← denselyOrdered_units_iff,
      ← LinearOrderedCommGroup.discrete_iff_not_denselyOrdered]
  refine Nonempty.congr ?_ ?_ <;> intro f
  · refine ⟨MulEquiv.unzero (withZeroUnitsEquiv.trans f), ?_⟩
    intros
    simp only [MulEquiv.unzero, withZeroUnitsEquiv, MulEquiv.trans_apply,
      MulEquiv.coe_mk, Equiv.coe_fn_mk, recZeroCoe_coe, OrderMonoidIso.coe_mulEquiv,
      MulEquiv.symm_trans_apply, MulEquiv.symm_mk, Equiv.coe_fn_symm_mk, map_eq_zero, coe_ne_zero,
      ↓reduceDIte, unzero_coe, MulEquiv.toEquiv_eq_coe, Equiv.toFun_as_coe, EquivLike.coe_coe]
    rw [← Units.val_le_val, ← map_le_map_iff f, ← coe_le_coe, coe_unzero, coe_unzero]
  · refine ⟨withZeroUnitsEquiv.symm.trans (MulEquiv.withZero f), ?_⟩
    intros
    simp only [withZeroUnitsEquiv, MulEquiv.symm_mk, MulEquiv.withZero,
      MulEquiv.toMonoidHom_eq_coe, MulEquiv.toEquiv_eq_coe, Equiv.toFun_as_coe, EquivLike.coe_coe,
      MulEquiv.trans_apply, MulEquiv.coe_mk, Equiv.coe_fn_symm_mk, Equiv.coe_fn_mk]
    split_ifs <;>
    simp_all [← Units.val_le_val]
