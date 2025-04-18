import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2020 Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bhavik Mehta
-/
import Mathlib.CategoryTheory.Limits.Shapes.SplitCoequalizer
import Mathlib.CategoryTheory.Limits.Shapes.SplitEqualizer
import Mathlib.CategoryTheory.Limits.Preserves.Basic

/-!
# Preserving (co)equalizers

Constructions to relate the notions of preserving (co)equalizers and reflecting (co)equalizers
to concrete (co)forks.

In particular, we show that `equalizerComparison f g G` is an isomorphism iff `G` preserves
the limit of the parallel pair `f,g`, as well as the dual result.
-/


noncomputable section

universe w v₁ v₂ u₁ u₂

open CategoryTheory CategoryTheory.Category CategoryTheory.Limits

variable {C : Type u₁} [Category.{v₁} C]
variable {D : Type u₂} [Category.{v₂} D]
variable (G : C ⥤ D)

namespace CategoryTheory.Limits

section Equalizers

variable {X Y Z : C} {f g : X ⟶ Y} {h : Z ⟶ X} (w : h ≫ f = h ≫ g)

/-- The map of a fork is a limit iff the fork consisting of the mapped morphisms is a limit. This
essentially lets us commute `Fork.ofι` with `Functor.mapCone`.
-/
def isLimitMapConeForkEquiv :
    IsLimit (G.mapCone (Fork.ofι h w)) ≃
      IsLimit (Fork.ofι (G.map h) (by simp only [← G.map_comp, w]) : Fork (G.map f) (G.map g)) :=
  (IsLimit.postcomposeHomEquiv (diagramIsoParallelPair _) _).symm.trans
    (IsLimit.equivIsoLimit (Fork.ext (Iso.refl _) (by simp [Fork.ι])))

/-- The property of preserving equalizers expressed in terms of forks. -/
def isLimitForkMapOfIsLimit [PreservesLimit (parallelPair f g) G] (l : IsLimit (Fork.ofι h w)) :
    IsLimit (Fork.ofι (G.map h) (by simp only [← G.map_comp, w]) : Fork (G.map f) (G.map g)) :=
  isLimitMapConeForkEquiv G w (PreservesLimit.preserves l)

/-- The property of reflecting equalizers expressed in terms of forks. -/
def isLimitOfIsLimitForkMap [ReflectsLimit (parallelPair f g) G]
    (l : IsLimit (Fork.ofι (G.map h) (by simp only [← G.map_comp, w]) : Fork (G.map f) (G.map g))) :
    IsLimit (Fork.ofι h w) :=
  ReflectsLimit.reflects ((isLimitMapConeForkEquiv G w).symm l)

variable (f g)
variable [HasEqualizer f g]

/--
If `G` preserves equalizers and `C` has them, then the fork constructed of the mapped morphisms of
a fork is a limit.
-/
def isLimitOfHasEqualizerOfPreservesLimit [PreservesLimit (parallelPair f g) G] :
    IsLimit (Fork.ofι
      (G.map (equalizer.ι f g)) (by simp only [← G.map_comp]; rw [equalizer.condition]) :
      Fork (G.map f) (G.map g)) :=
  isLimitForkMapOfIsLimit G _ (equalizerIsEqualizer f g)

variable [HasEqualizer (G.map f) (G.map g)]

/-- If the equalizer comparison map for `G` at `(f,g)` is an isomorphism, then `G` preserves the
equalizer of `(f,g)`.
-/
def PreservesEqualizer.ofIsoComparison [i : IsIso (equalizerComparison f g G)] :
    PreservesLimit (parallelPair f g) G := by
  apply preservesLimitOfPreservesLimitCone (equalizerIsEqualizer f g)
  apply (isLimitMapConeForkEquiv _ _).symm _
  refine @IsLimit.ofPointIso _ _ _ _ _ _ _ (limit.isLimit (parallelPair (G.map f) (G.map g))) ?_
  apply i

variable [PreservesLimit (parallelPair f g) G]

/--
If `G` preserves the equalizer of `(f,g)`, then the equalizer comparison map for `G` at `(f,g)` is
an isomorphism.
-/
def PreservesEqualizer.iso : G.obj (equalizer f g) ≅ equalizer (G.map f) (G.map g) :=
  IsLimit.conePointUniqueUpToIso (isLimitOfHasEqualizerOfPreservesLimit G f g) (limit.isLimit _)

@[simp]
theorem PreservesEqualizer.iso_hom :
    (PreservesEqualizer.iso G f g).hom = equalizerComparison f g G :=
  rfl

@[simp]
theorem PreservesEqualizer.iso_inv_ι :
    (PreservesEqualizer.iso G f g).inv ≫ G.map (equalizer.ι f g) =
      equalizer.ι (G.map f) (G.map g) := by
  rw [← Iso.cancel_iso_hom_left (PreservesEqualizer.iso G f g), ← Category.assoc, Iso.hom_inv_id]
  simp

instance : IsIso (equalizerComparison f g G) := by
  rw [← PreservesEqualizer.iso_hom]
  infer_instance

end Equalizers

section Coequalizers

variable {X Y Z : C} {f g : X ⟶ Y} {h : Y ⟶ Z} (w : f ≫ h = g ≫ h)

/-- The map of a cofork is a colimit iff the cofork consisting of the mapped morphisms is a colimit.
This essentially lets us commute `Cofork.ofπ` with `Functor.mapCocone`.
-/
def isColimitMapCoconeCoforkEquiv :
    IsColimit (G.mapCocone (Cofork.ofπ h w)) ≃
      IsColimit
        (Cofork.ofπ (G.map h) (by simp only [← G.map_comp, w]) : Cofork (G.map f) (G.map g)) :=
  (IsColimit.precomposeInvEquiv (diagramIsoParallelPair _) _).symm.trans <|
    IsColimit.equivIsoColimit <|
      Cofork.ext (Iso.refl _) <| by
        dsimp only [Cofork.π, Cofork.ofπ_ι_app]
        dsimp; rw [Category.comp_id, Category.id_comp]

/-- The property of preserving coequalizers expressed in terms of coforks. -/
def isColimitCoforkMapOfIsColimit [PreservesColimit (parallelPair f g) G]
    (l : IsColimit (Cofork.ofπ h w)) :
    IsColimit
      (Cofork.ofπ (G.map h) (by simp only [← G.map_comp, w]) : Cofork (G.map f) (G.map g)) :=
  isColimitMapCoconeCoforkEquiv G w (PreservesColimit.preserves l)

/-- The property of reflecting coequalizers expressed in terms of coforks. -/
def isColimitOfIsColimitCoforkMap [ReflectsColimit (parallelPair f g) G]
    (l :
      IsColimit
        (Cofork.ofπ (G.map h) (by simp only [← G.map_comp, w]) : Cofork (G.map f) (G.map g))) :
    IsColimit (Cofork.ofπ h w) :=
  ReflectsColimit.reflects ((isColimitMapCoconeCoforkEquiv G w).symm l)

variable (f g)
variable [HasCoequalizer f g]

/--
If `G` preserves coequalizers and `C` has them, then the cofork constructed of the mapped morphisms
of a cofork is a colimit.
-/
def isColimitOfHasCoequalizerOfPreservesColimit [PreservesColimit (parallelPair f g) G] :
    IsColimit (Cofork.ofπ (G.map (coequalizer.π f g)) (by
      simp only [← G.map_comp]; rw [coequalizer.condition]) : Cofork (G.map f) (G.map g)) :=
  isColimitCoforkMapOfIsColimit G _ (coequalizerIsCoequalizer f g)

variable [HasCoequalizer (G.map f) (G.map g)]

/-- If the coequalizer comparison map for `G` at `(f,g)` is an isomorphism, then `G` preserves the
coequalizer of `(f,g)`.
-/
def ofIsoComparison [i : IsIso (coequalizerComparison f g G)] :
    PreservesColimit (parallelPair f g) G := by
  apply preservesColimitOfPreservesColimitCocone (coequalizerIsCoequalizer f g)
  apply (isColimitMapCoconeCoforkEquiv _ _).symm _
  refine
    @IsColimit.ofPointIso _ _ _ _ _ _ _ (colimit.isColimit (parallelPair (G.map f) (G.map g))) ?_
  apply i

variable [PreservesColimit (parallelPair f g) G]

/--
If `G` preserves the coequalizer of `(f,g)`, then the coequalizer comparison map for `G` at `(f,g)`
is an isomorphism.
-/
def PreservesCoequalizer.iso : coequalizer (G.map f) (G.map g) ≅ G.obj (coequalizer f g) :=
  IsColimit.coconePointUniqueUpToIso (colimit.isColimit _)
    (isColimitOfHasCoequalizerOfPreservesColimit G f g)

@[simp]
theorem PreservesCoequalizer.iso_hom :
    (PreservesCoequalizer.iso G f g).hom = coequalizerComparison f g G :=
  rfl

instance : IsIso (coequalizerComparison f g G) := by
  rw [← PreservesCoequalizer.iso_hom]
  infer_instance

instance map_π_epi : Epi (G.map (coequalizer.π f g)) :=
  ⟨fun {W} h k => by
    rw [← ι_comp_coequalizerComparison]
    haveI : Epi (coequalizer.π (G.map f) (G.map g) ≫ coequalizerComparison f g G) := by
      apply epi_comp
    apply (cancel_epi _).1⟩

@[reassoc]
theorem map_π_preserves_coequalizer_inv :
    G.map (coequalizer.π f g) ≫ (PreservesCoequalizer.iso G f g).inv =
      coequalizer.π (G.map f) (G.map g) := by
  rw [← ι_comp_coequalizerComparison_assoc, ← PreservesCoequalizer.iso_hom, Iso.hom_inv_id,
    comp_id]

@[reassoc]
theorem map_π_preserves_coequalizer_inv_desc {W : D} (k : G.obj Y ⟶ W)
    (wk : G.map f ≫ k = G.map g ≫ k) : G.map (coequalizer.π f g) ≫
      (PreservesCoequalizer.iso G f g).inv ≫ coequalizer.desc k wk = k := by
  rw [← Category.assoc, map_π_preserves_coequalizer_inv, coequalizer.π_desc]

@[reassoc]
theorem map_π_preserves_coequalizer_inv_colimMap {X' Y' : D} (f' g' : X' ⟶ Y')
    [HasCoequalizer f' g'] (p : G.obj X ⟶ X') (q : G.obj Y ⟶ Y') (wf : G.map f ≫ q = p ≫ f')
    (wg : G.map g ≫ q = p ≫ g') :
    G.map (coequalizer.π f g) ≫
        (PreservesCoequalizer.iso G f g).inv ≫
          colimMap (parallelPairHom (G.map f) (G.map g) f' g' p q wf wg) =
      q ≫ coequalizer.π f' g' := by
  rw [← Category.assoc, map_π_preserves_coequalizer_inv, ι_colimMap, parallelPairHom_app_one]

@[reassoc]
theorem map_π_preserves_coequalizer_inv_colimMap_desc {X' Y' : D} (f' g' : X' ⟶ Y')
    [HasCoequalizer f' g'] (p : G.obj X ⟶ X') (q : G.obj Y ⟶ Y') (wf : G.map f ≫ q = p ≫ f')
    (wg : G.map g ≫ q = p ≫ g') {Z' : D} (h : Y' ⟶ Z') (wh : f' ≫ h = g' ≫ h) :
    G.map (coequalizer.π f g) ≫
        (PreservesCoequalizer.iso G f g).inv ≫
          colimMap (parallelPairHom (G.map f) (G.map g) f' g' p q wf wg) ≫ coequalizer.desc h wh =
      q ≫ h := by
  slice_lhs 1 3 => rw [map_π_preserves_coequalizer_inv_colimMap]
  slice_lhs 2 3 => rw [coequalizer.π_desc]

/-- Any functor preserves coequalizers of split pairs. -/
instance (priority := 1) preservesSplitCoequalizers (f g : X ⟶ Y) [HasSplitCoequalizer f g] :
    PreservesColimit (parallelPair f g) G := by
  apply
    preservesColimitOfPreservesColimitCocone
      (HasSplitCoequalizer.isSplitCoequalizer f g).isCoequalizer
  apply
    (isColimitMapCoconeCoforkEquiv G _).symm
      ((HasSplitCoequalizer.isSplitCoequalizer f g).map G).isCoequalizer

instance (priority := 1) preservesSplitEqualizers (f g : X ⟶ Y) [HasSplitEqualizer f g] :
    PreservesLimit (parallelPair f g) G := by
  apply
    preservesLimitOfPreservesLimitCone
      (HasSplitEqualizer.isSplitEqualizer f g).isEqualizer
  apply
    (isLimitMapConeForkEquiv G _).symm
      ((HasSplitEqualizer.isSplitEqualizer f g).map G).isEqualizer

end Coequalizers

end CategoryTheory.Limits
