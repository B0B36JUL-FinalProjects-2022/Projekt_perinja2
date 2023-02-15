using PredNets
using Test

ar_params = Dict{Symbol, Any}(:weights=>[1.2, 0.9])
ma_params = Dict{Symbol, Any}(:weights=>[1.2, 0.9], :c=>1)

n1 = Node(1, "AR", ar_params)
n2 = Node(1, "MA", ma_params)
n3 = Node(1, "ARMA"; model_params=Dict(:ar_params=>ar_params, :ma_params=>ma_params))

g = Graph()   
g.nodes = Dict{Int64, Node}(1=>n1, 2=>n2, 3=>n3) 
g.edges = Dict{Int ,Vector{Int}}(1=>[2,3], 2=>[1,3], 3=>[1,2])
g.process = [x/3 for x in range(1,60)]

file = "$(tempname()).yml"
serialize(g, file)

b = deserialize(file)

@test g.edges == b.edges
@test g.process == b.process

for i in keys(g.nodes)
    @test typeof(g.nodes[i]) == typeof(b.nodes[i])
    @test serialize(g.nodes[i].model) == serialize(b.nodes[i].model)
end
println("test_graph.jl: tests passed")
nothing