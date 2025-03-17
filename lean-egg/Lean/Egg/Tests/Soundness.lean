import Egg

-- Tests containing examples of backend soundness issues.

-- In this example egg finds a proof, but we're not performing proof reconstruction (which would be
-- impossible) as a result of setting `exitPoint := some .beforeProof`.
example : False := by
  have h : ∀ x : Unit, x = .unit := fun _ => rfl
  have : 1 + 2 = 0 := by egg (config := { exitPoint := some .beforeProof }) [h]
  contradiction
