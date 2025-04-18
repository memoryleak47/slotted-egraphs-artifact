import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2021 Kim Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kim Morrison
-/
import Mathlib.Data.Finset.Lattice
import Mathlib.Order.Hom.Basic
import Mathlib.Data.Set.Finite
import Mathlib.Order.ConditionallyCompleteLattice.Indexed

/-!
# The monotone sequence of partial supremums of a sequence

We define `partialSups : (ℕ → α) → ℕ →o α` inductively. For `f : ℕ → α`, `partialSups f` is
the sequence `f 0`, `f 0 ⊔ f 1`, `f 0 ⊔ f 1 ⊔ f 2`, ... The point of this definition is that
* it doesn't need a `⨆`, as opposed to `⨆ (i ≤ n), f i` (which also means the wrong thing on
  `ConditionallyCompleteLattice`s).
* it doesn't need a `⊥`, as opposed to `(Finset.range (n + 1)).sup f`.
* it avoids needing to prove that `Finset.range (n + 1)` is nonempty to use `Finset.sup'`.

Equivalence with those definitions is shown by `partialSups_eq_biSup`, `partialSups_eq_sup_range`,
and `partialSups_eq_sup'_range` respectively.

## Notes

One might dispute whether this sequence should start at `f 0` or `⊥`. We choose the former because :
* Starting at `⊥` requires... having a bottom element.
* `fun f n ↦ (Finset.range n).sup f` is already effectively the sequence starting at `⊥`.
* If we started at `⊥` we wouldn't have the Galois insertion. See `partialSups.gi`.

## TODO

One could generalize `partialSups` to any locally finite bot preorder domain, in place of `ℕ`.
Necessary for the TODO in the module docstring of `Order.disjointed`.
-/


variable {α : Type*}

section SemilatticeSup

variable [SemilatticeSup α]

/-- The monotone sequence whose value at `n` is the supremum of the `f m` where `m ≤ n`. -/
def partialSups (f : ℕ → α) : ℕ →o α :=
  ⟨@Nat.rec (fun _ => α) (f 0) fun (n : ℕ) (a : α) => a ⊔ f (n + 1),
    monotone_nat_of_le_succ fun _ => le_sup_left⟩

@[simp]
theorem partialSups_zero (f : ℕ → α) : partialSups f 0 = f 0 :=
  rfl

@[simp]
theorem partialSups_succ (f : ℕ → α) (n : ℕ) :
    partialSups f (n + 1) = partialSups f n ⊔ f (n + 1) :=
  rfl

lemma partialSups_iff_forall {f : ℕ → α} (p : α → Prop)
    (hp : ∀ {a b}, p (a ⊔ b) ↔ p a ∧ p b) : ∀ {n : ℕ}, p (partialSups f n) ↔ ∀ k ≤ n, p (f k)
  | 0 => by simp
  | (n + 1) => by simp [hp, partialSups_iff_forall, ← Nat.lt_succ_iff, ← Nat.forall_lt_succ]

@[simp]
lemma partialSups_le_iff {f : ℕ → α} {n : ℕ} {a : α} : partialSups f n ≤ a ↔ ∀ k ≤ n, f k ≤ a :=
  partialSups_iff_forall (· ≤ a) sup_le_iff

theorem le_partialSups_of_le (f : ℕ → α) {m n : ℕ} (h : m ≤ n) : f m ≤ partialSups f n :=
  partialSups_le_iff.1 le_rfl m h

theorem le_partialSups (f : ℕ → α) : f ≤ partialSups f := fun _n => le_partialSups_of_le f le_rfl

theorem partialSups_le (f : ℕ → α) (n : ℕ) (a : α) (w : ∀ m, m ≤ n → f m ≤ a) :
    partialSups f n ≤ a :=
  partialSups_le_iff.2 w

@[simp]
lemma upperBounds_range_partialSups (f : ℕ → α) :
    upperBounds (Set.range (partialSups f)) = upperBounds (Set.range f) := by
  ext a
  simp only [mem_upperBounds, Set.forall_mem_range, partialSups_le_iff]
  exact ⟨fun h _ ↦ h _ _ le_rfl, fun h _ _ _ ↦ h _⟩

@[simp]
theorem bddAbove_range_partialSups {f : ℕ → α} :
    BddAbove (Set.range (partialSups f)) ↔ BddAbove (Set.range f) :=
  .of_eq <| congr_arg Set.Nonempty <| upperBounds_range_partialSups f

theorem Monotone.partialSups_eq {f : ℕ → α} (hf : Monotone f) : (partialSups f : ℕ → α) = f := by
  ext n
  induction' n with n ih
  · rfl
  · rw [partialSups_succ, ih, sup_eq_right.2 (hf (Nat.le_succ _))]

theorem partialSups_mono : Monotone (partialSups : (ℕ → α) → ℕ →o α) := fun _f _g h _n ↦
  partialSups_le_iff.2 fun k hk ↦ (h k).trans (le_partialSups_of_le _ hk)

lemma partialSups_monotone (f : ℕ → α) : Monotone (partialSups f) :=
  fun n _ hnm ↦ partialSups_le f n _ (fun _ hm'n ↦ le_partialSups_of_le _ (hm'n.trans hnm))

/-- `partialSups` forms a Galois insertion with the coercion from monotone functions to functions.
-/
def partialSups.gi : GaloisInsertion (partialSups : (ℕ → α) → ℕ →o α) (↑) where
  choice f h :=
    ⟨f, by convert (partialSups f).monotone using 1; exact (le_partialSups f).antisymm h⟩
  gc f g := by
    refine ⟨(le_partialSups f).trans, fun h => ?_⟩
    convert partialSups_mono h
    exact OrderHom.ext _ _ g.monotone.partialSups_eq.symm
  le_l_u f := le_partialSups f
  choice_eq f h := OrderHom.ext _ _ ((le_partialSups f).antisymm h)

theorem partialSups_eq_sup'_range (f : ℕ → α) (n : ℕ) :
    partialSups f n = (Finset.range (n + 1)).sup' ⟨n, Finset.self_mem_range_succ n⟩ f :=
  eq_of_forall_ge_iff fun _ ↦ by simp [Nat.lt_succ_iff]

lemma partialSups_apply {ι : Type*} {π : ι → Type*} [(i : ι) → SemilatticeSup (π i)]
    (f : ℕ → (i : ι) → π i) (n : ℕ) (i : ι) : partialSups f n i = partialSups (f · i) n := by
  simp only [partialSups_eq_sup'_range, Finset.sup'_apply]

end SemilatticeSup

theorem partialSups_eq_sup_range [SemilatticeSup α] [OrderBot α] (f : ℕ → α) (n : ℕ) :
    partialSups f n = (Finset.range (n + 1)).sup f :=
  eq_of_forall_ge_iff fun _ ↦ by simp [Nat.lt_succ_iff]

@[simp]
lemma disjoint_partialSups_left [DistribLattice α] [OrderBot α] {f : ℕ → α} {n : ℕ} {x : α} :
    Disjoint (partialSups f n) x ↔ ∀ k ≤ n, Disjoint (f k) x :=
  partialSups_iff_forall (Disjoint · x) disjoint_sup_left

@[simp]
lemma disjoint_partialSups_right [DistribLattice α] [OrderBot α] {f : ℕ → α} {n : ℕ} {x : α} :
    Disjoint x (partialSups f n) ↔ ∀ k ≤ n, Disjoint x (f k) :=
  partialSups_iff_forall (Disjoint x) disjoint_sup_right

/- Note this lemma requires a distributive lattice, so is not useful (or true) in situations such as
submodules. -/
theorem partialSups_disjoint_of_disjoint [DistribLattice α] [OrderBot α] (f : ℕ → α)
    (h : Pairwise (Disjoint on f)) {m n : ℕ} (hmn : m < n) : Disjoint (partialSups f m) (f n) :=
  disjoint_partialSups_left.2 fun _k hk ↦ h <| (hk.trans_lt hmn).ne

section ConditionallyCompleteLattice

variable [ConditionallyCompleteLattice α]

theorem partialSups_eq_ciSup_Iic (f : ℕ → α) (n : ℕ) : partialSups f n = ⨆ i : Set.Iic n, f i :=
  eq_of_forall_ge_iff fun _ ↦ by
    rw [ciSup_set_le_iff Set.nonempty_Iic ((Set.finite_le_nat _).image _).bddAbove,
      partialSups_le_iff]; rfl

@[simp]
theorem ciSup_partialSups_eq {f : ℕ → α} (h : BddAbove (Set.range f)) :
    ⨆ n, partialSups f n = ⨆ n, f n := by
  refine (ciSup_le fun n => ?_).antisymm (ciSup_mono ?_ <| le_partialSups f)
  · rw [partialSups_eq_ciSup_Iic]
    exact ciSup_le fun i => le_ciSup h _
  · rwa [bddAbove_range_partialSups]

end ConditionallyCompleteLattice

section CompleteLattice

theorem partialSups_eq_biSup [CompleteLattice α] (f : ℕ → α) (n : ℕ) :
    partialSups f n = ⨆ i ≤ n, f i := by
  simpa only [iSup_subtype] using partialSups_eq_ciSup_Iic f n

lemma partialSups_eq_sUnion_image [DecidableEq (Set α)] (s : ℕ → Set α) (n : ℕ) :
    partialSups s n = ⋃₀ ↑((Finset.range (n + 1)).image s) := by
  ext; simp [partialSups_eq_biSup, Nat.lt_succ_iff]

lemma partialSups_eq_biUnion_range (s : ℕ → Set α) (n : ℕ) :
    partialSups s n = ⋃ i ∈ Finset.range (n + 1), s i := by
  ext; simp [partialSups_eq_biSup, Nat.lt_succ]

variable [CompleteLattice α]

theorem iSup_partialSups_eq (f : ℕ → α) : ⨆ n, partialSups f n = ⨆ n, f n :=
  ciSup_partialSups_eq <| OrderTop.bddAbove _

theorem iSup_le_iSup_of_partialSups_le_partialSups {f g : ℕ → α}
    (h : partialSups f ≤ partialSups g) : ⨆ n, f n ≤ ⨆ n, g n := by
  rw [← iSup_partialSups_eq f, ← iSup_partialSups_eq g]
  exact iSup_mono h

theorem iSup_eq_iSup_of_partialSups_eq_partialSups {f g : ℕ → α}
    (h : partialSups f = partialSups g) : ⨆ n, f n = ⨆ n, g n := by
  simp_rw [← iSup_partialSups_eq f, ← iSup_partialSups_eq g, h]

end CompleteLattice
