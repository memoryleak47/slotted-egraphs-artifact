import Egg

variable (a b c d : Int)

example : ((a * b) - (2 * c)) * d - (a * b) = (d - 1) * (a * b) - (2 * c * d) := by
  egg [Int.sub_mul, Int.sub_sub, Int.add_comm, Int.mul_comm, Int.one_mul]
