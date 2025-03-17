import Egg

-- https://leanprover.zulipchat.com/#narrow/stream/113488-general/topic/unification.20problem.20in.20rw/near/438497625

variable {α} {f : α → α → α} (f_comm : ∀ a b, f a b = f b a) (f_assoc : ∀ a b c, f (f a b) c = f a (f b c))

include f_assoc f_comm in
theorem foldl_descend : (head :: tail).foldl f init = f init (tail.foldl f head) := by
  induction tail generalizing init with
  | nil         => rfl
  | cons _ _ ih => egg [List.foldl, f_assoc, f_comm, ih]

include f_assoc f_comm in
theorem foldl_eq_foldr (l : List α) : l.foldl f init = l.foldr f init := by
  induction l with
  | nil         => rfl
  | cons _ _ ih => egg [List.foldl, List.foldr, f_comm, ih, foldl_descend; f_comm, f_assoc]
