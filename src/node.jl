using Pkg
using Distributions
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
    model::Model
    nodes::Dict
    function Node(node_id::Int64, model::String, model_params::Dict; μ::Float64=0.0, σ::Float64=1.0)
        new(node_id, Normal(μ, σ), select_model(model)(; model_params...), Dict{Int64,Node}())
    end
    function Node(node_id::Int64, model::String; model_params::Dict)
        Node(node_id, model, model_params)
    end

end

function link_nodes!(left::Node, right::Node)
    left.nodes[right.id] = right
    right.nodes[left.id] = left
    nothing
end

function observe_and_predict!(node::Node, timestep::Int64, value::Float64)
    value += rand(node.noise_generator)
    observe!(node.model, value)
    predict!(node.model, timestep)
end

function mix!(node::Node, timestep::Int64; mix_func::Function)
    predictions = Dict{Int64,Float64}(k => get_prediction(v, timestep) for (k, v) in node.nodes)
    value = get_prediction(node, timestep)
    predictions[node.id] = value
    mix!(node.model, timestep, predictions; mix_func=mix_func)
end

function Base.show(io::IO, ::MIME"text/plain", node::Node)
    println(io, "Node($(node.id))")
    println(io, "links: $([x.first for x in node.nodes])")
    println(io, node.model)
end

function plt(node::Node; kw...)
    df = node.model.df
    x = 1:nrow(df)
    plot(x, df.observed, label="observed", kw...)
    plot!(x, df.predicted, label="predicted", kw...)
    plot!(x, df.mixed, label="mixed", kw...)
    title!("Prediction results for node $(node.id)")
    xlabel!("x")
    ylabel!("y")
end

function serialize(node::Node)
    Dict{Symbol,Any}(
        :model =>String(nameof(typeof(node.model))),
        :model_params => serialize(node.model),
        :noise_mu => mean(node.noise_generator),
        :noise_sigma => std(node.noise_generator)
    )
end

get_prediction(node::Node, timestep::Int64) = get_prediction(node.model, timestep)
