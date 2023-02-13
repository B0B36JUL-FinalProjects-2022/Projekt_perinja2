using Pkg
Pkg.activate("")
using PredNets

g = deserialize("./examples/config.yaml")
simulate!(g)