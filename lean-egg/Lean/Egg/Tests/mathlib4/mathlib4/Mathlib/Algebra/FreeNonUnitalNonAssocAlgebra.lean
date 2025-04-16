import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2021 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash
-/
import Mathlib.Algebra.Free
import Mathlib.Algebra.MonoidAlgebra.Basic

/-!
# Free algebras

Given a semiring `R` and a type `X`, we construct the free non-unital, non-associative algebra on
`X` with coefficients in `R`, together with its universal property. The construction is valuable
because it can be used to build free algebras with more structure, e.g., free Lie algebras.

Note that elsewhere we have a construction of the free unital, associative algebra. This is called
`FreeAlgebra`.

## Main definitions

  * `FreeNonUnitalNonAssocAlgebra`
  * `FreeNonUnitalNonAssocAlgebra.lift`
  * `FreeNonUnitalNonAssocAlgebra.of`

## Implementation details

We construct the free algebra as the magma algebra, with coefficients in `R`, of the free magma on
`X`. However we regard this as an implementation detail and thus deliberately omit the lemmas
`of_apply` and `lift_apply`, and we mark `FreeNonUnitalNonAssocAlgebra` and `lift` as
irreducible once we have established the universal property.

## Tags

free algebra, non-unital, non-associative, free magma, magma algebra, universal property,
forgetful functor, adjoint functor
-/


universe u v w

noncomputable section

variable (R : Type u) (X : Type v) [Semiring R]

/-- The free non-unital, non-associative algebra on the type `X` with coefficients in `R`. -/
abbrev FreeNonUnitalNonAssocAlgebra :=
  MonoidAlgebra R (FreeMagma X)

namespace FreeNonUnitalNonAssocAlgebra

variable {X}

/-- The embedding of `X` into the free algebra with coefficients in `R`. -/
def of : X → FreeNonUnitalNonAssocAlgebra R X :=
  MonoidAlgebra.ofMagma R _ ∘ FreeMagma.of

variable {A : Type w} [NonUnitalNonAssocSemiring A]
variable [Module R A] [IsScalarTower R A A] [SMulCommClass R A A]

/-- The functor `X ↦ FreeNonUnitalNonAssocAlgebra R X` from the category of types to the
category of non-unital, non-associative algebras over `R` is adjoint to the forgetful functor in the
other direction. -/
def lift : (X → A) ≃ (FreeNonUnitalNonAssocAlgebra R X →ₙₐ[R] A) :=
  FreeMagma.lift.trans (MonoidAlgebra.liftMagma R)

@[simp]
theorem lift_symm_apply (F : FreeNonUnitalNonAssocAlgebra R X →ₙₐ[R] A) :
    (lift R).symm F = F ∘ of R := rfl

@[simp]
theorem of_comp_lift (f : X → A) : lift R f ∘ of R = f :=
  (lift R).left_inv f

@[simp]
theorem lift_unique (f : X → A) (F : FreeNonUnitalNonAssocAlgebra R X →ₙₐ[R] A) :
    F ∘ of R = f ↔ F = lift R f :=
  (lift R).symm_apply_eq

@[simp]
theorem lift_of_apply (f : X → A) (x) : lift R f (of R x) = f x :=
  congr_fun (of_comp_lift _ f) x

@[simp]
theorem lift_comp_of (F : FreeNonUnitalNonAssocAlgebra R X →ₙₐ[R] A) : lift R (F ∘ of R) = F :=
  (lift R).apply_symm_apply F

@[ext]
theorem hom_ext {F₁ F₂ : FreeNonUnitalNonAssocAlgebra R X →ₙₐ[R] A}
    (h : ∀ x, F₁ (of R x) = F₂ (of R x)) : F₁ = F₂ :=
  (lift R).symm.injective <| funext h

end FreeNonUnitalNonAssocAlgebra
