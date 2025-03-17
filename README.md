Slotted E-Graphs - Artifact
===========================

In this repository, we will collect the benchmarks from our paper into one artifact.


## Functional Array Language

To reproduce the Functional Array Language case study, run the `./run.sh` script in the functional-array-language folder.

It should compile both egg-rise and slotted-rise (which also includes the slotted-db module),

and run them accordingly.


You should find the results in the `outputs` folder.

After running sufficiently many tests, you can abort `run.sh`; and run `python3 plot.py outputs`.

This should generate the output graphs from Figure 8 of our paper.

## Lean Tactic Case Study

To reproduce the Lean case study, first ensure that the `lean-egg` project can be built:

```bash
$ cd lean-egg
$ lake build
```

Once the build completes successfully, open the test file `lean-egg/Lean/Egg/Tests/PLDI.lean` in VS Code. 

### Content

The `PLDI.lean` test file starts with a standalone definition of join-semilattices and related definitions. The subsequent namespaces `Slotted` and `Egg` contain the two theorems `not_supPrime` and `not_supIrred` which were highlighted in Section 4.3 of the paper. The theorem statements and proofs are identical between the `Slotted` and `Egg` namespaces. In both cases we attempt to prove these theorems using the `egg` tactic. The only difference is that in the `Slotted` namespace, we enable *slotted* as the backend solver, whereas the `Egg` namespace enables *egg* as the backend solver. The result is that both proofs succeed when *slotted* is used, and fail when *egg* is used. 

### Failing Proofs

The proofs in the `Egg` namespace fail for two reasons:

* `not_supPrime`: This call to `egg` produces an explanation with over 4000 steps, which exceeds the explanation length limit. The `egg` tactic employs an "explanation length limit", to abort invocations which produce explanations which are too long to process in a reasonable amount of time. To (try to) process such explanations anyway, increase the explanation length limit with `set_option egg.explLengthLimit <num>`. Note that this may cause the tactic to take multiple minutes to complete.
* `not_supIrred`: This call to `egg` hightlights e-graph explosion, which means that this invocation always times out. In this test case, we set the timout to `1000000000000000000` to show that equality saturation does not complete in any sensible amount of time. Running this tactic invocation for several hours leads to memory overflow. In comparison, this same theorem is proven with the *slotted* backend in less than 1 second. To inspect intermediate results, reduce the time limit to a value like 10 (seconds) by adjusting the value passed to the `egg.timeLimit` option. Note how quickly the number of e-nodes and -classes grows (by hovering over the tactic call and inspecting the info message).

### Further Inspection

To inspect further details of the respective tactic invocations we enable the `egg.reporting` option. This option enables tracking of various statistics for `egg` tactic calls. In VS Code, this information can be viewed by hovering over the specific invocation of the `egg` tactic. Alternatively, it can be viewed by in the *Infoview* when placing the cursor on the line of the the specific invocation of the `egg` tactic. The most important statistics are:

* `total time`: The total amount of time taken to complete the call to the `egg` tactic.
* `eqsat time`: The amount of time taken to run equality saturation in the backend.
* `proof time`: The length of the time span starting after equality saturation completed and ending with the completion of the `egg` tactic. This time span mainly represents the amount of time tak for proof reconstruction.
* `iters`: The number of iterations run before equality saturation completed (potentially by being aborted due to exceeding resource limits.)
* `nodes`: The number of e-nodes contained in the e-graph when equality saturation completed (potentially by being aborted due to exceeding resource limits.)
* `classes`: The number of e-classes contained in the e-graph when equality saturation completed (potentially by being aborted due to exceeding resource limits.)
* `expl steps`: The number of steps in the explanation produced by the respective equality saturation backend. If the explanation length exceeds the limit set by the `egg` tactic (1000 steps), then this value will only appear in an associated error message.

To view the explanations/proofs discovered by a given tactic invocation, place the cursor on the line of the `egg` tactic invocation and open the *Infoview*. The "Explanation" item shows the raw explanation string as returned by the backend. The "Explanation Steps" item shows the explanation in a more readable form, as pretty-printed Lean expressions.


