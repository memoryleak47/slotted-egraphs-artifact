import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2015 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura, Jeremy Avigad, Minchao Wu, Mario Carneiro
-/
import Mathlib.Algebra.Group.Embedding
import Mathlib.Data.Fin.Basic
import Mathlib.Data.Finset.Union

/-! # Image and map operations on finite sets

This file provides the finite analog of `Set.image`, along with some other similar functions.

Note there are two ways to take the image over a finset; via `Finset.image` which applies the
function then removes duplicates (requiring `DecidableEq`), or via `Finset.map` which exploits
injectivity of the function to avoid needing to deduplicate. Choosing between these is similar to
choosing between `insert` and `Finset.cons`, or between `Finset.union` and `Finset.disjUnion`.

## Main definitions

* `Finset.image`: Given a function `f : α → β`, `s.image f` is the image finset in `β`.
* `Finset.map`: Given an embedding `f : α ↪ β`, `s.map f` is the image finset in `β`.
* `Finset.filterMap` Given a function `f : α → Option β`, `s.filterMap f` is the
  image finset in `β`, filtering out `none`s.
* `Finset.subtype`: `s.subtype p` is the finset of `Subtype p` whose elements belong to `s`.
* `Finset.fin`:`s.fin n` is the finset of all elements of `s` less than `n`.

## TODO

Move the material about `Finset.range` so that the `Mathlib.Algebra.Group.Embedding` import can be
removed.
-/

-- TODO
-- assert_not_exists OrderedCommMonoid
assert_not_exists MonoidWithZero
assert_not_exists MulAction

variable {α β γ : Type*}

open Multiset

open Function

namespace Finset

/-! ### map -/


section Map

open Function

/-- When `f` is an embedding of `α` in `β` and `s` is a finset in `α`, then `s.map f` is the image
finset in `β`. The embedding condition guarantees that there are no duplicates in the image. -/
def map (f : α ↪ β) (s : Finset α) : Finset β :=
  ⟨s.1.map f, s.2.map f.2⟩

@[simp]
theorem map_val (f : α ↪ β) (s : Finset α) : (map f s).1 = s.1.map f :=
  rfl

@[simp]
theorem map_empty (f : α ↪ β) : (∅ : Finset α).map f = ∅ :=
  rfl

variable {f : α ↪ β} {s : Finset α}

@[simp]
theorem mem_map {b : β} : b ∈ s.map f ↔ ∃ a ∈ s, f a = b :=
  Multiset.mem_map

-- Porting note: Higher priority to apply before `mem_map`.
@[simp 1100]
theorem mem_map_equiv {f : α ≃ β} {b : β} : b ∈ s.map f.toEmbedding ↔ f.symm b ∈ s := by
  rw [mem_map]
  exact
    ⟨by
      rintro ⟨a, H, rfl⟩
      simpa, fun h => ⟨_, h, by simp⟩⟩

@[simp 1100]
theorem mem_map' (f : α ↪ β) {a} {s : Finset α} : f a ∈ s.map f ↔ a ∈ s :=
  mem_map_of_injective f.2

theorem mem_map_of_mem (f : α ↪ β) {a} {s : Finset α} : a ∈ s → f a ∈ s.map f :=
  (mem_map' _).2

theorem forall_mem_map {f : α ↪ β} {s : Finset α} {p : ∀ a, a ∈ s.map f → Prop} :
    (∀ y (H : y ∈ s.map f), p y H) ↔ ∀ x (H : x ∈ s), p (f x) (mem_map_of_mem _ H) :=
  ⟨fun h y hy => h (f y) (mem_map_of_mem _ hy),
   fun h x hx => by
    obtain ⟨y, hy, rfl⟩ := mem_map.1 hx
    exact h _ hy⟩

theorem apply_coe_mem_map (f : α ↪ β) (s : Finset α) (x : s) : f x ∈ s.map f :=
  mem_map_of_mem f x.prop

@[simp, norm_cast]
theorem coe_map (f : α ↪ β) (s : Finset α) : (s.map f : Set β) = f '' s :=
  Set.ext (by simp only [mem_coe, mem_map, Set.mem_image, implies_true])

theorem coe_map_subset_range (f : α ↪ β) (s : Finset α) : (s.map f : Set β) ⊆ Set.range f :=
  calc
    ↑(s.map f) = f '' s := coe_map f s
    _ ⊆ Set.range f := Set.image_subset_range f ↑s

/-- If the only elements outside `s` are those left fixed by `σ`, then mapping by `σ` has no effect.
-/
theorem map_perm {σ : Equiv.Perm α} (hs : { a | σ a ≠ a } ⊆ s) : s.map (σ : α ↪ α) = s :=
  coe_injective <| (coe_map _ _).trans <| Set.image_perm hs

theorem map_toFinset [DecidableEq α] [DecidableEq β] {s : Multiset α} :
    s.toFinset.map f = (s.map f).toFinset :=
  ext fun _ => by simp only [mem_map, Multiset.mem_map, exists_prop, Multiset.mem_toFinset]

@[simp]
theorem map_refl : s.map (Embedding.refl _) = s :=
  ext fun _ => by simpa only [mem_map, exists_prop] using exists_eq_right

@[simp]
theorem map_cast_heq {α β} (h : α = β) (s : Finset α) :
    HEq (s.map (Equiv.cast h).toEmbedding) s := by
  subst h
  simp

theorem map_map (f : α ↪ β) (g : β ↪ γ) (s : Finset α) : (s.map f).map g = s.map (f.trans g) :=
  eq_of_veq <| by simp only [map_val, Multiset.map_map]; rfl

theorem map_comm {β'} {f : β ↪ γ} {g : α ↪ β} {f' : α ↪ β'} {g' : β' ↪ γ}
    (h_comm : ∀ a, f (g a) = g' (f' a)) : (s.map g).map f = (s.map f').map g' := by
  simp_rw [map_map, Embedding.trans, Function.comp_def, h_comm]

theorem _root_.Function.Semiconj.finset_map {f : α ↪ β} {ga : α ↪ α} {gb : β ↪ β}
    (h : Function.Semiconj f ga gb) : Function.Semiconj (map f) (map ga) (map gb) := fun _ =>
  map_comm h

theorem _root_.Function.Commute.finset_map {f g : α ↪ α} (h : Function.Commute f g) :
    Function.Commute (map f) (map g) :=
  Function.Semiconj.finset_map h

@[simp]
theorem map_subset_map {s₁ s₂ : Finset α} : s₁.map f ⊆ s₂.map f ↔ s₁ ⊆ s₂ :=
  ⟨fun h _ xs => (mem_map' _).1 <| h <| (mem_map' f).2 xs,
   fun h => by simp [subset_def, Multiset.map_subset_map h]⟩

@[gcongr] alias ⟨_, _root_.GCongr.finsetMap_subset⟩ := map_subset_map

/-- The `Finset` version of `Equiv.subset_symm_image`. -/
theorem subset_map_symm {t : Finset β} {f : α ≃ β} : s ⊆ t.map f.symm ↔ s.map f ⊆ t := by
  constructor <;> intro h x hx
  · simp only [mem_map_equiv, Equiv.symm_symm] at hx
    simpa using h hx
  · simp only [mem_map_equiv]
    exact h (by simp [hx])

/-- The `Finset` version of `Equiv.symm_image_subset`. -/
theorem map_symm_subset {t : Finset β} {f : α ≃ β} : t.map f.symm ⊆ s ↔ t ⊆ s.map f := by
  simp only [← subset_map_symm, Equiv.symm_symm]

/-- Associate to an embedding `f` from `α` to `β` the order embedding that maps a finset to its
image under `f`. -/
def mapEmbedding (f : α ↪ β) : Finset α ↪o Finset β :=
  OrderEmbedding.ofMapLEIff (map f) fun _ _ => map_subset_map

@[simp]
theorem map_inj {s₁ s₂ : Finset α} : s₁.map f = s₂.map f ↔ s₁ = s₂ :=
  (mapEmbedding f).injective.eq_iff

theorem map_injective (f : α ↪ β) : Injective (map f) :=
  (mapEmbedding f).injective

@[simp]
theorem map_ssubset_map {s t : Finset α} : s.map f ⊂ t.map f ↔ s ⊂ t := (mapEmbedding f).lt_iff_lt

@[gcongr] alias ⟨_, _root_.GCongr.finsetMap_ssubset⟩ := map_ssubset_map

@[simp]
theorem mapEmbedding_apply : mapEmbedding f s = map f s :=
  rfl

theorem filter_map {p : β → Prop} [DecidablePred p] :
    (s.map f).filter p = (s.filter (p ∘ f)).map f :=
  eq_of_veq (Multiset.filter_map _ _ _)

lemma map_filter' (p : α → Prop) [DecidablePred p] (f : α ↪ β) (s : Finset α)
    [DecidablePred (∃ a, p a ∧ f a = ·)] :
    (s.filter p).map f = (s.map f).filter fun b => ∃ a, p a ∧ f a = b := by
  simp [Function.comp_def, filter_map, f.injective.eq_iff]

lemma filter_attach' [DecidableEq α] (s : Finset α) (p : s → Prop) [DecidablePred p] :
    s.attach.filter p =
      (s.filter fun x => ∃ h, p ⟨x, h⟩).attach.map
        ⟨Subtype.map id <| filter_subset _ _, Subtype.map_injective _ injective_id⟩ :=
  eq_of_veq <| Multiset.filter_attach' _ _

lemma filter_attach (p : α → Prop) [DecidablePred p] (s : Finset α) :
    s.attach.filter (fun a : s ↦ p a) =
      (s.filter p).attach.map ((Embedding.refl _).subtypeMap mem_of_mem_filter) :=
  eq_of_veq <| Multiset.filter_attach _ _

theorem map_filter {f : α ≃ β} {p : α → Prop} [DecidablePred p] :
    (s.filter p).map f.toEmbedding = (s.map f.toEmbedding).filter (p ∘ f.symm) := by
  simp only [filter_map, Function.comp_def, Equiv.toEmbedding_apply, Equiv.symm_apply_apply]

@[simp]
theorem disjoint_map {s t : Finset α} (f : α ↪ β) :
    Disjoint (s.map f) (t.map f) ↔ Disjoint s t :=
  mod_cast Set.disjoint_image_iff f.injective (s := s) (t := t)

theorem map_disjUnion {f : α ↪ β} (s₁ s₂ : Finset α) (h) (h' := (disjoint_map _).mpr h) :
    (s₁.disjUnion s₂ h).map f = (s₁.map f).disjUnion (s₂.map f) h' :=
  eq_of_veq <| Multiset.map_add _ _ _

/-- A version of `Finset.map_disjUnion` for writing in the other direction. -/
theorem map_disjUnion' {f : α ↪ β} (s₁ s₂ : Finset α) (h') (h := (disjoint_map _).mp h') :
    (s₁.disjUnion s₂ h).map f = (s₁.map f).disjUnion (s₂.map f) h' :=
  map_disjUnion _ _ _

theorem map_union [DecidableEq α] [DecidableEq β] {f : α ↪ β} (s₁ s₂ : Finset α) :
    (s₁ ∪ s₂).map f = s₁.map f ∪ s₂.map f :=
  mod_cast Set.image_union f s₁ s₂

theorem map_inter [DecidableEq α] [DecidableEq β] {f : α ↪ β} (s₁ s₂ : Finset α) :
    (s₁ ∩ s₂).map f = s₁.map f ∩ s₂.map f :=
  mod_cast Set.image_inter f.injective (s := s₁) (t := s₂)

@[simp]
theorem map_singleton (f : α ↪ β) (a : α) : map f {a} = {f a} :=
  coe_injective <| by simp only [coe_map, coe_singleton, Set.image_singleton]

@[simp]
theorem map_insert [DecidableEq α] [DecidableEq β] (f : α ↪ β) (a : α) (s : Finset α) :
    (insert a s).map f = insert (f a) (s.map f) := by
  simp only [insert_eq, map_union, map_singleton]

@[simp]
theorem map_cons (f : α ↪ β) (a : α) (s : Finset α) (ha : a ∉ s) :
    (cons a s ha).map f = cons (f a) (s.map f) (by simpa using ha) :=
  eq_of_veq <| Multiset.map_cons f a s.val

@[simp]
theorem map_eq_empty : s.map f = ∅ ↔ s = ∅ := (map_injective f).eq_iff' (map_empty f)

@[simp]
theorem map_nonempty : (s.map f).Nonempty ↔ s.Nonempty :=
  mod_cast Set.image_nonempty (f := f) (s := s)

@[aesop safe apply (rule_sets := [finsetNonempty])]
protected alias ⟨_, Nonempty.map⟩ := map_nonempty

@[simp]
theorem map_nontrivial : (s.map f).Nontrivial ↔ s.Nontrivial :=
  mod_cast Set.image_nontrivial f.injective (s := s)

theorem attach_map_val {s : Finset α} : s.attach.map (Embedding.subtype _) = s :=
  eq_of_veq <| by rw [map_val, attach_val]; exact Multiset.attach_map_val _

theorem disjoint_range_addLeftEmbedding (a : ℕ) (s : Finset ℕ) :
    Disjoint (range a) (map (addLeftEmbedding a) s) := by
  simp_rw [disjoint_left, mem_map, mem_range, addLeftEmbedding_apply]
  rintro _ h ⟨l, -, rfl⟩
  omega

theorem disjoint_range_addRightEmbedding (a : ℕ) (s : Finset ℕ) :
    Disjoint (range a) (map (addRightEmbedding a) s) := by
  rw [← addLeftEmbedding_eq_addRightEmbedding]
  apply disjoint_range_addLeftEmbedding

theorem map_disjiUnion {f : α ↪ β} {s : Finset α} {t : β → Finset γ} {h} :
    (s.map f).disjiUnion t h =
      s.disjiUnion (fun a => t (f a)) fun _ ha _ hb hab =>
        h (mem_map_of_mem _ ha) (mem_map_of_mem _ hb) (f.injective.ne hab) :=
  eq_of_veq <| Multiset.bind_map _ _ _

theorem disjiUnion_map {s : Finset α} {t : α → Finset β} {f : β ↪ γ} {h} :
    (s.disjiUnion t h).map f =
      s.disjiUnion (fun a => (t a).map f) (h.mono' fun _ _ ↦ (disjoint_map _).2) :=
  eq_of_veq <| Multiset.map_bind _ _ _

end Map

theorem range_add_one' (n : ℕ) :
    range (n + 1) = insert 0 ((range n).map ⟨fun i => i + 1, fun i j => by simp⟩) := by
  ext (⟨⟩ | ⟨n⟩) <;> simp [Nat.zero_lt_succ n]

/-! ### image -/


section Image

variable [DecidableEq β]

/-- `image f s` is the forward image of `s` under `f`. -/
def image (f : α → β) (s : Finset α) : Finset β :=
  (s.1.map f).toFinset

@[simp]
theorem image_val (f : α → β) (s : Finset α) : (image f s).1 = (s.1.map f).dedup :=
  rfl

@[simp]
theorem image_empty (f : α → β) : (∅ : Finset α).image f = ∅ :=
  rfl

variable {f g : α → β} {s : Finset α} {t : Finset β} {a : α} {b c : β}

@[simp]
theorem mem_image : b ∈ s.image f ↔ ∃ a ∈ s, f a = b := by
  simp only [mem_def, image_val, mem_dedup, Multiset.mem_map, exists_prop]

theorem mem_image_of_mem (f : α → β) {a} (h : a ∈ s) : f a ∈ s.image f :=
  mem_image.2 ⟨_, h, rfl⟩

theorem forall_image {p : β → Prop} : (∀ b ∈ s.image f, p b) ↔ ∀ a ∈ s, p (f a) := by
  simp only [mem_image, forall_exists_index, and_imp, forall_apply_eq_imp_iff₂]

theorem map_eq_image (f : α ↪ β) (s : Finset α) : s.map f = s.image f :=
  eq_of_veq (s.map f).2.dedup.symm

--@[simp] Porting note: removing simp, `simp` [Nonempty] can prove it
theorem mem_image_const : c ∈ s.image (const α b) ↔ s.Nonempty ∧ b = c := by
  rw [mem_image]
  simp only [exists_prop, const_apply, exists_and_right]
  rfl

theorem mem_image_const_self : b ∈ s.image (const α b) ↔ s.Nonempty :=
  mem_image_const.trans <| and_iff_left rfl

instance canLift (c) (p) [CanLift β α c p] :
    CanLift (Finset β) (Finset α) (image c) fun s => ∀ x ∈ s, p x where
  prf := by
    rintro ⟨⟨l⟩, hd : l.Nodup⟩ hl
    lift l to List α using hl
    exact ⟨⟨l, hd.of_map _⟩, ext fun a => by simp⟩

theorem image_congr (h : (s : Set α).EqOn f g) : Finset.image f s = Finset.image g s := by
  ext
  simp_rw [mem_image, ← bex_def]
  exact exists₂_congr fun x hx => by rw [h hx]

theorem _root_.Function.Injective.mem_finset_image (hf : Injective f) :
    f a ∈ s.image f ↔ a ∈ s := by
  refine ⟨fun h => ?_, Finset.mem_image_of_mem f⟩
  obtain ⟨y, hy, heq⟩ := mem_image.1 h
  exact hf heq ▸ hy


@[simp, norm_cast]
theorem coe_image : ↑(s.image f) = f '' ↑s :=
  Set.ext <| by simp only [mem_coe, mem_image, Set.mem_image, implies_true]

@[simp]
lemma image_nonempty : (s.image f).Nonempty ↔ s.Nonempty :=
  mod_cast Set.image_nonempty (f := f) (s := (s : Set α))

@[aesop safe apply (rule_sets := [finsetNonempty])]
protected theorem Nonempty.image (h : s.Nonempty) (f : α → β) : (s.image f).Nonempty :=
  image_nonempty.2 h

alias ⟨Nonempty.of_image, _⟩ := image_nonempty

@[deprecated image_nonempty (since := "2023-12-29")]
theorem Nonempty.image_iff (f : α → β) : (s.image f).Nonempty ↔ s.Nonempty :=
  image_nonempty

theorem image_toFinset [DecidableEq α] {s : Multiset α} :
    s.toFinset.image f = (s.map f).toFinset :=
  ext fun _ => by simp only [mem_image, Multiset.mem_toFinset, exists_prop, Multiset.mem_map]

theorem image_val_of_injOn (H : Set.InjOn f s) : (image f s).1 = s.1.map f :=
  (s.2.map_on H).dedup

@[simp]
theorem image_id [DecidableEq α] : s.image id = s :=
  ext fun _ => by simp only [mem_image, exists_prop, id, exists_eq_right]

@[simp]
theorem image_id' [DecidableEq α] : (s.image fun x => x) = s :=
  image_id

theorem image_image [DecidableEq γ] {g : β → γ} : (s.image f).image g = s.image (g ∘ f) :=
  eq_of_veq <| by simp only [image_val, dedup_map_dedup_eq, Multiset.map_map]

theorem image_comm {β'} [DecidableEq β'] [DecidableEq γ] {f : β → γ} {g : α → β} {f' : α → β'}
    {g' : β' → γ} (h_comm : ∀ a, f (g a) = g' (f' a)) :
    (s.image g).image f = (s.image f').image g' := by simp_rw [image_image, comp_def, h_comm]

theorem _root_.Function.Semiconj.finset_image [DecidableEq α] {f : α → β} {ga : α → α} {gb : β → β}
    (h : Function.Semiconj f ga gb) : Function.Semiconj (image f) (image ga) (image gb) := fun _ =>
  image_comm h

theorem _root_.Function.Commute.finset_image [DecidableEq α] {f g : α → α}
    (h : Function.Commute f g) : Function.Commute (image f) (image g) :=
  Function.Semiconj.finset_image h

theorem image_subset_image {s₁ s₂ : Finset α} (h : s₁ ⊆ s₂) : s₁.image f ⊆ s₂.image f := by
  simp only [subset_def, image_val, subset_dedup', dedup_subset', Multiset.map_subset_map h]

theorem image_subset_iff : s.image f ⊆ t ↔ ∀ x ∈ s, f x ∈ t :=
  calc
    s.image f ⊆ t ↔ f '' ↑s ⊆ ↑t := by norm_cast
    _ ↔ _ := Set.image_subset_iff

theorem image_mono (f : α → β) : Monotone (Finset.image f) := fun _ _ => image_subset_image

lemma image_injective (hf : Injective f) : Injective (image f) := by
  simpa only [funext (map_eq_image _)] using map_injective ⟨f, hf⟩

lemma image_inj {t : Finset α} (hf : Injective f) : s.image f = t.image f ↔ s = t :=
  (image_injective hf).eq_iff

theorem image_subset_image_iff {t : Finset α} (hf : Injective f) :
    s.image f ⊆ t.image f ↔ s ⊆ t :=
  mod_cast Set.image_subset_image_iff hf (s := s) (t := t)

lemma image_ssubset_image {t : Finset α} (hf : Injective f) : s.image f ⊂ t.image f ↔ s ⊂ t := by
  simp_rw [← lt_iff_ssubset]
  exact lt_iff_lt_of_le_iff_le' (image_subset_image_iff hf) (image_subset_image_iff hf)

theorem coe_image_subset_range : ↑(s.image f) ⊆ Set.range f :=
  calc
    ↑(s.image f) = f '' ↑s := coe_image
    _ ⊆ Set.range f := Set.image_subset_range f ↑s

theorem filter_image {p : β → Prop} [DecidablePred p] :
    (s.image f).filter p = (s.filter fun a ↦ p (f a)).image f :=
  ext fun b => by
    simp only [mem_filter, mem_image, exists_prop]
    exact
      ⟨by rintro ⟨⟨x, h1, rfl⟩, h2⟩; exact ⟨x, ⟨h1, h2⟩, rfl⟩,
       by rintro ⟨x, ⟨h1, h2⟩, rfl⟩; exact ⟨⟨x, h1, rfl⟩, h2⟩⟩

@[deprecated filter_mem_eq_inter (since := "2024-09-15")]
theorem filter_mem_image_eq_image (f : α → β) (s : Finset α) (t : Finset β) (h : ∀ x ∈ s, f x ∈ t) :
    (t.filter fun y => y ∈ s.image f) = s.image f := by
  rwa [filter_mem_eq_inter, inter_eq_right, image_subset_iff]

theorem fiber_nonempty_iff_mem_image {y : β} : (s.filter (f · = y)).Nonempty ↔ y ∈ s.image f := by
  simp [Finset.Nonempty]

theorem image_union [DecidableEq α] {f : α → β} (s₁ s₂ : Finset α) :
    (s₁ ∪ s₂).image f = s₁.image f ∪ s₂.image f :=
  mod_cast Set.image_union f s₁ s₂

theorem image_inter_subset [DecidableEq α] (f : α → β) (s t : Finset α) :
    (s ∩ t).image f ⊆ s.image f ∩ t.image f :=
  (image_mono f).map_inf_le s t

theorem image_inter_of_injOn [DecidableEq α] {f : α → β} (s t : Finset α)
    (hf : Set.InjOn f (s ∪ t)) : (s ∩ t).image f = s.image f ∩ t.image f :=
  coe_injective <| by
    push_cast
    exact Set.image_inter_on fun a ha b hb => hf (Or.inr ha) <| Or.inl hb

theorem image_inter [DecidableEq α] (s₁ s₂ : Finset α) (hf : Injective f) :
    (s₁ ∩ s₂).image f = s₁.image f ∩ s₂.image f :=
  image_inter_of_injOn _ _ hf.injOn

@[simp]
theorem image_singleton (f : α → β) (a : α) : image f {a} = {f a} :=
  ext fun x => by simpa only [mem_image, exists_prop, mem_singleton, exists_eq_left] using eq_comm

@[simp]
theorem image_insert [DecidableEq α] (f : α → β) (a : α) (s : Finset α) :
    (insert a s).image f = insert (f a) (s.image f) := by
  simp only [insert_eq, image_singleton, image_union]

theorem erase_image_subset_image_erase [DecidableEq α] (f : α → β) (s : Finset α) (a : α) :
    (s.image f).erase (f a) ⊆ (s.erase a).image f := by
  simp only [subset_iff, and_imp, exists_prop, mem_image, exists_imp, mem_erase]
  rintro b hb x hx rfl
  exact ⟨_, ⟨ne_of_apply_ne f hb, hx⟩, rfl⟩

@[simp]
theorem image_erase [DecidableEq α] {f : α → β} (hf : Injective f) (s : Finset α) (a : α) :
    (s.erase a).image f = (s.image f).erase (f a) :=
  coe_injective <| by push_cast [Set.image_diff hf, Set.image_singleton]; rfl

@[simp]
theorem image_eq_empty : s.image f = ∅ ↔ s = ∅ := mod_cast Set.image_eq_empty (f := f) (s := s)

theorem image_sdiff [DecidableEq α] {f : α → β} (s t : Finset α) (hf : Injective f) :
    (s \ t).image f = s.image f \ t.image f :=
  mod_cast Set.image_diff hf s t

open scoped symmDiff in
theorem image_symmDiff [DecidableEq α] {f : α → β} (s t : Finset α) (hf : Injective f) :
    (s ∆ t).image f = s.image f ∆ t.image f :=
  mod_cast Set.image_symmDiff hf s t

@[simp]
theorem _root_.Disjoint.of_image_finset {s t : Finset α} {f : α → β}
    (h : Disjoint (s.image f) (t.image f)) : Disjoint s t :=
  disjoint_iff_ne.2 fun _ ha _ hb =>
    ne_of_apply_ne f <| h.forall_ne_finset (mem_image_of_mem _ ha) (mem_image_of_mem _ hb)

theorem mem_range_iff_mem_finset_range_of_mod_eq' [DecidableEq α] {f : ℕ → α} {a : α} {n : ℕ}
    (hn : 0 < n) (h : ∀ i, f (i % n) = f i) :
    a ∈ Set.range f ↔ a ∈ (Finset.range n).image fun i => f i := by
  constructor
  · rintro ⟨i, hi⟩
    simp only [mem_image, exists_prop, mem_range]
    exact ⟨i % n, Nat.mod_lt i hn, (rfl.congr hi).mp (h i)⟩
  · rintro h
    simp only [mem_image, exists_prop, Set.mem_range, mem_range] at *
    rcases h with ⟨i, _, ha⟩
    exact ⟨i, ha⟩

theorem mem_range_iff_mem_finset_range_of_mod_eq [DecidableEq α] {f : ℤ → α} {a : α} {n : ℕ}
    (hn : 0 < n) (h : ∀ i, f (i % n) = f i) :
    a ∈ Set.range f ↔ a ∈ (Finset.range n).image (fun (i : ℕ) => f i) :=
  suffices (∃ i, f (i % n) = a) ↔ ∃ i, i < n ∧ f ↑i = a by simpa [h]
  have hn' : 0 < (n : ℤ) := Int.ofNat_lt.mpr hn
  Iff.intro
    (fun ⟨i, hi⟩ =>
      have : 0 ≤ i % ↑n := Int.emod_nonneg _ (ne_of_gt hn')
      ⟨Int.toNat (i % n), by
        rw [← Int.ofNat_lt, Int.toNat_of_nonneg this]; exact ⟨Int.emod_lt_of_pos i hn', hi⟩⟩)
    fun ⟨i, hi, ha⟩ =>
    ⟨i, by rw [Int.emod_eq_of_lt (Int.ofNat_zero_le _) (Int.ofNat_lt_ofNat_of_lt hi), ha]⟩

theorem range_add (a b : ℕ) : range (a + b) = range a ∪ (range b).map (addLeftEmbedding a) := by
  rw [← val_inj, union_val]
  exact Multiset.range_add_eq_union a b

@[simp]
theorem attach_image_val [DecidableEq α] {s : Finset α} : s.attach.image Subtype.val = s :=
  eq_of_veq <| by rw [image_val, attach_val, Multiset.attach_map_val, dedup_eq_self]

@[simp]
theorem attach_insert [DecidableEq α] {a : α} {s : Finset α} :
    attach (insert a s) =
      insert (⟨a, mem_insert_self a s⟩ : { x // x ∈ insert a s })
        ((attach s).image fun x => ⟨x.1, mem_insert_of_mem x.2⟩) :=
  ext fun ⟨x, hx⟩ =>
    ⟨Or.casesOn (mem_insert.1 hx)
        (fun h : x = a => fun _ => mem_insert.2 <| Or.inl <| Subtype.eq h) fun h : x ∈ s => fun _ =>
        mem_insert_of_mem <| mem_image.2 <| ⟨⟨x, h⟩, mem_attach _ _, Subtype.eq rfl⟩,
      fun _ => Finset.mem_attach _ _⟩

@[simp]
theorem disjoint_image {s t : Finset α} {f : α → β} (hf : Injective f) :
    Disjoint (s.image f) (t.image f) ↔ Disjoint s t :=
  mod_cast Set.disjoint_image_iff hf (s := s) (t := t)

theorem image_const {s : Finset α} (h : s.Nonempty) (b : β) : (s.image fun _ => b) = singleton b :=
  mod_cast Set.Nonempty.image_const (coe_nonempty.2 h) b

@[simp]
theorem map_erase [DecidableEq α] (f : α ↪ β) (s : Finset α) (a : α) :
    (s.erase a).map f = (s.map f).erase (f a) := by
  simp_rw [map_eq_image]
  exact s.image_erase f.2 a

theorem image_biUnion [DecidableEq γ] {f : α → β} {s : Finset α} {t : β → Finset γ} :
    (s.image f).biUnion t = s.biUnion fun a => t (f a) :=
  haveI := Classical.decEq α
  Finset.induction_on s rfl fun a s _ ih => by simp only [image_insert, biUnion_insert, ih]

theorem biUnion_image [DecidableEq γ] {s : Finset α} {t : α → Finset β} {f : β → γ} :
    (s.biUnion t).image f = s.biUnion fun a => (t a).image f :=
  haveI := Classical.decEq α
  Finset.induction_on s rfl fun a s _ ih => by simp only [biUnion_insert, image_union, ih]

theorem image_biUnion_filter_eq [DecidableEq α] (s : Finset β) (g : β → α) :
    ((s.image g).biUnion fun a => s.filter fun c => g c = a) = s :=
  biUnion_filter_eq_of_maps_to fun _ => mem_image_of_mem g

theorem biUnion_singleton {f : α → β} : (s.biUnion fun a => {f a}) = s.image f :=
  ext fun x => by simp only [mem_biUnion, mem_image, mem_singleton, eq_comm]

end Image

/-! ### filterMap -/

section FilterMap

/-- `filterMap f s` is a combination filter/map operation on `s`.
  The function `f : α → Option β` is applied to each element of `s`;
  if `f a` is `some b` then `b` is included in the result, otherwise
  `a` is excluded from the resulting finset.

  In notation, `filterMap f s` is the finset `{b : β | ∃ a ∈ s , f a = some b}`. -/
-- TODO: should there be `filterImage` too?
def filterMap (f : α → Option β) (s : Finset α)
    (f_inj : ∀ a a' b, b ∈ f a → b ∈ f a' → a = a') : Finset β :=
  ⟨s.val.filterMap f, s.nodup.filterMap f f_inj⟩

variable (f : α → Option β) (s' : Finset α) {s t : Finset α}
  {f_inj : ∀ a a' b, b ∈ f a → b ∈ f a' → a = a'}

@[simp]
theorem filterMap_val : (filterMap f s' f_inj).1 = s'.1.filterMap f := rfl

@[simp]
theorem filterMap_empty : (∅ : Finset α).filterMap f f_inj = ∅ := rfl

@[simp]
theorem mem_filterMap {b : β} : b ∈ s.filterMap f f_inj ↔ ∃ a ∈ s, f a = some b :=
  s.val.mem_filterMap f

@[simp, norm_cast]
theorem coe_filterMap : (s.filterMap f f_inj : Set β) = {b | ∃ a ∈ s, f a = some b} :=
  Set.ext (by simp only [mem_coe, mem_filterMap, Option.mem_def, Set.mem_setOf_eq, implies_true])

@[simp]
theorem filterMap_some : s.filterMap some (by simp) = s :=
  ext fun _ => by simp only [mem_filterMap, Option.some.injEq, exists_eq_right]

theorem filterMap_mono (h : s ⊆ t) :
    filterMap f s f_inj ⊆ filterMap f t f_inj := by
  rw [← val_le_iff] at h ⊢
  exact Multiset.filterMap_le_filterMap f h

end FilterMap

/-! ### Subtype -/


section Subtype

/-- Given a finset `s` and a predicate `p`, `s.subtype p` is the finset of `Subtype p` whose
elements belong to `s`. -/
protected def subtype {α} (p : α → Prop) [DecidablePred p] (s : Finset α) : Finset (Subtype p) :=
  (s.filter p).attach.map
    ⟨fun x => ⟨x.1, by simpa using (Finset.mem_filter.1 x.2).2⟩,
     fun _ _ H => Subtype.eq <| Subtype.mk.inj H⟩

@[simp]
theorem mem_subtype {p : α → Prop} [DecidablePred p] {s : Finset α} :
    ∀ {a : Subtype p}, a ∈ s.subtype p ↔ (a : α) ∈ s
  | ⟨a, ha⟩ => by simp [Finset.subtype, ha]

theorem subtype_eq_empty {p : α → Prop} [DecidablePred p] {s : Finset α} :
    s.subtype p = ∅ ↔ ∀ x, p x → x ∉ s := by simp [Finset.ext_iff, Subtype.forall, Subtype.coe_mk]

@[mono]
theorem subtype_mono {p : α → Prop} [DecidablePred p] : Monotone (Finset.subtype p) :=
  fun _ _ h _ hx => mem_subtype.2 <| h <| mem_subtype.1 hx

/-- `s.subtype p` converts back to `s.filter p` with
`Embedding.subtype`. -/
@[simp]
theorem subtype_map (p : α → Prop) [DecidablePred p] {s : Finset α} :
    (s.subtype p).map (Embedding.subtype _) = s.filter p := by
  ext x
  simp [@and_comm _ (_ = _), @and_left_comm _ (_ = _), @and_comm (p x) (x ∈ s)]

/-- If all elements of a `Finset` satisfy the predicate `p`,
`s.subtype p` converts back to `s` with `Embedding.subtype`. -/
theorem subtype_map_of_mem {p : α → Prop} [DecidablePred p] {s : Finset α} (h : ∀ x ∈ s, p x) :
    (s.subtype p).map (Embedding.subtype _) = s := ext <| by simpa [subtype_map] using h

/-- If a `Finset` of a subtype is converted to the main type with
`Embedding.subtype`, all elements of the result have the property of
the subtype. -/
theorem property_of_mem_map_subtype {p : α → Prop} (s : Finset { x // p x }) {a : α}
    (h : a ∈ s.map (Embedding.subtype _)) : p a := by
  rcases mem_map.1 h with ⟨x, _, rfl⟩
  exact x.2

/-- If a `Finset` of a subtype is converted to the main type with
`Embedding.subtype`, the result does not contain any value that does
not satisfy the property of the subtype. -/
theorem not_mem_map_subtype_of_not_property {p : α → Prop} (s : Finset { x // p x }) {a : α}
    (h : ¬p a) : a ∉ s.map (Embedding.subtype _) :=
  mt s.property_of_mem_map_subtype h

/-- If a `Finset` of a subtype is converted to the main type with
`Embedding.subtype`, the result is a subset of the set giving the
subtype. -/
theorem map_subtype_subset {t : Set α} (s : Finset t) : ↑(s.map (Embedding.subtype _)) ⊆ t := by
  intro a ha
  rw [mem_coe] at ha
  convert property_of_mem_map_subtype s ha

end Subtype

/-! ### Fin -/


/-- Given a finset `s` of natural numbers and a bound `n`,
`s.fin n` is the finset of all elements of `s` less than `n`.
-/
protected def fin (n : ℕ) (s : Finset ℕ) : Finset (Fin n) :=
  (s.subtype _).map Fin.equivSubtype.symm.toEmbedding

@[simp]
theorem mem_fin {n} {s : Finset ℕ} : ∀ a : Fin n, a ∈ s.fin n ↔ (a : ℕ) ∈ s
  | ⟨a, ha⟩ => by simp [Finset.fin, ha, and_comm]

@[mono]
theorem fin_mono {n} : Monotone (Finset.fin n) := fun s t h x => by simpa using @h x

@[simp]
theorem fin_map {n} {s : Finset ℕ} : (s.fin n).map Fin.valEmbedding = s.filter (· < n) := by
  simp [Finset.fin, Finset.map_map]

/--
If a finset `t` is a subset of the image of another finset `s` under `f`, then it is equal to the
image of a subset of `s`.

For the version where `s` is a set, see `subset_set_image_iff`.
-/
theorem subset_image_iff [DecidableEq β] {s : Finset α} {t : Finset β} {f : α → β} :
    t ⊆ s.image f ↔ ∃ s' : Finset α, s' ⊆ s ∧ s'.image f = t := by
  refine ⟨fun ht => ?_, fun ⟨s', hs', h⟩ => h ▸ image_subset_image hs'⟩
  refine ⟨s.filter (f · ∈ t), filter_subset _ _, le_antisymm (by simp [image_subset_iff]) ?_⟩
  intro x hx
  specialize ht hx
  aesop

/-- If a `Finset` is a subset of the image of a `Set` under `f`,
then it is equal to the `Finset.image` of a `Finset` subset of that `Set`. -/
theorem subset_set_image_iff [DecidableEq β] {s : Set α} {t : Finset β} {f : α → β} :
    ↑t ⊆ f '' s ↔ ∃ s' : Finset α, ↑s' ⊆ s ∧ s'.image f = t := by
  constructor; swap
  · rintro ⟨t, ht, rfl⟩
    rw [coe_image]
    exact Set.image_subset f ht
  intro h
  letI : CanLift β s (f ∘ (↑)) fun y => y ∈ f '' s := ⟨fun y ⟨x, hxt, hy⟩ => ⟨⟨x, hxt⟩, hy⟩⟩
  lift t to Finset s using h
  refine ⟨t.map (Embedding.subtype _), map_subtype_subset _, ?_⟩
  ext y; simp

theorem range_sdiff_zero {n : ℕ} : range (n + 1) \ {0} = (range n).image Nat.succ := by
  induction' n with k hk
  · simp
  conv_rhs => rw [range_succ]
  rw [range_succ, image_insert, ← hk, insert_sdiff_of_not_mem]
  simp

end Finset

theorem Multiset.toFinset_map [DecidableEq α] [DecidableEq β] (f : α → β) (m : Multiset α) :
    (m.map f).toFinset = m.toFinset.image f :=
  Finset.val_inj.1 (Multiset.dedup_map_dedup_eq _ _).symm

namespace Equiv

/-- Given an equivalence `α` to `β`, produce an equivalence between `Finset α` and `Finset β`. -/
protected def finsetCongr (e : α ≃ β) : Finset α ≃ Finset β where
  toFun s := s.map e.toEmbedding
  invFun s := s.map e.symm.toEmbedding
  left_inv s := by simp [Finset.map_map]
  right_inv s := by simp [Finset.map_map]

@[simp]
theorem finsetCongr_apply (e : α ≃ β) (s : Finset α) : e.finsetCongr s = s.map e.toEmbedding :=
  rfl

@[simp]
theorem finsetCongr_refl : (Equiv.refl α).finsetCongr = Equiv.refl _ := by
  ext
  simp

@[simp]
theorem finsetCongr_symm (e : α ≃ β) : e.finsetCongr.symm = e.symm.finsetCongr :=
  rfl

@[simp]
theorem finsetCongr_trans (e : α ≃ β) (e' : β ≃ γ) :
    e.finsetCongr.trans e'.finsetCongr = (e.trans e').finsetCongr := by
  ext
  simp [-Finset.mem_map, -Equiv.trans_toEmbedding]

theorem finsetCongr_toEmbedding (e : α ≃ β) :
    e.finsetCongr.toEmbedding = (Finset.mapEmbedding e.toEmbedding).toEmbedding :=
  rfl

end Equiv
