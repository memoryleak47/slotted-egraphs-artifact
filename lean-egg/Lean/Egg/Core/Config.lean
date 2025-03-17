namespace Egg.Config

structure Normalization where
  betaReduceRws := true
  etaReduceRws  := true
  natReduceRws  := true
  deriving BEq

def Normalization.noReduce : Normalization where
  betaReduceRws := false
  etaReduceRws  := false
  natReduceRws  := false

structure Encoding extends Normalization where
  -- TODO: Currently, this option implicitly disables `retryWithShapes` as slotted cannot handle shapes, yet.
  slotted     := false
  eraseProofs := true
  -- TODO: Currently, this option implicitly disables defeq rewrites as they can not handle shapes, yet.
  shapes      := false
  deriving BEq

structure Gen where
  builtins      := true
  basket?       := (none : Option Lean.Name)
  genTcProjRws  := true
  genTcSpecRws  := true
  genGoalTcSpec := true
  explosion     := false
  deriving BEq

structure DefEq where
  natLit    := true
  eta       := true
  etaExpand := false
  beta      := true
  levels    := true

structure Backend where
  blockInvalidMatches := true
  shiftCapturedBVars  := true -- This option implies `blockInvalidMatches`.
  unionSemantics      := true
  conditionSubgoals   := false
  -- TODO: For slotted e-graphs, this option can be used to inspect the tree explanation by setting
  --       this option to `false`.
  optimizeExpl        := true
  timeLimit           := 3
  nodeLimit           := 1000000000000000000
  iterLimit           := 1000000000000000000
  reporting           := false
  flattenReports      := false
  deriving BEq

inductive Debug.ExitPoint
  | none
  | beforeEqSat
  | beforeProof
  deriving BEq, Inhabited

structure Debug where
  exitPoint := Debug.ExitPoint.none
  vizPath   := (none : Option String)
  deriving BEq

structure _root_.Egg.Config extends Encoding, DefEq, Gen, Backend, Debug where
  retryWithShapes := true
  explLengthLimit := 1000

-- TODO: Why aren't these coercions automatic?

instance : Coe Encoding Normalization where
  coe := Encoding.toNormalization

instance : Coe Config Encoding where
  coe := toEncoding

instance : Coe Config DefEq where
  coe := toDefEq
