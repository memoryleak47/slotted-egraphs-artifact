import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2020 Kim Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kim Morrison
-/
import Mathlib.Algebra.Category.Ring.Limits
import Mathlib.Topology.Sheaves.Sheaf

/-!
# Checking the sheaf condition on the underlying presheaf of types.

If `G : C ⥤ D` is a functor which reflects isomorphisms and preserves limits
(we assume all limits exist in `C`),
then checking the sheaf condition for a presheaf `F : Presheaf C X`
is equivalent to checking the sheaf condition for `F ⋙ G`.

The important special case is when
`C` is a concrete category with a forgetful functor
that preserves limits and reflects isomorphisms.
Then to check the sheaf condition it suffices
to check it on the underlying sheaf of types.

## References
* https://stacks.math.columbia.edu/tag/0073
-/

universe v v₁ v₂ u₁ u₂

noncomputable section

open CategoryTheory Limits

namespace TopCat.Presheaf

/-- If `G : C ⥤ D` is a functor which reflects isomorphisms and preserves limits
(we assume all limits exist in `C`),
then checking the sheaf condition for a presheaf `F : Presheaf C X`
is equivalent to checking the sheaf condition for `F ⋙ G`.

The important special case is when
`C` is a concrete category with a forgetful functor
that preserves limits and reflects isomorphisms.
Then to check the sheaf condition it suffices to check it on the underlying sheaf of types.

Another useful example is the forgetful functor `TopCommRingCat ⥤ TopCat`.

See <https://stacks.math.columbia.edu/tag/0073>.
In fact we prove a stronger version with arbitrary target category.
-/
theorem isSheaf_iff_isSheaf_comp' {C : Type u₁} [Category.{v₁} C] {D : Type u₂} [Category.{v₂} D]
    (G : C ⥤ D) [G.ReflectsIsomorphisms] [HasLimitsOfSize.{v, v} C] [PreservesLimitsOfSize.{v, v} G]
    {X : TopCat.{v}} (F : Presheaf C X) : Presheaf.IsSheaf F ↔ Presheaf.IsSheaf (F ⋙ G) :=
  Presheaf.isSheaf_iff_isSheaf_comp _ F G

theorem isSheaf_iff_isSheaf_comp {C : Type u₁} [Category.{v} C] {D : Type u₂} [Category.{v} D]
    (G : C ⥤ D) [G.ReflectsIsomorphisms] [HasLimits C] [PreservesLimits G]
    {X : TopCat.{v}} (F : Presheaf C X) : Presheaf.IsSheaf F ↔ Presheaf.IsSheaf (F ⋙ G) :=
  isSheaf_iff_isSheaf_comp' G F

/-!
As an example, we now have everything we need to check the sheaf condition
for a presheaf of commutative rings, merely by checking the sheaf condition
for the underlying sheaf of types.

Note that the universes for `TopCat` and `CommRingCat` must be the same for this argument
to go through.
-/
example (X : TopCat.{u₁}) (F : Presheaf CommRingCat.{u₁} X)
    (h : Presheaf.IsSheaf (F ⋙ (forget CommRingCat))) :
    F.IsSheaf :=
(isSheaf_iff_isSheaf_comp (forget CommRingCat) F).mpr h

end TopCat.Presheaf
