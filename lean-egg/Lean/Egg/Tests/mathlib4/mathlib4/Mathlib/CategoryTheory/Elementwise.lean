import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2021 Kim Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kim Morrison
-/
import Mathlib.Tactic.CategoryTheory.Elementwise
import Mathlib.CategoryTheory.ConcreteCategory.Basic

/-!
# Use the `elementwise` attribute to create applied versions of lemmas.

Usually we would use `@[elementwise]` at the point of definition,
however some early parts of the category theory library are imported by `Tactic.Elementwise`,
so we need to add the attribute after the fact.
-/


/-! We now add some `elementwise` attributes to lemmas that were proved earlier. -/


open CategoryTheory

attribute [elementwise (attr := simp)] Iso.hom_inv_id Iso.inv_hom_id

-- This list is incomplete, and it would probably be useful to add more.
set_option linter.existingAttributeWarning false in
attribute [elementwise (attr := simp)] IsIso.hom_inv_id IsIso.inv_hom_id
