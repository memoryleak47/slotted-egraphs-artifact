import Mathlib.Testing.Egg.SimpOnlyOverride
/-
Copyright (c) 2023 Kim Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kim Morrison
-/
import Mathlib.Init
import Batteries.Data.MLList.Basic

/-!
# Reading from handles, files, and processes as lazy lists.

## Deprecation

This material has been moved out of Mathlib to https://github.com/semorrison/lean-monadic-list.
-/

open System IO.FS
set_option linter.deprecated false

namespace MLList

/-- Read lines of text from a handle, as a lazy list in `IO`. -/
@[deprecated "See deprecation note in module documentation." (since := "2024-08-22")]
def linesFromHandle (h : Handle) : MLList IO String :=
  MLList.iterate (do
    let line ← h.getLine
    -- This copies the logic from `IO.FS.lines`.
    if line.length == 0 then
      return none
    else if line.back == '\n' then
      let line := line.dropRight 1
      let line :=
        if System.Platform.isWindows && line.back == '\x0d' then line.dropRight 1 else line
      return some line
    else
      return some line)
  |>.takeWhile (·.isSome) |>.map (fun o => o.getD "")

/-- Read lines of text from a file, as a lazy list in `IO`. -/
@[deprecated "See deprecation note in module documentation." (since := "2024-08-22")]
def lines (f : FilePath) : MLList IO String := .squash fun _ => do
  return linesFromHandle (← Handle.mk f Mode.read)

open IO.Process in
/--
Run a command with given input on `stdio`,
returning `stdout` as a lazy list in `IO`.
-/
@[deprecated "See deprecation note in module documentation." (since := "2024-08-22")]
def runCmd (cmd : String) (args : Array String) (input : String := "") : MLList IO String := do
  let child ← spawn
    { cmd := cmd, args := args, stdin := .piped, stdout := .piped, stderr := .piped }
  linesFromHandle (← put child input).stdout
where put
    (child : Child { stdin := .piped, stdout := .piped, stderr := .piped }) (input : String) :
    IO (Child { stdin := .null, stdout := .piped, stderr := .piped }) := do
  let (stdin, child) ← child.takeStdin
  stdin.putStr input
  stdin.flush
  return child

end MLList
