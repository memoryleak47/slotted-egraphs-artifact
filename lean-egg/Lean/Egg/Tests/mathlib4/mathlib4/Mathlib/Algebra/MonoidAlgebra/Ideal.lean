import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2023 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser
-/
import Mathlib.Algebra.MonoidAlgebra.Defs
import Mathlib.RingTheory.Ideal.BigOperators
import Mathlib.RingTheory.Ideal.Span

/-!
# Lemmas about ideals of `MonoidAlgebra` and `AddMonoidAlgebra`
-/


variable {k A G : Type*}

/-- If `x` belongs to the ideal generated by generators in `s`, then every element of the support of
`x` factors through an element of `s`.

We could spell `∃ d, m = d * m` as `MulOpposite.op m' ∣ MulOpposite.op m` but this would be worse.
-/
theorem MonoidAlgebra.mem_ideal_span_of_image [Monoid G] [Semiring k] {s : Set G}
    {x : MonoidAlgebra k G} :
    x ∈ Ideal.span (MonoidAlgebra.of k G '' s) ↔ ∀ m ∈ x.support, ∃ m' ∈ s, ∃ d, m = d * m' := by
  let RHS : Ideal (MonoidAlgebra k G) :=
    { carrier := { p | ∀ m : G, m ∈ p.support → ∃ m' ∈ s, ∃ d, m = d * m' }
      add_mem' := fun {x y} hx hy m hm => by
        classical exact (Finset.mem_union.1 <| Finsupp.support_add hm).elim (hx m) (hy m)
      zero_mem' := fun m hm => by cases hm
      smul_mem' := fun x y hy m hm => by
        classical
        rw [smul_eq_mul, mul_def] at hm
        replace hm := Finset.mem_biUnion.mp (Finsupp.support_sum hm)
        obtain ⟨xm, -, hm⟩ := hm
        replace hm := Finset.mem_biUnion.mp (Finsupp.support_sum hm)
        obtain ⟨ym, hym, hm⟩ := hm
        obtain rfl := Finset.mem_singleton.mp (Finsupp.support_single_subset hm)
        refine (hy _ hym).imp fun sm p => And.imp_right ?_ p
        rintro ⟨d, rfl⟩
        exact ⟨xm * d, (mul_assoc _ _ _).symm⟩ }
  change _ ↔ x ∈ RHS
  constructor
  · revert x
    rw [← SetLike.le_def] -- Porting note: refine needs this even though it's defeq?
    refine Ideal.span_le.2 ?_
    rintro _ ⟨i, hi, rfl⟩ m hm
    refine ⟨_, hi, 1, ?_⟩
    obtain rfl := Finset.mem_singleton.mp (Finsupp.support_single_subset hm)
    exact (one_mul _).symm
  · intro hx
    rw [← Finsupp.sum_single x]
    refine Ideal.sum_mem _ fun i hi => ?_  -- Porting note: changed `apply` to `refine`
    obtain ⟨d, hd, d2, rfl⟩ := hx _ hi
    convert Ideal.mul_mem_left _ (id <| Finsupp.single d2 <| x (d2 * d) : MonoidAlgebra k G) _
    pick_goal 3
    · exact Ideal.subset_span ⟨_, hd, rfl⟩
    rw [id, MonoidAlgebra.of_apply, MonoidAlgebra.single_mul_single, mul_one]

/-- If `x` belongs to the ideal generated by generators in `s`, then every element of the support of
`x` factors additively through an element of `s`.
-/
theorem AddMonoidAlgebra.mem_ideal_span_of'_image [AddMonoid A] [Semiring k] {s : Set A}
    {x : AddMonoidAlgebra k A} :
    x ∈ Ideal.span (AddMonoidAlgebra.of' k A '' s) ↔ ∀ m ∈ x.support, ∃ m' ∈ s, ∃ d, m = d + m' :=
  @MonoidAlgebra.mem_ideal_span_of_image k (Multiplicative A) _ _ _ _
