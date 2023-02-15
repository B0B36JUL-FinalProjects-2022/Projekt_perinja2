using Pkg
Pkg.activate(".")
using PredNets

g = deserialize("./examples/airline_passengers.yaml")

simulate!(g)

save_results(g; output_dir="outputs")