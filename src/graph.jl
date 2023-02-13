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
    graph.process =  :process in keys(config) ? config[:process] : nothing
    return graph
end

function serialize(graph::Graph, file::String)
    out = Dict{Symbol, Any}()

    nodes = Vector{Dict{Symbol, Any}}()
    for (_, node) in sort(collect(graph.nodes), by=x->x[1])   
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
    out[:edges] = [x; for x in sort(collect(edges))]
    if !isnothing(graph.process) 
        out[:process] = graph.process
    end

    YAML.write_file(file,out);
    nothing
end

function simulate!(graph::Graph; process::Union{Nothing, Vector{Float64}}=nothing)

    sim_proc = !isnothing(graph.process) ? graph.process : process
    isnothing(sim_proc) && error("Graph has no process, nor was one provided.")

    for (i, x) in enumerate(sim_proc)
        @info "process at time $i"
        for node in values(graph.nodes)
            observe_and_predict!(node, i, x)
        end
        for node in values(graph.nodes)
            # todo get neighbor predictions
            mix!(node, i; mix_func=x->mean(values(x)))
        end  
    end

    #TODO generate report
end
