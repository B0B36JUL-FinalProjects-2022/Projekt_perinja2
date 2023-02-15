using YAML
using Base.Filesystem
using SHA
using Dates

using GraphRecipes
using Plots

gr()
"""
    mutable struct Graph

Graph structure to represent a prediction network.

# Attributes
- `nodes`: a dictionary to store node objects.
- `edges`: a dictionary to store edges between nodes.
- `process`: a vector of `Float64` values representing the input signal to the prediction network.

# Examples
```@julia
julia> g = Graph()

julia> n1 = Node(1, MA, Dict(:c => 1, :weights => [1.4, -0.5]), μ=0.0, σ=0.1)
julia> n2 = Node(2, AR, Dict(:weights => [1.1, -0.2]), μ=0.0, σ=0.1)

julia> add_edge!(g, n1.id, n2.id)

julia> g.nodes[n1.id] = n1
julia> g.nodes[n2.id] = n2

julia> simulate!(g, output_dir="./results")

julia> save_results(g)
```
"""
mutable struct Graph
    nodes::Dict{Int,Any}
    edges::Dict{Int,Vector{Int}}
    process::Vector{Float64}
    Graph() = new(Dict{Int,Any}(), Dict{Int,Vector{Int}}(), )
end
"""
    add_edge!(graph::Graph, u::Int, v::Int)

Add an edge between the nodes with IDs `u` and `v` to the graph.

# Arguments
- `graph`: a Graph object to add the edge to.
- `u`: the ID of the first node to connect.
- `v`: the ID of the second node to connect.

# Examples
```@julia

julia> g = Graph()
julia> add_edge!(g, 1, 2)
julia> add_edge!(g, 2, 3)
```

"""
function add_edge!(graph, u, v)
    if haskey(graph.edges, u)
        push!(graph.edges[u], v)
    else
        graph.edges[u] = [v]
    end
    nothing
end
"""
    deserialize(path::String)

Deserialize a graph from a YAML file at `path`.

# Arguments
- `path`: the path to the YAML file containing the graph information.

# Examples
```@julia
julia> g = deserialize("graph.yaml")
```
"""
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

function serialize_nodes!(graph::Graph, out::Dict{Symbol, Any})
    @debug "Serializing nodes."
    nodes = Vector{Dict{Symbol, Any}}()
    for (_, node) in sort(collect(graph.nodes), by=x->x[1])   
        push!(nodes, serialize(node))
    end
    out[:nodes] = nodes
    @debug "Serializing OK."
    nothing
end

function serialize_edges!(graph::Graph, out::Dict{Symbol, Any})
    @debug "Serializing edges."
    edges = Set{Vector{Int64}}()
    for (src, nodes) in graph.edges
        for node in nodes
            u = min(src, node)
            v = max(src, node)
            push!(edges, [u, v])
        end
    end
    out[:edges] = [x; for x in sort(collect(edges))]
    @debug "Serializing OK."
    nothing
end

function serialize_process!(graph::Graph, out::Dict{Symbol, Any})
    @debug "Serializing process."
    if !isnothing(graph.process) 
        out[:process] = graph.process
    end
    @debug "Serializing OK."
    nothing
end
"""
    serialize(graph::Graph, file::String)

Serialize a graph to a YAML file at `file`.

# Arguments
- `graph`: the graph to serialize.
- `file`: the file path to save the YAML file.
"""
function serialize(graph::Graph, file::String)
    @debug "Serializing graph to file $file."
    out = Dict{Symbol, Any}()

    serialize_nodes!(graph, out)
    serialize_edges!(graph, out)
    serialize_process!(graph, out)

    YAML.write_file(file, out);
    @info "Graph saved into $out"
    nothing
end

"""
Generates a graph visualization and saves it to a PNG file in the given directory.

# Arguments
- graph::Graph: The `Graph` object to visualize.
- output_dir::String: The path to the directory where the visualization will be saved. Defaults to the current directory.

"""
function create_graph_plot(graph::Graph; output_dir::String=".")
    mat = zeros(Int64, length(graph.nodes), length(graph.nodes))

    for (u, neighbors) in graph.edges
        for v in neighbors
            mat[u, v] = 1
            mat[v, u] = 1
        end
    end
    cmap = Dict{Any, String}(MA=>"#e74c3c", AR=>"#2ecc71", ARMA=>"#f1c40f")
    plt = graphplot(mat, names = [id for id in keys(graph.nodes)], 
    nodeshape = :circle, 
    markercolor = [cmap[typeof(n.model)] for n in values(graph.nodes)],
    node_weights = [10 for _ in keys(graph.nodes)], 
    curvature_scalar = 0.05)

    title!( "Prediction network")
    png(plt, "$output_dir/graph.png")
    nothing 
end

"""
        simulate!(graph::Graph; 
        process::Union{Nothing, Vector{Float64}}=nothing, 
        output_dir::Union{String, Nothing}=nothing
        )
    Simulates the process of a graph using the given data, or the graph's own data if none is provided.

    Arguments:
    - graph::Graph: The `Graph` object to simulate.
    - process::Union{Nothing, Vector{Float64}}: The data to use for the simulation, or `nothing` to use the graph's own data. Defaults to `nothing`.
    - output_dir::Union{String, Nothing}: The path to the directory where the simulation results will be saved, or `nothing` to use a temporary directory. Defaults to `nothing`.

    """
function simulate!(graph::Graph; 
    process::Union{Nothing, Vector{Float64}}=nothing, 
    output_dir::Union{String, Nothing}=nothing
    )
    @info "Starting simulation."
    sim_proc = !isnothing(graph.process) ? graph.process : process
    isnothing(sim_proc) && error("Graph has no process, nor was one provided.")
    @info "Process is present."

    for (i, x) in enumerate(sim_proc)
        @info "step $i"
        for node in values(graph.nodes)
            observe_and_predict!(node, i, x)
        end
        @info "predicting done for step $i"
        @info "mixing predictions"
        for node in values(graph.nodes)
            mix!(node, i; mix_func=x->mean(values(x)))
        end  
        @info "mixing done for step $i"
    end
    @info "No more data."
    save_results(graph; output_dir=output_dir)    
end

"""
    save_results(graph::Graph; output_dir="path")
Saves the results of a graph simulation to a directory.

Arguments:
- `graph::Graph`: The `Graph` object containing the simulation results to save.
- `output_dir::Union{Nothing, String}`: The path to the directory where the simulation results will be saved, or `nothing` to use a temporary directory.

Returns:
- `nothing`.
"""
function save_results(graph::Graph; output_dir::Union{Nothing, String})
    if isnothing(output_dir)
        output_dir = tempdir()
    end
    run_dir = joinpath((output_dir, bytes2hex(sha3_224("$(now())"))))
    @info "Creating file://$run_dir"
    mkdir(run_dir)

    create_graph_plot(graph; output_dir=run_dir)

    for (_, node) in graph.nodes
        save_results(node; output_dir=run_dir)
    end

end
