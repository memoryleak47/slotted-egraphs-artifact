import Egg

-- This test checks that we correctly encode bvars in binder types. We had a bug where the binder
-- type would have an off-by-one bvar index.

example :
    (∀ (α : Type) (l : List α), l.length = l.length) ↔
    (∀ (α : Type) (l : List α), l.length = l.length) := by
  egg
