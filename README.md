# Async ANN Pipeline in ACT/CHP

This project implements a small asynchronous ANN-style hardware pipeline in
ACT/CHP. The toy problem is XOR, implemented as a fixed 2-2-1 feedforward
classifier with two inputs, two hidden activation stages, and one output stage.

Three activation variants are included:

- Step: `x >= 3 -> 1`, otherwise `0`
- ReLU: `x > 2 -> x - 2`, otherwise `0`
- Sigmoid approximation: `x <= 2 -> 0`, `x = 3 -> 2`, `x >= 4 -> 4`

This is intentionally a fixed XOR-focused ANN-style demonstrator. It is not a
trainable ANN framework and does not support arbitrary topologies or learned
weights. The equations are hand-derived for XOR and encoded onto a non-negative
integer domain to keep the CHP model compatible with the local ACT toolchain.

## Folder Structure

```text
.
├── README.md
├── Makefile
├── run_sim.spi
├── src/
│   └── ann_components.act
├── tests/
│   ├── activation/
│   ├── ann/
│   └── exploratory/
├── report/
│   └── report.md
├── docs/
└── tools/
```

The core implementation is in `src/ann_components.act`. The main regression
tests are in `tests/ann/` and `tests/activation/`. Exploratory edge tests are
kept separately in `tests/exploratory/`.

## ACT Setup

Run these commands before using the Makefile:

```sh
export ACT_HOME=/home/chrwa/schoolProjects/actflow/
export PATH=$PATH:$ACT_HOME/bin
```

Check that the simulator is visible:

```sh
which actsim
```

Expected path:

```text
/home/chrwa/schoolProjects/actflow/bin/actsim
```

## Core Verification

From the project root, run:

```sh
make clean
make all
make activation
make throughput
```

Expected result: all commands complete without ACT assertion failures.

The core targets cover:

- `make all`: XOR truth-table tests for Step, ReLU, and Sigmoid variants.
- `make activation`: isolated activation-function tests.
- `make throughput`: back-to-back transaction tests for Step, ReLU, and Sigmoid.

Optional exploratory tests:

```sh
make edges
```

## Verified Baseline

Verified on 2026-05-19 with:

```sh
export ACT_HOME=/home/chrwa/schoolProjects/actflow/
export PATH=$PATH:$ACT_HOME/bin
make clean
make all
make activation
make throughput
make edges
```

Result: all listed targets completed without assertion failures.
