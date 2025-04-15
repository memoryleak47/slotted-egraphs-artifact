Slotted E-Graphs - Artifact
===========================

This repository collects the benchmarks from the paper "Slotted E-Graphs" into one artifact.

There are three sets of benchmarks each with its own folder: 
  - `functional-array-language` for the evaluation in Section 4.1
  - `sdql` for the evaluation in Section 4.2
  - `lean-egg` for the evaluation in Section 4.3


## Dependencies and Docker
The artifact is packaged in a Docker image. Execute it and run a terminal from it. On MacOS/Windows using Docker desktop, this can be done via a GUI, on a Debian-based machine (like Ubuntu), you can get Docker by running
```
sudo apt install docker.io
```

And load and run the docker image with:

```
sudo docker load < slotted-image.tar.gz
sudo docker run -it slotted-image
```

The docker container has the following dependencies preinstalled:
  - Linux `coreutils`, `git`, `curl`
  - slotted-egraphs (https://crates.io/crates/slotted-egraphs; version 0.0.26)
  - egg (https://crates.io/crates/egg)
  - Rust (version 1.82)
  - Lean 4 (version 4.14.0-rc1)
  - uv Python Manager (version 0.6.8)
  - Python (version 3.12)
  - Mathplotlib (version 3.10.1)
  - Pandas (version 2.2.3)

You can run the benchmarks without docker when all dependencies are installed.
You can run the benchmarks also from within the docker container without needing to install any additional software.

## Slotted implementation
You can inspect the implementation of Slotted E-Graphs.
Each subfolder contains a copy of the Rust implementation (`functional-array-language/slotted-egraphs`, `sdql/slotted/slotted-egraphs`, `lean-egg/Rust/Slotted`).
All these versions are identical with minor configuration differences.


## Functional Array Language (Section 4.1)

To reproduce Figure 8 from the Functional Array Language case study, run `uv run run.py` in the `functional-array-language` folder. **This should take about 5 minutes.**

The results are written to the `outputs` subfolder.

To produce the plots from Figure 8 run `uv run plot.py outputs`.

This generates the output graphs from Figure 8 of our paper in the `plots` subfolder.


## SDQL (Section 4.2)

To run all benchmarks from Table 1 and 2, you need to go to the folder `sdql` and run `main.sh`.
**This should take about two hours.**

The results will be written to `bench.txt` and `mttkrp.txt` in each subfolder `baseline` and `slotted`.
The results from `bench.txt` correspond to Table 1 in our paper, while
the results from `mttkrp.txt` correspond to Table 2.

The baseline uses egg with one small change (see [here](https://github.com/amirsh/egg/commit/5b19ed7dd5870a42370d5fb8825410072f51410c)): When counting the number of e-nodes in the Runner, we use `total_number_of_nodes` instead of `total_size`.
This is a fairer comparison, as eggs `total_size` also counts e-nodes that could have been cleaned up -- and are cleaned up in our slotted implementation.


## Lean Tactic (Section 4.3)

### Table 4

To reproduce Table 4, run the script `lean-egg/mathlib.sh`.
This script builds mathlib4 with calls to `simp` replaced by `egg` as described in Section 4.3.
The build step can take on the order of 30 minutes.
Results of the build pertaining to the `egg` tactic are logged in the `mathlib-logs` directory (which is created by the script).
For transparency, we also log the intermediate states of subsequent processing steps in this directory, though they are not too useful themselves.
Finally, the aggregated results are printed and should look roughly as follows:

```text
Total Number of Test Cases: 442

Backend | Successful Proven Theorems | Average Explanation Length | ...With Binders
-----------------------------------------------------------------------------------
slotted | 296                        | 6.07                       | 6.70
egg     | 296                        | 5.35                       | 12.7
```

We note that the results obtained in this artifact differ slightly from those in Table 4.
Namely, TODO.
This does not, however, affect the overall outcome.

### Binder Explosion

To reproduce the behavior of the `egg` tactic on the theorems `not_supPrime` and `not_supIrred` as shown in Section 4.3, run the script `lean-egg/main.sh`.
This script runs Lean on the test file `lean-egg/Lean/Egg/Tests/PLDI.lean` in a non-interactive session.
This test file contains the theorems `not_supPrime` and `not_supIrred` and (attempted) proofs thereof using the `egg` tactic with both the *slotted* and *egg* backends.
**This script will run until the one of the proof attempts runs out of memory, which should take about 30 minutes.**
Each call to the `egg` tactic logs whether it succeeded or failed, as well as additional debugging information.
The most important items are:

* `total time`: The total amount of time taken to complete the call to the `egg` tactic.
* `eqsat time`: The amount of time taken to run equality saturation in the backend.
* `proof time`: The length of the time span starting after equality saturation completed and ending with the completion of the `egg` tactic. This time span mainly represents the amount of time taken for proof reconstruction.
* `iters`: The number of iterations run before equality saturation completed (potentially by being aborted due to exceeding resource limits.)
* `nodes`: The number of e-nodes contained in the e-graph when equality saturation completed (potentially by being aborted due to exceeding resource limits.)
* `classes`: The number of e-classes contained in the e-graph when equality saturation completed (potentially by being aborted due to exceeding resource limits.)
* `expl steps`: The number of steps in the explanation produced by the respective equality saturation backend. If the explanation length exceeds the limit set by the `egg` tactic (1000 steps), then this value will only appear in an associated error message.

The high-level results obtained from these logs are that both theorems are quickly proven by the slotted backend with few explanation steps, while the egg backend either produces too many explanation steps for the `egg` tactic to handle, or does not even return before running out of memory.

To properly inspect the statements, proofs, and metrics of the theorems shown in Section 4.3, we require a setup which allows interaction with the `lean-egg` project contained in this artifact.
To reproduce the results of the paper, it suffices to run the non-interactive CLI version as follows. If you want to explore further, we recommend the Interactive version below.

#### Further Inspection

For the interested reader, we also outline how to inspect the Lean file in more depth.
In this case, we require the use of [VS Code](https://code.visualstudio.com) with the [Lean4](https://marketplace.visualstudio.com/items?itemName=leanprover.lean4) extension.

> If you want to use VS Code within docker, you need the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension.
> To run the docker container from VS Code, open the command palette (Ctrl+Shift+P or Cmd+Shift+P) and run the `Dev Containers: Open Fold in Container...` command.
> Select the root directory (the one containing this `README`) as the target folder.
> *Troubleshooting:* If the command fails, try erasing any `.tar` file in the root directory, if present. Then run the command again.

Once you have finished the setup, navigate into the `lean-egg` directory, and
- open the `lean-egg/Lean/Egg/Tests/PLDI.lean` file in VS Code
- click on the Lean 4 icon (a "∀" symbol) at the top-right to open the info view using "Toggle Info View"
- click on the blue "Restart File" button at the bottom-right to start the Lean analysis.

The `PLDI.lean` test file starts with a standalone definition of join-semilattices and related definitions. The subsequent namespaces `Slotted` and `Egg` contain the two theorems `not_supPrime` and `not_supIrred`. The theorem statements and proofs are identical between the `Slotted` and `Egg` namespaces. In both cases we attempt to prove these theorems using the `egg` tactic. The only difference is that in the `Slotted` namespace, we enable *slotted* as the backend solver, whereas the `Egg` namespace enables *egg* as the backend solver. The result is that both proofs succeed when *slotted* is used, and fail when *egg* is used. 

The proofs in the `Egg` namespace fail for two reasons:

* `not_supPrime`: This call to `egg` produces an explanation with over 4000 steps, which exceeds the explanation length limit. The `egg` tactic employs an "explanation length limit", to abort invocations which produce explanations which are too long to process in a reasonable amount of time. To (try to) process such explanations anyway, increase the explanation length limit with `set_option egg.explLengthLimit <num>`. Note that this may cause the tactic to take multiple minutes to complete.
* `not_supIrred`: This call to `egg` highlights e-graph explosion, which means that this invocation always times out. In this test case, we set the timout to `1000000000000000000` to show that equality saturation does not complete in any sensible amount of time. Running this tactic invocation for several hours leads to memory overflow. In comparison, this same theorem is proven with the *slotted* backend in less than 1 second. To inspect intermediate results, reduce the time limit to a value like 10 (seconds) by adjusting the value passed to the `egg.timeLimit` option. Note how quickly the number of e-nodes and -classes grows (by hovering over the tactic call and inspecting the info message).

To view the explanations/proofs discovered by a given tactic invocation, start by enabling the `egg.explanation{.steps}` options on lines 38 and 39. Then, place the cursor on the line of the `egg` tactic invocation and open the *Infoview*. The "Explanation" item shows the raw explanation string as returned by the backend. The "Explanation Steps" item shows the explanation in a more readable form, as pretty-printed Lean expressions.


