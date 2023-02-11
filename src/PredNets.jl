module PredNets
# export SetNoise, Pair, Measurement, Terminate, Ok, Error
export AR, MA, ARMA, Node, Graph, observe!, predict!, mix!, plt

    include("models/model.jl")
    include("models/ar.jl")
    include("models/ma.jl")
    include("models/arma.jl")
    include("graph.jl")
    include("node.jl")
    include("graph_generator.jl")
end