Hejsa test

Async ANN Pipeline in ACT/CHP
=============================

Overview
--------
Implemented a simple asynchronous Artificial Neural Network (ANN)-style
classifier in ACT/CHP. The design follows the flat file layout and
channel-oriented coding style used in the uploaded labs. The network topology
is a 2-2-1 feedforward ANN with two inputs, two hidden neurons, and one output
neuron.

The chosen toy problem is XOR. Three activation function variants are provided:

1. Step Function
2. ReLU
3. Sigmoid Approximation (piecewise linear)

All communication between stages is done through channels. Each network variant
now uses a real staged 2-2-1 ACT/CHP structure: hidden-layer sums are computed,
sent through activation processes, then combined into an output-layer sum and
sent through a final activation process. To stay compatible with the local ACT
toolchain, neuron sums are encoded onto a non-negative integer domain rather
than relying on signed intermediate values. The activation functions are also
available as separate reusable processes for isolated testing.


Files
-----
ann_components.act              - activation blocks and top-level ANN-style ACT processes
testbench_ann_step.act          - original forward-pass testbench for the step network
testbench_ann_relu.act          - original forward-pass testbench for the ReLU network
testbench_ann_sigmoid.act       - original forward-pass testbench for the sigmoid approximation network
testbench_ann_step_full.act     - full XOR truth-table testbench for the step network
testbench_ann_relu_full.act     - full XOR truth-table testbench for the ReLU network
testbench_ann_sigmoid_full.act  - full XOR truth-table testbench for the sigmoid approximation network
testbench_ann_step_edges.act    - exploratory edge tests for the step network
testbench_ann_relu_edges.act    - exploratory edge tests for the ReLU network
testbench_ann_sigmoid_edges.act - exploratory edge tests for the sigmoid approximation network
testbench_activation_step.act   - direct activation testbench for step_activation
testbench_activation_relu.act   - direct activation testbench for relu_activation
testbench_activation_sigmoid.act- direct activation testbench for sigmoid_activation
testbench_ann_throughput.act    - back-to-back pipeline throughput test
Makefile                        - convenience targets
run_sim.spi                     - non-interactive actsim command script
README.md                       - project description and usage


Network Architecture
--------------------
Topology: 2 inputs -> 2 hidden neurons -> 1 output neuron

ASCII diagram:

               /-------> H1 -------\
  IN1 ---------+                    \
               |                     ---> Y ---> OUT
  IN2 ---------+                    /
               \-------> H2 -------/

Each hidden neuron receives both inputs and contributes to the single output
neuron. The exported network variants implement this topology directly in CHP,
with channel-connected activation stages in the hidden and output layers.
Implemented network instances:

- ANNStep
- ANNReLU
- ANNSigmoid


Activation Functions
--------------------
Step Function
  Returns 1 when x >= 3 and 0 otherwise on the encoded domain.

ReLU
  Returns x - 2 when x > 2 and 0 otherwise on the encoded domain.

Sigmoid Approximation
  The currently simulated piecewise linear integer approximation is:
    x <= 2 -> 0
    x = 3  -> 2
    x >= 4 -> 4

The sigmoid approximation uses scaled integer outputs instead of floating-point
values, which makes it more practical for hardware-oriented CHP models.


Building and Running
--------------------
Prerequisites
~~~~~~~~~~~~~
Before running make, the following tools should be installed and available on
PATH.

| Tool | Used for |
|------|----------|
| actsim | Runs ACT/CHP simulations and executes the exported testbench process. |
| ACT toolset | Provides the ACT language front-end, CHP support, imports, and simulator integration. |
| make | Executes the build and simulation targets defined in the Makefile. |
| POSIX shell (sh/bash) | Runs the commands inside the Makefile targets. |
| rm | Removes generated output files during make clean. |

If your ACT installation uses environment variables such as ACT_HOME, set them
before running make.

Target reference
~~~~~~~~~~~~~~~~
| Target | Command | What it does | Expected output |
|--------|---------|--------------|-----------------|
| all | make all | Runs the three main XOR truth-table simulations. | Step, ReLU, and Sigmoid full tests complete without assertion failures. |
| sim | make sim | Alias for all. | Same result as make all. |
| step | make step | Runs only the Step ANN truth-table test bench. | actsim launches test_ann_step_full and exits cleanly. |
| relu | make relu | Runs only the ReLU ANN truth-table test bench. | actsim launches test_ann_relu_full and exits cleanly. |
| sigmoid | make sigmoid | Runs only the Sigmoid ANN truth-table test bench. | actsim launches test_ann_sigmoid_full and exits cleanly. |
| step-edges | make step-edges | Runs the exploratory Step edge test bench. | Bench runs if the local ACT parser accepts the literals used in the file. |
| relu-edges | make relu-edges | Runs the exploratory ReLU edge test bench. | Bench runs if the local ACT parser accepts the literals used in the file. |
| sigmoid-edges | make sigmoid-edges | Runs the exploratory Sigmoid edge test bench. | Bench runs if the local ACT parser accepts the literals used in the file. |
| edges | make edges | Runs all exploratory edge test benches. | Useful for manual experimentation; not required for the core pass path. |
| activation-step | make activation-step | Runs the direct Step activation test. | Step activation covers the low/high threshold split on the encoded domain. |
| activation-relu | make activation-relu | Runs the direct ReLU activation test. | ReLU activation covers the encoded-domain floor and passthrough slope. |
| activation-sigmoid | make activation-sigmoid | Runs the direct Sigmoid activation test. | Sigmoid activation covers the encoded-domain low, mid, and saturated regions. |
| activation | make activation | Runs all direct activation tests. | All three activation benches complete without assertion failures. |
| throughput | make throughput | Runs the back-to-back streaming test. | Continuous traffic completes without deadlock. |
| test | make test | Alias for all in the current Makefile. | Same result as make all. |
| check | make check | Alias for all in the current Makefile. | Same result as make all. |
| clean | make clean | Removes generated simulation artefacts. | *.out and *.txt files are deleted. |

Step-by-step walkthrough
~~~~~~~~~~~~~~~~~~~~~~~~
1. Open a terminal and move to the project directory.

   cd ann_async_project

2. Check that the simulator is visible on PATH.

   which actsim

   Expected result: a valid filesystem path such as /home/user/act-local/bin/actsim.

3. Run the core truth-table simulations.

   make all

   Expected output: the terminal echoes three actsim commands. If the tests
   pass, the simulator exits without assertion failures.

4. Run the activation tests.

   make activation-step
   make activation-relu
   make activation-sigmoid

   Expected result: each command launches one activation test bench and exits
   cleanly.

5. Run the throughput test.

   make throughput

   Expected result: the streaming test completes without deadlock or assertion
   failures.

6. Optional exploratory tests.

   make step-edges
   make relu-edges
   make sigmoid-edges

   These are useful for additional manual checks, but they are not part of the
   minimal known-good submission path.

7. Clean generated files.

   make clean

   Expected result: generated .out and .txt files are removed.

A successful run is usually quiet. In these test benches, correctness is mostly
signaled by the absence of assert(...) failures and by normal simulator exit.

Common failure modes
~~~~~~~~~~~~~~~~~~~~
| Problem | Likely cause | Fix |
|---------|--------------|-----|
| make: actsim: No such file or directory | The ACT simulator is not installed or not on PATH. | Install the ACT toolset and verify which actsim returns a valid path. |
| Import error for ann_components.act | Running make from the wrong directory. | Run commands from the project root that contains ann_components.act. |
| ACT_HOME or library lookup errors | ACT environment variables are unset or point to the wrong installation. | Export the correct ACT environment variables required by your ACT setup. |
| Simulation hangs | A send/receive handshake is unmatched, or a process connection is missing. | Re-check channel wiring and confirm every OUT! has a matching IN? in the active path. |
| Assertion failure | Expected output in the test bench does not match the network behaviour. | Recompute the exercised case and update either the test expectation or the implementation. |
| Parse/type errors on signed literals | Your local ACT version handles signed literal syntax differently. | Use temporary variables or avoid signed edge cases in the core regression path. |

How to add a new test
~~~~~~~~~~~~~~~~~~~~~
1. Copy an existing test bench such as testbench_ann_step_full.act.
2. Add or modify transactions in the chp block using the pattern IN1!x; IN2!y; OUT?z; assert(z = expected);
3. If testing an activation directly, instantiate the activation block and drive its int<16> input channel.
4. Add a Makefile target that runs the new exported test process with actsim and the existing run_sim.spi script.
5. Run the target from the project root and verify the simulation exits cleanly.


Test Results
------------
Known-good regression path
~~~~~~~~~~~~~~~~~~~~~~~~~~
The following targets have been confirmed as the current working baseline:

- make step
- make relu
- make sigmoid
- make activation-step
- make activation-relu
- make activation-sigmoid
- make throughput

Core XOR outputs
~~~~~~~~~~~~~~~~
Step network:
  (0,0) -> 0
  (0,1) -> 1
  (1,0) -> 1
  (1,1) -> 0

ReLU network:
  (0,0) -> 0
  (0,1) -> 1
  (1,0) -> 1
  (1,1) -> 0

Sigmoid approximation network (scaled output):
  (0,0) -> 0
  (0,1) -> 4
  (1,0) -> 4
  (1,1) -> 0

Interpreting output 4 as logical true gives the same XOR classification.

Comparative output table
~~~~~~~~~~~~~~~~~~~~~~~~
| Input | Step Out | ReLU Out | Sigmoid Out |
|-------|----------|----------|-------------|
| (0, 0) | 0 | 0 | 0 |
| (0, 1) | 1 | 1 | 4 |
| (1, 0) | 1 | 1 | 4 |
| (1, 1) | 0 | 0 | 0 |

Activation-isolation results
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The direct activation tests currently exercise non-negative integer inputs.
Observed outputs are:

- Step activation: inputs 0..5 -> outputs 1,1,1,1,1,1
- ReLU activation: inputs 0..5 -> outputs 0,1,2,3,4,5
- Sigmoid approximation: inputs 0..5 -> outputs 2,3,4,4,4,4


Comparison of Activation Functions
----------------------------------
| Activation | Behavior | Hardware cost | Latency | Accuracy on XOR |
|------------|----------|---------------|---------|-----------------|
| Step | Threshold at 0, binary output | Lowest: comparator + constant output select | Lowest | 4/4 correct |
| ReLU | Pass positive values, clamp zero to 0 | Low: comparator + datapath pass-through | Low | 4/4 correct |
| Sigmoid Approximation | Saturating piecewise linear integer output in {2,3,4} for the exercised domain | Highest of the three: multiple compares + saturation/encoding | Highest of the three | 4/4 correct (scaled) |

For the current working ACT version, Step and ReLU are the most direct to
interpret. The sigmoid approximation is still useful for demonstrating a
non-binary activation output, but it should be read as a scaled integer score
rather than a Boolean value.


Report Material
---------------
Introduction paragraph
~~~~~~~~~~~~~~~~~~~~~~
Asynchronous hardware is relevant for neural-network inference because inference
is naturally a dataflow problem: values move through multiply-accumulate stages,
activations, and layer-to-layer connections without requiring a single global
clock edge for every operation. This makes asynchronous design attractive for
modular pipelines, elastic timing, and systems where local handshaking can
absorb variable stage delays. The 2-2-1 ANN in this project is intentionally
small, but it demonstrates the essential structure of hardware inference: two
inputs are combined by a hidden layer and then reduced to a single output
classification. Using XOR as the toy problem makes the design meaningful, since
XOR cannot be solved by a single linear threshold unit. This report shows how
the network was implemented in ACT/CHP, how three activation functions behave
under integer hardware constraints, and how their outputs compare on the same
test set.

Network architecture description
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The implemented network is a feedforward 2-2-1 ANN with two inputs, two hidden
neurons, and one output neuron. At the interface level, both hidden neurons
conceptually depend on both inputs and contribute to the final classification.
In the ACT/CHP model, communication still occurs through channels, so execution
remains asynchronous and handshake-driven. The current working top-level version
prioritises robust simulation under the available ACT toolchain: the exported
network processes preserve the 2-2-1 ANN-style structure and XOR behaviour,
while the individual activation functions are also exposed as standalone blocks
for direct verification. The output represents a classification result for the
chosen toy problem, XOR. In the Step and ReLU variants the output is directly
binary for the tested inputs, while the sigmoid approximation produces a scaled
integer output that is interpreted as false/true by magnitude. The topology
corresponds to the ASCII diagram above.

Activation function analysis
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Step Function
  The step activation is defined as: output 1 if the input sum is greater than
  or equal to 0, otherwise output 0. In integer hardware this is especially
  attractive because it reduces the activation stage to a sign check at the
  chosen threshold. The implementation therefore needs only a comparator and
  logic to emit one of two constant output values. That makes the step function
  the cheapest option in both area and control complexity. Its main limitation
  is that it discards magnitude information immediately. Any non-negative sum,
  whether barely above zero or very large, becomes the same output.

ReLU
  ReLU is defined as: output the input sum if it is positive, otherwise output
  0. In integer hardware this is still simple, since the stage only needs a
  comparison against zero and a selection between the incoming datapath and
  zero. Compared with the step function, ReLU preserves positive magnitude
  information, which can be useful because later neurons can respond differently
  to weak and strong evidence. The cost is slightly higher than step because
  the datapath must pass variable values rather than only constants.

Sigmoid Approximation
  The currently exercised sigmoid approximation is a simple saturating integer
  function over the tested domain: 0 maps to 2, 1 maps to 3, and values 2 or
  larger map to 4. This avoids the exponential and division operations of a
  true sigmoid while still demonstrating a non-binary activation output. In
  hardware, the approximation needs several comparison cases and a small output
  encoding network, making it the most expensive of the three activations used
  here. Its main trade-off is that the result must be interpreted as a scaled
  score rather than as a direct Boolean output.

Results and comparison section
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The current known-good regression results show that all three network variants
classify the XOR truth table correctly, although they do so with different
output semantics. As summarized in the comparative output table above, the Step
network produces binary outputs 0, 1, 1, 0 for the four input vectors (0,0),
(0,1), (1,0), and (1,1). The ReLU network produces the same binary pattern on
the chosen Boolean inputs. The Sigmoid Approximation network also classifies XOR
correctly, but it produces scaled outputs 0, 4, 4, 0. These values must
therefore be interpreted as low/high rather than strict Boolean zero/one.

The activation-isolation tests clarify the functional differences between the
three activation blocks over the non-negative integer domain currently exercised
by the working test suite. Step collapses all tested values to logical true.
ReLU maps each positive integer to itself while keeping zero at zero, making it
the easiest activation to trace numerically. The sigmoid approximation produces
an intermediate scaled response before saturating. For a simple hardware
classifier, these results imply that Step and ReLU are easier to use directly,
while the sigmoid approximation is most useful when a graded confidence-like
signal is desired.

Conclusion paragraph
~~~~~~~~~~~~~~~~~~~~
This project implemented a working asynchronous 2-2-1 ANN-style XOR classifier
in ACT/CHP and demonstrated three activation behaviours: Step, ReLU, and a
piecewise integer Sigmoid Approximation. The design showed that a small neural-
network-inspired classifier can be expressed as communicating hardware processes
and simulated with ACT/CHP test benches. The core XOR truth-table tests, direct
activation tests, and throughput test all run successfully in the current
working baseline. The main takeaway is that activation choice affects both the
hardware complexity and the meaning of the output, even when the classification
result on the toy problem remains the same. A natural next step would be to
return to a more explicitly weighted MAC-based implementation once the ACT
syntax and signed-arithmetic behaviour are fully pinned down.

Suggested figures list
~~~~~~~~~~~~~~~~~~~~~~
| Figure | Description |
|--------|-------------|
| Network topology diagram | Show the 2-2-1 structure with two inputs, two hidden neurons, and one output neuron. |
| One complete forward-pass waveform/trace | Show a simulation trace for one input vector moving through the input handshakes and final output handshake. |
| Comparative output table | Present the table above showing XOR inputs and outputs for Step, ReLU, and Sigmoid Approximation. |
| Activation function comparison graph | Plot the three implemented activation curves over the tested integer domain. |
| Expanded test coverage summary | Show which tests cover truth table, direct activation checks, throughput, and exploratory edge cases. |
| Boundary-behaviour figure | Highlight the difference between Step at x = 0, ReLU at x = 0, and the integer sigmoid approximation over small input values. |


Report Section
--------------
Asynchronous pipelines are a good match for neural-network inference because a
forward pass is naturally decomposed into stages that communicate data from one
layer to the next. In a synchronous design, every stage must align to a global
clock even if the work done by each stage is uneven. In contrast, ACT/CHP
models let each stage proceed when data is available and the next stage is ready
to receive it. That makes the design modular, easy to compose, and naturally
backpressure-aware. In this project the design is expressed as communicating ACT
processes rather than as a single monolithic block, which fits the asynchronous
style well.

The three activation functions behave differently when restricted to integer
arithmetic. The step function is the simplest: it only checks whether the input
is non-negative and emits either 0 or 1. This is attractive in hardware because
it avoids expensive arithmetic after the decision point. ReLU is also hardware-
friendly because it only needs a comparison and a pass-through path for positive
values. It preserves magnitude information, which can be useful in larger
networks, but in a small integer design it can also require slightly wider
datapaths to avoid clipping. The sigmoid function is normally expensive in
hardware because it relies on exponentials and division. To keep the design
practical, this project uses a piecewise integer approximation with scaled
outputs. This keeps the control simple while still giving smoother, non-binary
behaviour.

There are clear trade-offs between accuracy, area and latency. The step
function usually has the smallest hardware area and shortest activation latency,
but it throws away magnitude information immediately. ReLU costs slightly more
because it forwards a variable value rather than a constant, yet it remains very
cheap. The sigmoid approximation has the largest control cost because it needs
several comparison regions and a saturating output encoding. In exchange, it
provides a richer output range that can better emulate a smooth nonlinearity.
For the XOR example used here, all three variants classify the dataset
correctly, although the sigmoid version uses scaled outputs rather than binary
ones.

A more complex model would require wider channels, more neurons, more layer-to-
layer fan-out, and probably explicit buffering between stages. Larger inputs
would increase arithmetic complexity and make weight storage a larger concern.
Deeper networks would also benefit from reusable templates for neurons and
layer-level wrappers so that the CHP description stays readable. At that point,
testing would also need to move beyond a few truth-table vectors and toward
automated regression sets with more extensive functional coverage.
