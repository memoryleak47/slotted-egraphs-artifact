import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Kenny Lau, Kim Morrison
-/
import Mathlib.Data.List.Chain
import Mathlib.Data.List.Nodup

/-!
# Ranges of naturals as lists

This file shows basic results about `List.iota`, `List.range`, `List.range'`
and defines `List.finRange`.
`finRange n` is the list of elements of `Fin n`.
`iota n = [n, n - 1, ..., 1]` and `range n = [0, ..., n - 1]` are basic list constructions used for
tactics. `range' a b = [a, ..., a + b - 1]` is there to help prove properties about them.
Actual maths should use `List.Ico` instead.
-/

universe u

open Nat

namespace List

variable {α : Type u}

theorem getElem_range'_1 {n m} (i) (H : i < (range' n m).length) :
    (range' n m)[i] = n + i := by simp

theorem chain'_range_succ (r : ℕ → ℕ → Prop) (n : ℕ) :
    Chain' r (range n.succ) ↔ ∀ m < n, r m m.succ := by
  rw [range_succ]
  induction' n with n hn
  · simp
  · rw [range_succ]
    simp only [append_assoc, singleton_append, chain'_append_cons_cons, chain'_singleton, and_true]
    rw [hn, forall_lt_succ]

theorem chain_range_succ (r : ℕ → ℕ → Prop) (n a : ℕ) :
    Chain r a (range n.succ) ↔ r a 0 ∧ ∀ m < n, r m m.succ := by
  rw [range_succ_eq_map, chain_cons, and_congr_right_iff, ← chain'_range_succ, range_succ_eq_map]
  exact fun _ => Iff.rfl

@[simp]
theorem finRange_zero : finRange 0 = [] :=
  rfl

@[simp]
theorem mem_finRange {n : ℕ} (a : Fin n) : a ∈ finRange n :=
  mem_pmap.2
    ⟨a.1, mem_range.2 a.2, by
      cases a
      rfl⟩

theorem nodup_finRange (n : ℕ) : (finRange n).Nodup :=
  (Pairwise.pmap (nodup_range n) _) fun _ _ _ _ => @Fin.ne_of_val_ne _ ⟨_, _⟩ ⟨_, _⟩

@[simp]
theorem length_finRange (n : ℕ) : (finRange n).length = n := by
  rw [finRange, length_pmap, length_range]

@[simp]
theorem finRange_eq_nil {n : ℕ} : finRange n = [] ↔ n = 0 := by
  rw [← length_eq_zero, length_finRange]

theorem pairwise_lt_finRange (n : ℕ) : Pairwise (· < ·) (finRange n) :=
  (List.pairwise_lt_range n).pmap (by simp) (by simp)

theorem pairwise_le_finRange (n : ℕ) : Pairwise (· ≤ ·) (finRange n) :=
  (List.pairwise_le_range n).pmap (by simp) (by simp)

@[simp]
theorem getElem_finRange {n : ℕ} {i : ℕ} (h) :
    (finRange n)[i] = ⟨i, length_finRange n ▸ h⟩ := by
  simp [finRange, getElem_range, getElem_pmap]

-- Porting note (#10756): new theorem
theorem get_finRange {n : ℕ} {i : ℕ} (h) :
    (finRange n).get ⟨i, h⟩ = ⟨i, length_finRange n ▸ h⟩ := by
  simp

@[deprecated (since := "2024-08-19")] alias nthLe_range' := get_range'
@[deprecated (since := "2024-08-19")] alias nthLe_range'_1 := getElem_range'_1
@[deprecated (since := "2024-08-19")] alias nthLe_range := get_range
@[deprecated (since := "2024-08-19")] alias nthLe_finRange := get_finRange

@[simp]
theorem finRange_map_get (l : List α) : (finRange l.length).map l.get = l :=
  List.ext_get (by simp) (by simp)

@[simp] theorem indexOf_finRange {k : ℕ} (i : Fin k) : (finRange k).indexOf i = i := by
  have : (finRange k).indexOf i < (finRange k).length := indexOf_lt_length.mpr (by simp)
  have h₁ : (finRange k).get ⟨(finRange k).indexOf i, this⟩ = i := indexOf_get this
  have h₂ : (finRange k).get ⟨i, by simp⟩ = i := get_finRange _
  simpa using (Nodup.get_inj_iff (nodup_finRange k)).mp (Eq.trans h₁ h₂.symm)

section Ranges

/-- From `l : List ℕ`, construct `l.ranges : List (List ℕ)` such that
  `l.ranges.map List.length = l` and `l.ranges.join = range l.sum`
* Example: `[1,2,3].ranges = [[0],[1,2],[3,4,5]]` -/
def ranges : List ℕ → List (List ℕ)
  | [] => nil
  | a::l => range a::(ranges l).map (map (a + ·))

/-- The members of `l.ranges` are pairwise disjoint -/
theorem ranges_disjoint (l : List ℕ) :
    Pairwise Disjoint (ranges l) := by
  induction l with
  | nil => exact Pairwise.nil
  | cons a l hl =>
    simp only [ranges, pairwise_cons]
    constructor
    · intro s hs
      obtain ⟨s', _, rfl⟩ := mem_map.mp hs
      intro u hu
      rw [mem_map]
      rintro ⟨v, _, rfl⟩
      rw [mem_range] at hu
      omega
    · rw [pairwise_map]
      apply Pairwise.imp _ hl
      intro u v
      apply disjoint_map
      exact fun u v => Nat.add_left_cancel

/-- The lengths of the members of `l.ranges` are those given by `l` -/
theorem ranges_length (l : List ℕ) :
    l.ranges.map length = l := by
  induction l with
  | nil => simp only [ranges, map_nil]
  | cons a l hl => -- (a :: l)
    simp only [map, length_range, map_map, cons.injEq, true_and]
    conv_rhs => rw [← hl]
    apply map_congr_left
    intro s _
    simp only [Function.comp_apply, length_map]

set_option linter.deprecated false in
/-- See `List.ranges_flatten` for the version about `List.sum`. -/
@[deprecated "Use `List.ranges_flatten`." (since := "2024-10-17")]
lemma ranges_flatten' : ∀ l : List ℕ, l.ranges.flatten = range (Nat.sum l)
  | [] => rfl
  | a :: l => by simp only [Nat.sum_cons, flatten, ← map_flatten, ranges_flatten', range_add]

@[deprecated (since := "2024-10-15")] alias ranges_join' := ranges_flatten'

set_option linter.deprecated false in
/-- Any entry of any member of `l.ranges` is strictly smaller than `Nat.sum l`.
See `List.mem_mem_ranges_iff_lt_sum` for the version about `List.sum`. -/
lemma mem_mem_ranges_iff_lt_natSum (l : List ℕ) {n : ℕ} :
    (∃ s ∈ l.ranges, n ∈ s) ↔ n < Nat.sum l := by
  rw [← mem_range, ← ranges_flatten', mem_flatten]

end Ranges

end List
