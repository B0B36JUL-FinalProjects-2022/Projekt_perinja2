using PredNets
using Test

@testset "PredNets.jl" begin
    include("test_ar.jl")
    include("test_ma.jl")
    include("test_arma.jl")
    include("test_node.jl")
end
