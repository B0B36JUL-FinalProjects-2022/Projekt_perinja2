using Distributions

include("models/ar.jl")
include("models/ma.jl")

import Base.show


function select_model(x::String)
    if x == "AR"
        AR
    elseif x == "MA"
        MA
    elseif x == "ARMA"
        ARMA
    end
end

mutable struct Node
    id::Int64
    noise_generator::Normal
    model::AR
    nodes::Dict{Int64,Node}
end

function Node(node_id::Int64, model::String, model_params::Vector{Float64}; μ::Float64=0., σ::Float64=1.0) 
    Node(node_id, Normal(μ, σ), select_model(model)(model_params), Dict{Int64,Node}())
end

function link_nodes!(left::Node, right::Node)
    left.nodes[right.id] = right
    right.nodes[left.id] = left
    nothing
end

function observe_and_predict!(node::Node, timestep::Int64, value::Float64)
    value += rand(node.noise_generator, 1)
    observe!(node.model, value)
    predict!(node.model, timestep)
end

function mix!(node::Node, timestep::Int64)
    predictions = Dict{Int64,Float64}(k => v.get_prediction(timestep) for (k, v) in node.nodes)
    predictions[node.id] = node.get_prediction(timestep)
    mix!(node.model, timestep, predictions)
end

function Base.show(io::IO, ::MIME"text/plain", node::Node)
    println(io, "Node($(node.id))")
    println(io, "links: $([x.first for x in node.nodes])")
    println(io, node.model)
end

nodes = [Node(i, 2, [1.0, 1.0]) for i in range(1, 10)];