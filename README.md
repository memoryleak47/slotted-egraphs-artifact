Slotted E-Graphs - Artifact
===========================

In this repository, we will collect the benchmarks from our paper into one artifact.

Each of the three benchmarks corresponds to a folder (functional-array-language, lean-egg, sdql) with a `main.sh` file in it.
This `main.sh` is the entry point of that benchmark and will be ran only within the docker image.

## Functional Array Language

To reproduce the Functional Array Language case study, run `uv run run.py` in the functional-array-language folder. You will need to the `uv` Python package manager.

It should compile both egg-rise and slotted-rise (which also includes the slotted-db module), and run them accordingly.

You should find the results in the `outputs` folder.

After running sufficiently many tests, you can abort `run.py`; and run `uv run plot.py outputs`. The `uv` package manager should have taken care of installing pandas and matplotlib.

This should generate the output graphs from Figure 8 of our paper.

## SDQL

In order to benchmark all files, you need to go to
the folder `sdql` and run `main.sh`.

In both cases, the results will be written to `bench.txt` and `mttkrp.txt` in each
folder `baseline` and `slotted`.
The results from `bench.txt` correspond to Table 1 in our paper, while
the results from `mttkrp.txt` correspond to Table 2.

The baseline uses egg with one small change (see [here](https://github.com/amirsh/egg/commit/5b19ed7dd5870a42370d5fb8825410072f51410c)): When counting the number of e-nodes in the Runner, we use `total_number_of_nodes` instead of `total_size`.
This is a fairer comparison, as eggs `total_size` also counts e-nodes that could have been cleaned up -- and are cleaned up in our slotted implementation.



## Lean Tactic

To properly inspect the statements, proofs, and metrics of the theorems shown in Section 4.3, we require a setup which allows interaction with the `lean-egg` project contained in this artifact.

### Setup

#### Without Docker

If you already have an installation of Lean and its package manager `lake`, start by building the `lean-egg` project:

```bash
$ cd lean-egg && lake build
```

Then, navigate into the `lean-egg` directory and open the `lean-egg/Lean/Egg/Tests/PLDI.lean` test file in your Lean-editor of choice (below we assume VS Code). Continue reading at the [Content](#content) section below.

#### With Docker

To reproduce the Lean case study with Docker we assume that you have [Docker](https://docs.docker.com/get-started/get-docker/) installed.

##### Non-Interactive Version

The `main.sh` script in `lean-egg` will run lean to check the test file `lean-egg/Lean/Egg/Tests/PLDI.lean` in a non-interactive session.

##### Interactive Version with VS Code

Alternatively, you can use [VS Code](https://code.visualstudio.com) with the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension.

To run the docker container from VS Code, open the command palette (Ctrl+Shift+P or Cmd+Shift+P) and run the `Dev Containers: Open Fold in Container...` command. 
Select the root directory (the one containing this `README`) as the target folder.

> *Troubleshooting:* If the command fails, try erasing any `.tar` file in the root directory, if present. Then run the command again.

If the docker container is successfully running with VS Code, open the `lean-egg/Lean/Egg/Tests/PLDI.lean` test file.

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


