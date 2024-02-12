# segul-bench

This repo hosts scripts and data for Handika and Esselstyn. [In review](https://www.authorea.com/doi/full/10.22541/au.165167823.30911834/v1).

## Requirements

- [Fish Shell](https://fishshell.com/)
- [Git](https://git-scm.com/)
- [GH CLI (optional)](https://cli.github.com/)
- [R](https://www.r-project.org/)
- [RStudio](https://www.rstudio.com/)

## Cloning the repository

```bash
gh repo clone hhandika/segul-bench
```

Or using git:

```bash
git clone https://github.com/hhandika/segul-bench
```

## Running the benchmark scripts

The scripts are written in [FISH SHELL](https://fishshell.com/). The latest revision of the manuscript only conducted automatic benchmarks on Linux. The GUI benchmark was done manually and inputted later into the automatic benchmark results.

### Download the data

Follow the link in the manuscript to download the data. The data is not included in this repository.

Create a `alignments` directory in the root of the repository. Then, move the data to the `alignments` directory.

```bash
cd segul-bench
```

```bash
mkdir alignments
```

### Benchmarking

We recommend copying the scripts to the same PATH environment of your Linux machine. The scripts are optimized for FISH SHELL. The scripts files are named based on the type of analysis and data type.

```bash
cp scripts/linux/* [PATH-ENV]
```

Then, run the scripts in the directory where the data is located.

For example, to run concatenation benchmark for DNA data:

```bash
concat_bench_openSUSE.sh
```

Running multiple scripts at once:

```bash
concat_bench_openSUSE.sh && concat_bench_AA_openSUSE.sh
```

## Analyzing the results

The latest version of the manuscript uses the data in `data/ms_rev2`. The data was parsed using [bench-parser](https://github.com/hhandika/bench-parser). The result is saved as `data/data_ms_rev2.csv`. You can use the data to reproduce the analysis in the manuscript. The scripts should work on any operating system where R and RStudio are installed. We use RMarkdown to write the main R scripts.

### Steps

1. Open `segul-bench.Rproj` in RStudio.

2. Open `R/benchmark.Rmd` in RStudio.

3. Run the script.
