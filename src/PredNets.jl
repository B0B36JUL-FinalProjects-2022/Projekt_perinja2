module PredNets
# export SetNoise, Pair, Measurement, Terminate, Ok, Error
    # include("models/ar.jl")
    # include("models/ma.jl")
    include("models/arma.jl")
    include("graph.jl")
    include("node.jl")
    include("graph_generator.jl")
end