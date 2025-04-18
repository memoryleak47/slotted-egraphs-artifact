import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Kenny Lau, Kim Morrison, Alex Keizer
-/
import Mathlib.Data.List.OfFn
import Mathlib.Data.List.Range
import Batteries.Data.List.Perm

/-!
# Lists of elements of `Fin n`

This file develops some results on `finRange n`.
-/

assert_not_exists Monoid

universe u

namespace List

variable {α : Type u}

@[simp]
theorem map_coe_finRange (n : ℕ) : ((finRange n) : List (Fin n)).map (Fin.val) = List.range n := by
  simp_rw [finRange, map_pmap, pmap_eq_map]
  exact List.map_id _

theorem finRange_succ_eq_map (n : ℕ) : finRange n.succ = 0 :: (finRange n).map Fin.succ := by
  apply map_injective_iff.mpr Fin.val_injective
  rw [map_cons, map_coe_finRange, range_succ_eq_map, Fin.val_zero, ← map_coe_finRange, map_map,
    map_map]
  simp only [Function.comp_def, Fin.val_succ]

theorem finRange_succ (n : ℕ) :
    finRange n.succ = (finRange n |>.map Fin.castSucc |>.concat (.last _)) := by
  apply map_injective_iff.mpr Fin.val_injective
  simp [range_succ, Function.comp_def]

-- Porting note: `map_nth_le` moved to `List.finRange_map_get` in Data.List.Range

theorem ofFn_eq_pmap {n} {f : Fin n → α} :
    ofFn f = pmap (fun i hi => f ⟨i, hi⟩) (range n) fun _ => mem_range.1 := by
  rw [pmap_eq_map_attach]
  exact ext_getElem (by simp) fun i hi1 hi2 => by simp [List.getElem_ofFn f i hi1]

theorem ofFn_id (n) : ofFn id = finRange n :=
  ofFn_eq_pmap

theorem ofFn_eq_map {n} {f : Fin n → α} : ofFn f = (finRange n).map f := by
  rw [← ofFn_id, map_ofFn, Function.comp_id]

theorem nodup_ofFn_ofInjective {n} {f : Fin n → α} (hf : Function.Injective f) :
    Nodup (ofFn f) := by
  rw [ofFn_eq_pmap]
  exact (nodup_range n).pmap fun _ _ _ _ H => Fin.val_eq_of_eq <| hf H

theorem nodup_ofFn {n} {f : Fin n → α} : Nodup (ofFn f) ↔ Function.Injective f := by
  refine ⟨?_, nodup_ofFn_ofInjective⟩
  refine Fin.consInduction ?_ (fun x₀ xs ih => ?_) f
  · intro _
    exact Function.injective_of_subsingleton _
  · intro h
    rw [Fin.cons_injective_iff]
    simp_rw [ofFn_succ, Fin.cons_succ, nodup_cons, Fin.cons_zero, mem_ofFn] at h
    exact h.imp_right ih

end List

open List

theorem Equiv.Perm.map_finRange_perm {n : ℕ} (σ : Equiv.Perm (Fin n)) :
    map σ (finRange n) ~ finRange n := by
  rw [perm_ext_iff_of_nodup ((nodup_finRange n).map σ.injective) <| nodup_finRange n]
  simpa [mem_map, mem_finRange] using σ.surjective

/-- The list obtained from a permutation of a tuple `f` is permutation equivalent to
the list obtained from `f`. -/
theorem Equiv.Perm.ofFn_comp_perm {n : ℕ} {α : Type u} (σ : Equiv.Perm (Fin n)) (f : Fin n → α) :
    ofFn (f ∘ σ) ~ ofFn f := by
  rw [ofFn_eq_map, ofFn_eq_map, ← map_map]
  exact σ.map_finRange_perm.map f
