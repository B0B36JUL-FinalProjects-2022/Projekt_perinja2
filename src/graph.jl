using YAML
using Base.Filesystem

mutable struct Graph
    nodes::Dict{Int,Any}
    edges::Dict{Int,Vector{Int}}
    process::Vector{Float64}
    Graph() = new(Dict{Int,Any}(), Dict{Int,Vector{Int}}(), )
end

function add_edge!(graph, u, v)
    if haskey(graph.edges, u)
        push!(graph.edges[u], v)
    else
        graph.edges[u] = [v]
    end
    nothing
end

function deserialize(path::String)
    (stat(path) === nothing || !isfile(path)) && error("Wrong path to config file provided.")

    config = open(path) do f
        YAML.load(f, dicttype=Dict{Symbol,Any})
    end
    graph = Graph()
    for node in config[:nodes]
        curr_node = Node(
            length(graph.nodes) + 1,
            node[:model],
            node[:model_params];
            μ=node[:noise_mu],
            σ=node[:noise_sigma]
        )
        graph.nodes[curr_node.id] = curr_node
    end

    for (u, v) in config[:edges]
       add_edge!(graph, u, v)
       add_edge!(graph, v, u)
    end

    typeof(config[:process])
    graph.process = config[:process]

    return graph
end

function serialize(graph::Graph, file::String)
    out = Dict{Symbol, Any}()

    nodes = Vector{Dict{Symbol, Any}}()
    for (_, node) in graph.nodes
        push!(nodes, serialize(node))
    end
    out[:nodes] = nodes

    edges = Set{Vector{Int64}}()
    for (src, nodes) in graph.edges
        for node in nodes
            u = min(src, node)
            v = max(src, node)
            push!(edges, [u, v])
        end
    end
    out[:edges] = [x; for x in edges]

    out[:process] = graph.process

    YAML.write_file(file, out);
    nothing
end
