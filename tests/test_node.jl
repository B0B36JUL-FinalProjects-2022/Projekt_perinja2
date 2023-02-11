using Pkg
# Pkg.activate("../$(pwd())")
using LinearAlgebra
using MyModule
using Test
using Distributions

# include("../src/node.jl")

nodes_1 = [MyModule.Node(i, "AR", ; model_params=Dict(:weights => [1.0, 1.0])) for i in 1:3]
nodes_2 = [Node(i, "MA"; model_params=Dict(:weights => [1.0, 1.0], :c => 0)) for i in 3:5]
nodes_3 = [Node(i, "ARMA"; model_params=Dict(
    :ar_params=>Dict{Symbol, Any}(:weights=>[1., 1.]), 
    :ma_params=>Dict(:weights=>[1., 1.], :c=>1),
)) for i in 5:8]