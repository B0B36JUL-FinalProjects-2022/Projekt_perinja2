# PredNets

[![Build Status](https://github.com/B0B36JUL-FinalProjects-2022/Projekt_perinja2/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Eldeeqq/PredNets.jl/actions/workflows/CI.yml?query=branch%3Amain)

# Description
This package allows to simulate distributed timeseries modelling on graph of predictors.

# Configuration
In ordger to run the simulation a predictor graph must be apriori created.

It is possible to create the graph manually, or using `.yaml` config file.
The structure of the config file is as following:
```yml
process:
    - vector
    - vector
        ...
    - vector
nodes:
    - <model description>
edges:
-
    - U
    - V
...

```

For more informations see documentation or [example](examples/minimal_example.yaml)

# Tests
In order to run tests, either run [runtests.jl](test/runtests.jl) within REPL, or run 
```bash 
julia -i test/runtests.jl
```

# Examples
In [examples](examples) are two example scripts, that can be ran from REPL or directly using julia. The [minimal_example.jl](examples/minimal_example.jl) runs simulation of linearly increasing process on 3 connected nodes. The [airline_passengers.jl](examples/airline_passengers.jl) simulates network of four models on popular [airline passengers](https://github.com/jbrownlee/Datasets/blob/master/airline-passengers.csv) dataset.

# Documentation
For more information check out the documentation.
