ACTSIM = actsim
ACTSIM_FLAGS = -Wlang_subst:off
RUN_SCRIPT = run_sim.spi

all: step relu sigmoid

sim: all

step:
	$(ACTSIM) $(ACTSIM_FLAGS) testbench_ann_step_full.act test_ann_step_full < $(RUN_SCRIPT)

relu:
	$(ACTSIM) $(ACTSIM_FLAGS) testbench_ann_relu_full.act test_ann_relu_full < $(RUN_SCRIPT)

sigmoid:
	$(ACTSIM) $(ACTSIM_FLAGS) testbench_ann_sigmoid_full.act test_ann_sigmoid_full < $(RUN_SCRIPT)

step-edges:
	$(ACTSIM) $(ACTSIM_FLAGS) testbench_ann_step_edges.act test_ann_step_edges < $(RUN_SCRIPT)

relu-edges:
	$(ACTSIM) $(ACTSIM_FLAGS) testbench_ann_relu_edges.act test_ann_relu_edges < $(RUN_SCRIPT)

sigmoid-edges:
	$(ACTSIM) $(ACTSIM_FLAGS) testbench_ann_sigmoid_edges.act test_ann_sigmoid_edges < $(RUN_SCRIPT)

edges: step-edges relu-edges sigmoid-edges

activation-step:
	$(ACTSIM) $(ACTSIM_FLAGS) testbench_activation_step.act test_activation_step < $(RUN_SCRIPT)

activation-relu:
	$(ACTSIM) $(ACTSIM_FLAGS) testbench_activation_relu.act test_activation_relu < $(RUN_SCRIPT)

activation-sigmoid:
	$(ACTSIM) $(ACTSIM_FLAGS) testbench_activation_sigmoid.act test_activation_sigmoid < $(RUN_SCRIPT)

activation: activation-step activation-relu activation-sigmoid

throughput:
	$(ACTSIM) $(ACTSIM_FLAGS) testbench_ann_throughput.act test_ann_throughput < $(RUN_SCRIPT)

test: all
check: all

clean:
	rm -f *.out *.txt