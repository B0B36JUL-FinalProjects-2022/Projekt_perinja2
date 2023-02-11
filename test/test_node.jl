using Pkg
using PredNets
using Test
using Distributions


nodes_1 = [PredNets.Node(i, "AR", ; model_params=Dict(:weights => [1.0, 1.0])) for i in 1:3]
nodes_2 = [PredNets.Node(i, "MA"; model_params=Dict(:weights => [1.0, 1.0], :c => 0)) for i in 3:5]
nodes_3 = [PredNets.Node(i, "ARMA"; model_params=Dict(
    :ar_params=>Dict{Symbol, Any}(:weights=>[1., 1.]), 
    :ma_params=>Dict(:weights=>[1., 1.], :c=>1),
)) for i in 5:8]

for node in nodes_1
    PredNets.link_nodes!(nodes_2[1], node)
end

@test Set(keys(nodes_2[1].nodes)) == Set(collect(x.id for x in nodes_1))
