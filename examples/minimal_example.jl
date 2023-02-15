using Pkg
Pkg.activate(".")
using PredNets

g = deserialize("./examples/minimal_example.yaml")

simulate!(g)

save_results(g; output_dir="outputs")