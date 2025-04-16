import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2020 David Wärn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: David Wärn
-/
import Mathlib.Logic.Encodable.Basic
import Mathlib.Order.Atoms
import Mathlib.Order.Chain
import Mathlib.Order.UpperLower.Basic
import Mathlib.Data.Set.Subsingleton

/-!
# Order ideals, cofinal sets, and the Rasiowa–Sikorski lemma

## Main definitions

Throughout this file, `P` is at least a preorder, but some sections require more
structure, such as a bottom element, a top element, or a join-semilattice structure.
- `Order.Ideal P`: the type of nonempty, upward directed, and downward closed subsets of `P`.
  Dual to the notion of a filter on a preorder.
- `Order.IsIdeal I`: a predicate for when a `Set P` is an ideal.
- `Order.Ideal.principal p`: the principal ideal generated by `p : P`.
- `Order.Ideal.IsProper I`: a predicate for proper ideals.
  Dual to the notion of a proper filter.
- `Order.Ideal.IsMaximal I`: a predicate for maximal ideals.
  Dual to the notion of an ultrafilter.
- `Order.Cofinal P`: the type of subsets of `P` containing arbitrarily large elements.
  Dual to the notion of 'dense set' used in forcing.
- `Order.idealOfCofinals p 𝒟`, where `p : P`, and `𝒟` is a countable family of cofinal
  subsets of `P`: an ideal in `P` which contains `p` and intersects every set in `𝒟`. (This a form
  of the Rasiowa–Sikorski lemma.)

## References

- <https://en.wikipedia.org/wiki/Ideal_(order_theory)>
- <https://en.wikipedia.org/wiki/Cofinal_(mathematics)>
- <https://en.wikipedia.org/wiki/Rasiowa%E2%80%93Sikorski_lemma>

Note that for the Rasiowa–Sikorski lemma, Wikipedia uses the opposite ordering on `P`,
in line with most presentations of forcing.

## Tags

ideal, cofinal, dense, countable, generic

-/


open Function Set

namespace Order

variable {P : Type*}

/-- An ideal on an order `P` is a subset of `P` that is
  - nonempty
  - upward directed (any pair of elements in the ideal has an upper bound in the ideal)
  - downward closed (any element less than an element of the ideal is in the ideal). -/
structure Ideal (P) [LE P] extends LowerSet P where
  /-- The ideal is nonempty. -/
  nonempty' : carrier.Nonempty
  /-- The ideal is upward directed. -/
  directed' : DirectedOn (· ≤ ·) carrier

-- Porting note (#11215): TODO: remove this configuration and use the default configuration.
-- We keep this to be consistent with Lean 3.
initialize_simps_projections Ideal (+toLowerSet, -carrier)

/-- A subset of a preorder `P` is an ideal if it is
  - nonempty
  - upward directed (any pair of elements in the ideal has an upper bound in the ideal)
  - downward closed (any element less than an element of the ideal is in the ideal). -/
@[mk_iff]
structure IsIdeal {P} [LE P] (I : Set P) : Prop where
  /-- The ideal is downward closed. -/
  IsLowerSet : IsLowerSet I
  /-- The ideal is nonempty. -/
  Nonempty : I.Nonempty
  /-- The ideal is upward directed. -/
  Directed : DirectedOn (· ≤ ·) I

/-- Create an element of type `Order.Ideal` from a set satisfying the predicate
`Order.IsIdeal`. -/
def IsIdeal.toIdeal [LE P] {I : Set P} (h : IsIdeal I) : Ideal P :=
  ⟨⟨I, h.IsLowerSet⟩, h.Nonempty, h.Directed⟩

namespace Ideal

section LE

variable [LE P]

section

variable {I s t : Ideal P} {x : P}

theorem toLowerSet_injective : Injective (toLowerSet : Ideal P → LowerSet P) := fun s t _ ↦ by
  cases s
  cases t
  congr

instance : SetLike (Ideal P) P where
  coe s := s.carrier
  coe_injective' _ _ h := toLowerSet_injective <| SetLike.coe_injective h

@[ext]
theorem ext {s t : Ideal P} : (s : Set P) = t → s = t :=
  SetLike.ext'

@[simp]
theorem carrier_eq_coe (s : Ideal P) : s.carrier = s :=
  rfl

@[simp]
theorem coe_toLowerSet (s : Ideal P) : (s.toLowerSet : Set P) = s :=
  rfl

protected theorem lower (s : Ideal P) : IsLowerSet (s : Set P) :=
  s.lower'

protected theorem nonempty (s : Ideal P) : (s : Set P).Nonempty :=
  s.nonempty'

protected theorem directed (s : Ideal P) : DirectedOn (· ≤ ·) (s : Set P) :=
  s.directed'

protected theorem isIdeal (s : Ideal P) : IsIdeal (s : Set P) :=
  ⟨s.lower, s.nonempty, s.directed⟩

theorem mem_compl_of_ge {x y : P} : x ≤ y → x ∈ (I : Set P)ᶜ → y ∈ (I : Set P)ᶜ := fun h ↦
  mt <| I.lower h

/-- The partial ordering by subset inclusion, inherited from `Set P`. -/
instance instPartialOrderIdeal : PartialOrder (Ideal P) :=
  PartialOrder.lift SetLike.coe SetLike.coe_injective

theorem coe_subset_coe : (s : Set P) ⊆ t ↔ s ≤ t :=
  Iff.rfl

theorem coe_ssubset_coe : (s : Set P) ⊂ t ↔ s < t :=
  Iff.rfl

@[trans]
theorem mem_of_mem_of_le {x : P} {I J : Ideal P} : x ∈ I → I ≤ J → x ∈ J :=
  @Set.mem_of_mem_of_subset P x I J

/-- A proper ideal is one that is not the whole set.
    Note that the whole set might not be an ideal. -/
@[mk_iff]
class IsProper (I : Ideal P) : Prop where
  /-- This ideal is not the whole set. -/
  ne_univ : (I : Set P) ≠ univ

theorem isProper_of_not_mem {I : Ideal P} {p : P} (nmem : p ∉ I) : IsProper I :=
  ⟨fun hp ↦ by
    have := mem_univ p
    rw [← hp] at this
    exact nmem this⟩

/-- An ideal is maximal if it is maximal in the collection of proper ideals.

Note that `IsCoatom` is less general because ideals only have a top element when `P` is directed
and nonempty. -/
@[mk_iff]
class IsMaximal (I : Ideal P) extends IsProper I : Prop where
  /-- This ideal is maximal in the collection of proper ideals. -/
  maximal_proper : ∀ ⦃J : Ideal P⦄, I < J → (J : Set P) = univ

theorem inter_nonempty [IsDirected P (· ≥ ·)] (I J : Ideal P) : (I ∩ J : Set P).Nonempty := by
  obtain ⟨a, ha⟩ := I.nonempty
  obtain ⟨b, hb⟩ := J.nonempty
  obtain ⟨c, hac, hbc⟩ := exists_le_le a b
  exact ⟨c, I.lower hac ha, J.lower hbc hb⟩

end

section Directed

variable [IsDirected P (· ≤ ·)] [Nonempty P] {I : Ideal P}

/-- In a directed and nonempty order, the top ideal of a is `univ`. -/
instance : OrderTop (Ideal P) where
  top := ⟨⊤, univ_nonempty, directedOn_univ⟩
  le_top _ _ _ := LowerSet.mem_top

@[simp]
theorem top_toLowerSet : (⊤ : Ideal P).toLowerSet = ⊤ :=
  rfl

@[simp]
theorem coe_top : ((⊤ : Ideal P) : Set P) = univ :=
  rfl

theorem isProper_of_ne_top (ne_top : I ≠ ⊤) : IsProper I :=
  ⟨fun h ↦ ne_top <| ext h⟩

theorem IsProper.ne_top (_ : IsProper I) : I ≠ ⊤ :=
  fun h ↦ IsProper.ne_univ <| congr_arg SetLike.coe h

theorem _root_.IsCoatom.isProper (hI : IsCoatom I) : IsProper I :=
  isProper_of_ne_top hI.1

theorem isProper_iff_ne_top : IsProper I ↔ I ≠ ⊤ :=
  ⟨fun h ↦ h.ne_top, fun h ↦ isProper_of_ne_top h⟩

theorem IsMaximal.isCoatom (_ : IsMaximal I) : IsCoatom I :=
  ⟨IsMaximal.toIsProper.ne_top, fun _ h ↦ ext <| IsMaximal.maximal_proper h⟩

theorem IsMaximal.isCoatom' [IsMaximal I] : IsCoatom I :=
  IsMaximal.isCoatom ‹_›

theorem _root_.IsCoatom.isMaximal (hI : IsCoatom I) : IsMaximal I :=
  { IsCoatom.isProper hI with maximal_proper := fun _ hJ ↦ by simp [hI.2 _ hJ] }

theorem isMaximal_iff_isCoatom : IsMaximal I ↔ IsCoatom I :=
  ⟨fun h ↦ h.isCoatom, fun h ↦ IsCoatom.isMaximal h⟩

end Directed

section OrderBot

variable [OrderBot P]

@[simp]
theorem bot_mem (s : Ideal P) : ⊥ ∈ s :=
  s.lower bot_le s.nonempty'.some_mem

end OrderBot

section OrderTop

variable [OrderTop P] {I : Ideal P}

theorem top_of_top_mem (h : ⊤ ∈ I) : I = ⊤ := by
  ext
  exact iff_of_true (I.lower le_top h) trivial

theorem IsProper.top_not_mem (hI : IsProper I) : ⊤ ∉ I := fun h ↦ hI.ne_top <| top_of_top_mem h

end OrderTop

end LE

section Preorder

variable [Preorder P]

section

variable {I : Ideal P} {x y : P}

/-- The smallest ideal containing a given element. -/
@[simps]
def principal (p : P) : Ideal P where
  toLowerSet := LowerSet.Iic p
  nonempty' := nonempty_Iic
  directed' _ hx _ hy := ⟨p, le_rfl, hx, hy⟩

instance [Inhabited P] : Inhabited (Ideal P) :=
  ⟨Ideal.principal default⟩

@[simp]
theorem principal_le_iff : principal x ≤ I ↔ x ∈ I :=
  ⟨fun h ↦ h le_rfl, fun hx _ hy ↦ I.lower hy hx⟩

@[simp]
theorem mem_principal : x ∈ principal y ↔ x ≤ y :=
  Iff.rfl

lemma mem_principal_self : x ∈ principal x :=
  mem_principal.2 (le_refl x)

end

section OrderBot

variable [OrderBot P]

/-- There is a bottom ideal when `P` has a bottom element. -/
instance : OrderBot (Ideal P) where
  bot := principal ⊥
  bot_le := by simp

@[simp]
theorem principal_bot : principal (⊥ : P) = ⊥ :=
  rfl

end OrderBot

section OrderTop

variable [OrderTop P]

@[simp]
theorem principal_top : principal (⊤ : P) = ⊤ :=
  toLowerSet_injective <| LowerSet.Iic_top

end OrderTop

end Preorder

section SemilatticeSup

variable [SemilatticeSup P] {x y : P} {I s : Ideal P}

/-- A specific witness of `I.directed` when `P` has joins. -/
theorem sup_mem (hx : x ∈ s) (hy : y ∈ s) : x ⊔ y ∈ s :=
  let ⟨_, hz, hx, hy⟩ := s.directed x hx y hy
  s.lower (sup_le hx hy) hz

@[simp]
theorem sup_mem_iff : x ⊔ y ∈ I ↔ x ∈ I ∧ y ∈ I :=
  ⟨fun h ↦ ⟨I.lower le_sup_left h, I.lower le_sup_right h⟩, fun h ↦ sup_mem h.1 h.2⟩

end SemilatticeSup

section SemilatticeSupDirected

variable [SemilatticeSup P] [IsDirected P (· ≥ ·)] {x : P} {I J s t : Ideal P}

/-- The infimum of two ideals of a co-directed order is their intersection. -/
instance : Inf (Ideal P) :=
  ⟨fun I J ↦
    { toLowerSet := I.toLowerSet ⊓ J.toLowerSet
      nonempty' := inter_nonempty I J
      directed' := fun x hx y hy ↦ ⟨x ⊔ y, ⟨sup_mem hx.1 hy.1, sup_mem hx.2 hy.2⟩, by simp⟩ }⟩

/-- The supremum of two ideals of a co-directed order is the union of the down sets of the pointwise
supremum of `I` and `J`. -/
instance : Sup (Ideal P) :=
  ⟨fun I J ↦
    { carrier := { x | ∃ i ∈ I, ∃ j ∈ J, x ≤ i ⊔ j }
      nonempty' := by
        cases' inter_nonempty I J with w h
        exact ⟨w, w, h.1, w, h.2, le_sup_left⟩
      directed' := fun x ⟨xi, _, xj, _, _⟩ y ⟨yi, _, yj, _, _⟩ ↦
        ⟨x ⊔ y, ⟨xi ⊔ yi, sup_mem ‹_› ‹_›, xj ⊔ yj, sup_mem ‹_› ‹_›,
            sup_le
              (calc
                x ≤ xi ⊔ xj := ‹_›
                _ ≤ xi ⊔ yi ⊔ (xj ⊔ yj) := sup_le_sup le_sup_left le_sup_left)
              (calc
                y ≤ yi ⊔ yj := ‹_›
                _ ≤ xi ⊔ yi ⊔ (xj ⊔ yj) := sup_le_sup le_sup_right le_sup_right)⟩,
          le_sup_left, le_sup_right⟩
      lower' := fun _ _ h ⟨yi, hi, yj, hj, hxy⟩ ↦ ⟨yi, hi, yj, hj, h.trans hxy⟩ }⟩

instance : Lattice (Ideal P) :=
  { Ideal.instPartialOrderIdeal with
    sup := (· ⊔ ·)
    le_sup_left := fun _ J i hi ↦
      let ⟨w, hw⟩ := J.nonempty
      ⟨i, hi, w, hw, le_sup_left⟩
    le_sup_right := fun I _ j hj ↦
      let ⟨w, hw⟩ := I.nonempty
      ⟨w, hw, j, hj, le_sup_right⟩
    sup_le := fun _ _ K hIK hJK _ ⟨_, hi, _, hj, ha⟩ ↦
      K.lower ha <| sup_mem (mem_of_mem_of_le hi hIK) (mem_of_mem_of_le hj hJK)
    inf := (· ⊓ ·)
    inf_le_left := fun _ _ ↦ inter_subset_left
    inf_le_right := fun _ _ ↦ inter_subset_right
    le_inf := fun _ _ _ ↦ subset_inter }

@[simp]
theorem coe_sup : ↑(s ⊔ t) = { x | ∃ a ∈ s, ∃ b ∈ t, x ≤ a ⊔ b } :=
  rfl

-- Porting note: Modified `s ∩ t` to `↑s ∩ ↑t`.
@[simp]
theorem coe_inf : (↑(s ⊓ t) : Set P) = ↑s ∩ ↑t :=
  rfl

@[simp]
theorem mem_inf : x ∈ I ⊓ J ↔ x ∈ I ∧ x ∈ J :=
  Iff.rfl

@[simp]
theorem mem_sup : x ∈ I ⊔ J ↔ ∃ i ∈ I, ∃ j ∈ J, x ≤ i ⊔ j :=
  Iff.rfl

theorem lt_sup_principal_of_not_mem (hx : x ∉ I) : I < I ⊔ principal x :=
  le_sup_left.lt_of_ne fun h ↦ hx <| by simpa only [left_eq_sup, principal_le_iff] using h

end SemilatticeSupDirected

section SemilatticeSupOrderBot

variable [SemilatticeSup P] [OrderBot P] {x : P}

instance : InfSet (Ideal P) :=
  ⟨fun S ↦
    { toLowerSet := ⨅ s ∈ S, toLowerSet s
      nonempty' :=
        ⟨⊥, by
          rw [LowerSet.carrier_eq_coe, LowerSet.coe_iInf₂, Set.mem_iInter₂]
          exact fun s _ ↦ s.bot_mem⟩
      directed' := fun a ha b hb ↦
        ⟨a ⊔ b,
          ⟨by
            rw [LowerSet.carrier_eq_coe, LowerSet.coe_iInf₂, Set.mem_iInter₂] at ha hb ⊢
            exact fun s hs ↦ sup_mem (ha _ hs) (hb _ hs), le_sup_left, le_sup_right⟩⟩ }⟩

variable {S : Set (Ideal P)}

@[simp]
theorem coe_sInf : (↑(sInf S) : Set P) = ⋂ s ∈ S, ↑s :=
  LowerSet.coe_iInf₂ _

@[simp]
theorem mem_sInf : x ∈ sInf S ↔ ∀ s ∈ S, x ∈ s := by
  simp_rw [← SetLike.mem_coe, coe_sInf, mem_iInter₂]

instance : CompleteLattice (Ideal P) :=
  { (inferInstance : Lattice (Ideal P)),
    completeLatticeOfInf (Ideal P) fun S ↦ by
      refine ⟨fun s hs ↦ ?_, fun s hs ↦ by rwa [← coe_subset_coe, coe_sInf, subset_iInter₂_iff]⟩
      rw [← coe_subset_coe, coe_sInf]
      exact biInter_subset_of_mem hs with }

end SemilatticeSupOrderBot

section DistribLattice

variable [DistribLattice P]
variable {I J : Ideal P}

theorem eq_sup_of_le_sup {x i j : P} (hi : i ∈ I) (hj : j ∈ J) (hx : x ≤ i ⊔ j) :
    ∃ i' ∈ I, ∃ j' ∈ J, x = i' ⊔ j' := by
  refine ⟨x ⊓ i, I.lower inf_le_right hi, x ⊓ j, J.lower inf_le_right hj, ?_⟩
  calc
    x = x ⊓ (i ⊔ j) := left_eq_inf.mpr hx
    _ = x ⊓ i ⊔ x ⊓ j := inf_sup_left _ _ _

theorem coe_sup_eq : ↑(I ⊔ J) = { x | ∃ i ∈ I, ∃ j ∈ J, x = i ⊔ j } :=
  Set.ext fun _ ↦
    ⟨fun ⟨_, _, _, _, _⟩ ↦ eq_sup_of_le_sup ‹_› ‹_› ‹_›, fun ⟨i, _, j, _, _⟩ ↦
      ⟨i, ‹_›, j, ‹_›, le_of_eq ‹_›⟩⟩

end DistribLattice

section BooleanAlgebra

variable [BooleanAlgebra P] {x : P} {I : Ideal P}

theorem IsProper.not_mem_of_compl_mem (hI : IsProper I) (hxc : xᶜ ∈ I) : x ∉ I := by
  intro hx
  apply hI.top_not_mem
  have ht : x ⊔ xᶜ ∈ I := sup_mem ‹_› ‹_›
  rwa [sup_compl_eq_top] at ht

theorem IsProper.not_mem_or_compl_not_mem (hI : IsProper I) : x ∉ I ∨ xᶜ ∉ I := by
  have h : xᶜ ∈ I → x ∉ I := hI.not_mem_of_compl_mem
  tauto

end BooleanAlgebra

end Ideal

/-- For a preorder `P`, `Cofinal P` is the type of subsets of `P`
  containing arbitrarily large elements. They are the dense sets in
  the topology whose open sets are terminal segments. -/
structure Cofinal (P) [Preorder P] where
  /-- The carrier of a `Cofinal` is the underlying set. -/
  carrier : Set P
  /-- The `Cofinal` contains arbitrarily large elements. -/
  mem_gt : ∀ x : P, ∃ y ∈ carrier, x ≤ y

namespace Cofinal

variable [Preorder P]

instance : Inhabited (Cofinal P) :=
  ⟨{  carrier := univ
      mem_gt := fun x ↦ ⟨x, trivial, le_rfl⟩ }⟩

instance : Membership P (Cofinal P) :=
  ⟨fun D x ↦ x ∈ D.carrier⟩

variable (D : Cofinal P) (x : P)

/-- A (noncomputable) element of a cofinal set lying above a given element. -/
noncomputable def above : P :=
  Classical.choose <| D.mem_gt x

theorem above_mem : D.above x ∈ D :=
  (Classical.choose_spec <| D.mem_gt x).1

theorem le_above : x ≤ D.above x :=
  (Classical.choose_spec <| D.mem_gt x).2

end Cofinal

section IdealOfCofinals

variable [Preorder P] (p : P) {ι : Type*} [Encodable ι] (𝒟 : ι → Cofinal P)

/-- Given a starting point, and a countable family of cofinal sets,
  this is an increasing sequence that intersects each cofinal set. -/
noncomputable def sequenceOfCofinals : ℕ → P
  | 0 => p
  | n + 1 =>
    match Encodable.decode n with
    | none => sequenceOfCofinals n
    | some i => (𝒟 i).above (sequenceOfCofinals n)

theorem sequenceOfCofinals.monotone : Monotone (sequenceOfCofinals p 𝒟) := by
  apply monotone_nat_of_le_succ
  intro n
  dsimp only [sequenceOfCofinals, Nat.add]
  cases (Encodable.decode n : Option ι)
  · rfl
  · apply Cofinal.le_above

theorem sequenceOfCofinals.encode_mem (i : ι) :
    sequenceOfCofinals p 𝒟 (Encodable.encode i + 1) ∈ 𝒟 i := by
  dsimp only [sequenceOfCofinals, Nat.add]
  rw [Encodable.encodek]
  apply Cofinal.above_mem

/-- Given an element `p : P` and a family `𝒟` of cofinal subsets of a preorder `P`,
  indexed by a countable type, `idealOfCofinals p 𝒟` is an ideal in `P` which
  - contains `p`, according to `mem_idealOfCofinals p 𝒟`, and
  - intersects every set in `𝒟`, according to `cofinal_meets_idealOfCofinals p 𝒟`.

  This proves the Rasiowa–Sikorski lemma. -/
def idealOfCofinals : Ideal P where
  carrier := { x : P | ∃ n, x ≤ sequenceOfCofinals p 𝒟 n }
  lower' := fun _ _ hxy ⟨n, hn⟩ ↦ ⟨n, le_trans hxy hn⟩
  nonempty' := ⟨p, 0, le_rfl⟩
  directed' := fun _ ⟨n, hn⟩ _ ⟨m, hm⟩ ↦
    ⟨_, ⟨max n m, le_rfl⟩, le_trans hn <| sequenceOfCofinals.monotone p 𝒟 (le_max_left _ _),
      le_trans hm <| sequenceOfCofinals.monotone p 𝒟 (le_max_right _ _)⟩

theorem mem_idealOfCofinals : p ∈ idealOfCofinals p 𝒟 :=
  ⟨0, le_rfl⟩

/-- `idealOfCofinals p 𝒟` is `𝒟`-generic. -/
theorem cofinal_meets_idealOfCofinals (i : ι) : ∃ x : P, x ∈ 𝒟 i ∧ x ∈ idealOfCofinals p 𝒟 :=
  ⟨_, sequenceOfCofinals.encode_mem p 𝒟 i, _, le_rfl⟩

end IdealOfCofinals

section sUnion

variable [Preorder P]

/-- A non-empty directed union of ideals of sets in a preorder is an ideal. -/
lemma isIdeal_sUnion_of_directedOn {C : Set (Set P)} (hidl : ∀ I ∈ C, IsIdeal I)
    (hD : DirectedOn (· ⊆ ·) C) (hNe : C.Nonempty) : IsIdeal C.sUnion := by
  refine ⟨isLowerSet_sUnion (fun I hI ↦ (hidl I hI).1), Set.nonempty_sUnion.2 ?_,
    directedOn_sUnion hD (fun J hJ => (hidl J hJ).3)⟩
  let ⟨I, hI⟩ := hNe
  exact ⟨I, ⟨hI, (hidl I hI).2⟩⟩

/-- A union of a nonempty chain of ideals of sets is an ideal. -/
lemma isIdeal_sUnion_of_isChain {C : Set (Set P)} (hidl : ∀ I ∈ C, IsIdeal I)
    (hC : IsChain (· ⊆ ·) C) (hNe : C.Nonempty) : IsIdeal C.sUnion :=
  isIdeal_sUnion_of_directedOn hidl hC.directedOn hNe

end sUnion
end Order
