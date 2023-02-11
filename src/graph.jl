using YAML
using Base.Filesystem


mutable struct Graph
    nodes::Dict{Int,Node}
    edges::Dict{Int,Vector{Int}}
    process::Vector{Float64}
    Graph() = (Dict{Int,Node}(), Dict{Int,Vector{Int}}(), )
end

function add_edge!(graph, u, v)
    if haskey(graph.edges, u)
        push!(graph.edges[u], v)
    else
        graph.edges[u] = [v]
    end
    nothing
end

function load_from_yaml(path::String)
    (stat(path) === nothing || !isfile(path)) && error("Wrong path to config file provided.")

    config = open(path) do f
        YAML.load(f)
    end
    graph = Graph()

    for node in config["nodes"]
        # TODO = change it so the node accepts string identifier and model params, then noise
        curr_node = Node(
            length(nodes) + 1,
            node["model"],
            node["model_params"],
            μ=node["noise_mu"],
            σ=node["noise_sigma"]
        )
        graph.nodes[curr_node.id] = curr_node
    end

    for (u, v) in config["edges"]
       add_edge!(graph, u, v)
       add_edge!(graph, v, u)
    end
    nothing
end

