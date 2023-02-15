using Pkg
using Distributions
import Base.show
using CSV

"""
    select_model(x::String)

Returns a Model Type based on the input string.
"""
function select_model(x::String)
    if x == "AR"
        AR
    elseif x == "MA"
        MA
    elseif x == "ARMA"
        ARMA
    end
end

"""
A Node object is used to represent a node in a graph. Each node has an ID, a noise generator, a model and a dictionary of nodes it is connected to.

Fields:
- id::Int64: unique identifier for the node
- noise_generator::Normal: a Normal distribution used to add noise to observed values
- model::Model: the statistical model used by the node to generate predictions
- nodes::Dict: a dictionary with key-value pairs of the node's connected nodes

"""
mutable struct Node
    id::Int64
    noise_generator::Normal
    model::Model
    nodes::Dict
    """
        Node(node_id::Int64, model::String, model_params::Dict; μ::Float64=0.0, σ::Float64=1.0)

    Construct a new Node object with a given ID, model and model parameters.

    Arguments:
    - node_id::Int64: unique identifier for the node
    - model::String: the name of the model to use for the node
    - model_params::Dict: a dictionary with key-value pairs of the model's parameters
    - μ::Float64: the mean of the Normal distribution used for adding noise (default 0.0)
    - σ::Float64: the standard deviation of the Normal distribution used for adding noise (default 1.0)

    """
    function Node(node_id::Int64, model::String, model_params::Dict; μ::Float64=0.0, σ::Float64=1.0)
        new(node_id, Normal(μ, σ), select_model(model)(; model_params...), Dict{Int64,Node}())
    end
    function Node(node_id::Int64, model::String; model_params::Dict)
        Node(node_id, model, model_params)
    end

end

"""
    link_nodes!(left::Node, right::Node)

Adds a connection between two nodes.

Arguments:
- left::Node: the first node
- right::Node: the second node

"""
function link_nodes!(left::Node, right::Node)
    left.nodes[right.id] = right
    right.nodes[left.id] = left
    nothing
end

"""
    observe_and_predict!(node::Node, timestep::Int64, value::Float64)

Adds a new value to a node's model and generates a new prediction for the given timestep

Arguments:
- node::Node: the node to add the value to and generate a prediction for
- timestep::Int64: the timestep to generate a prediction for
- value::Float64: the observed value to add to the model

"""
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

function serialize(node::Node)
    Dict{Symbol,Any}(
        :model =>String(nameof(typeof(node.model))),
        :model_params => serialize(node.model),
        :noise_mu => mean(node.noise_generator),
        :noise_sigma => std(node.noise_generator)
    )
end

get_prediction(node::Node, timestep::Int64) = get_prediction(node.model, timestep)

"""
Plots and saves the prediction results for a given node in a directory.

Args:
- node: the Node whose prediction results should be plotted and saved.
- output_dir: a string representing the directory where the results should be saved.
- kw: additional keyword arguments that are passed to the Plots.jl plotting function.

"""
function save_results(node::Node; output_dir::String, kw...)
    
    df = node.model.df
    x = 1:nrow(df)

    plot(x, df.observed, label="observed", kw...)
    plot!(x, df.predicted, label="predicted", kw...)
    plot!(x, df.mixed, label="mixed", kw...)

    title!("Prediction results for node $(node.id)")
    xlabel!("x")
    ylabel!("y")

    png("$output_dir/results_$(node.id).png")
    CSV.write("$output_dir/out_$(node.id).csv", df)
    nothing
end