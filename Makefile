ACTSIM = actsim
ACTSIM_FLAGS = -Wlang_subst:off
RUN_SCRIPT = run_sim.spi
ANN_TEST_DIR = tests/ann
ACTIVATION_TEST_DIR = tests/activation
EXPLORATORY_TEST_DIR = tests/exploratory

.PHONY: all sim step relu sigmoid step-edges relu-edges sigmoid-edges edges activation-step activation-relu activation-sigmoid activation throughput test check clean

all: step relu sigmoid

sim: all

step:
	cd $(ANN_TEST_DIR) && $(ACTSIM) $(ACTSIM_FLAGS) testbench_ann_step_full.act test_ann_step_full < ../../$(RUN_SCRIPT)

relu:
	cd $(ANN_TEST_DIR) && $(ACTSIM) $(ACTSIM_FLAGS) testbench_ann_relu_full.act test_ann_relu_full < ../../$(RUN_SCRIPT)

sigmoid:
	cd $(ANN_TEST_DIR) && $(ACTSIM) $(ACTSIM_FLAGS) testbench_ann_sigmoid_full.act test_ann_sigmoid_full < ../../$(RUN_SCRIPT)

step-edges:
	cd $(EXPLORATORY_TEST_DIR) && $(ACTSIM) $(ACTSIM_FLAGS) testbench_ann_step_edges.act test_ann_step_edges < ../../$(RUN_SCRIPT)

relu-edges:
	cd $(EXPLORATORY_TEST_DIR) && $(ACTSIM) $(ACTSIM_FLAGS) testbench_ann_relu_edges.act test_ann_relu_edges < ../../$(RUN_SCRIPT)

sigmoid-edges:
	cd $(EXPLORATORY_TEST_DIR) && $(ACTSIM) $(ACTSIM_FLAGS) testbench_ann_sigmoid_edges.act test_ann_sigmoid_edges < ../../$(RUN_SCRIPT)

edges: step-edges relu-edges sigmoid-edges

activation-step:
	cd $(ACTIVATION_TEST_DIR) && $(ACTSIM) $(ACTSIM_FLAGS) testbench_activation_step.act test_activation_step < ../../$(RUN_SCRIPT)

activation-relu:
	cd $(ACTIVATION_TEST_DIR) && $(ACTSIM) $(ACTSIM_FLAGS) testbench_activation_relu.act test_activation_relu < ../../$(RUN_SCRIPT)

activation-sigmoid:
	cd $(ACTIVATION_TEST_DIR) && $(ACTSIM) $(ACTSIM_FLAGS) testbench_activation_sigmoid.act test_activation_sigmoid < ../../$(RUN_SCRIPT)

activation: activation-step activation-relu activation-sigmoid

throughput:
	cd $(ANN_TEST_DIR) && $(ACTSIM) $(ACTSIM_FLAGS) testbench_ann_throughput.act test_ann_throughput < ../../$(RUN_SCRIPT)

test: all
check: all

clean:
	rm -f *.out *.txt .actsim_history tests/ann/*.out tests/ann/*.txt tests/ann/.actsim_history tests/activation/*.out tests/activation/*.txt tests/activation/.actsim_history tests/exploratory/*.out tests/exploratory/*.txt tests/exploratory/.actsim_history
