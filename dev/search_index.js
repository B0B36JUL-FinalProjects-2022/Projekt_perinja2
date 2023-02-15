var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = PredNets","category":"page"},{"location":"#PredNets","page":"Home","title":"PredNets","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for PredNets.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"This package allows to simulate distributed timeseries modelling on graph of  predictors.","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: graph)","category":"page"},{"location":"#Currently-supported-models","page":"Home","title":"Currently supported models","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"- AR\n- MA\n- ARMA\n- ~~Kalman Filter~~","category":"page"},{"location":"#Configuration","page":"Home","title":"Configuration","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"info: config.yaml\nIn ordger to run the simulation a predictor graph must be apriori created.It is possible to create the graph manually, or using .yaml config file. The structure of the config file is as following:process:\n    - vector\n    - vector\n        ...\n    - vector\nnodes:\n    - <model description>\nedges:\n-\n    - U\n    - V\n...\n","category":"page"},{"location":"","page":"Home","title":"Home","text":"info: model coniguration\nEach model has its own config definition, but they share mandatory parameters sigma and mu, which represent the distribution for the external noise  when measuring the data.nodes:\n    - model: \"<model type>\"\n        noise_sigma: 1.4\n        noise_mu: 0.0\n        <model specific params>","category":"page"},{"location":"","page":"Home","title":"Home","text":"info: AR\nAR needs only weights.nodes:\n    - model: \"AR\"\n        noise_sigma: 1.4\n        noise_mu: 0.0\n        weights:\n            - B_1\n            - B_2\n            ...\n            - B_n\n","category":"page"},{"location":"","page":"Home","title":"Home","text":"info: MA\nMA needs weigts and cnodes:\n    - model: \"MA\"\n        noise_sigma: 1.4\n        noise_mu: 0.0\n        c: 0\n        weights:\n            - B_1\n            - B_2\n            ...\n            - B_n\n","category":"page"},{"location":"","page":"Home","title":"Home","text":"info: ARMA\nARMA has ar_params and ma_params which each contains respective params.nodes:\n    - model: \"ARMA\"\n        noise_mu: 0.0\n        noise_sigma: 1.4\n        ar_params: ...\n        ma_params: ...\n","category":"page"},{"location":"#Minimal-example","page":"Home","title":"Minimal example","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"using PredNets\n\ng = deserialize(\"./examples/minimal_example.yaml\")\n\nsimulate!(g)\n\nsave_results(g; output_dir=\"outputs\")","category":"page"},{"location":"#List-of-functionality","page":"Home","title":"List of functionality","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [PredNets]","category":"page"},{"location":"#PredNets.AR","page":"Home","title":"PredNets.AR","text":"Autoregressive (AR) model struct.\n\nFields\n\ndeg: integer value representing the degree of the model\nweights: vector of Float64 representing the model weights\nn: integer value representing the number of data points used in the model\ndf: DataFrame with columns:\nobserved: vector of Float64 representing the observed values\npredicted: vector of Float64 representing the predicted values\nmixed: vector of Float64 representing the mixed values\n\n\n\n\n\n","category":"type"},{"location":"#PredNets.ARMA","page":"Home","title":"PredNets.ARMA","text":"Autoregressive moving average (ARMA) model struct.\n\nFields\n\nar: AR struct representing the autoregressive part of the model\nma: MA struct representing the moving average part of the model\ndeg: integer value representing the degree of the model\nn: integer value representing the number of data points used in the model\ndf: DataFrame with columns:\nobserved: vector of Float64 representing the observed values\npredicted: vector of Float64 representing the predicted values\nmixed: vector of Float64 representing the mixed values\n\n\n\n\n\n","category":"type"},{"location":"#PredNets.Graph","page":"Home","title":"PredNets.Graph","text":"mutable struct Graph\n\nGraph structure to represent a prediction network.\n\nAttributes\n\nnodes: a dictionary to store node objects.\nedges: a dictionary to store edges between nodes.\nprocess: a vector of Float64 values representing the input signal to the prediction network.\n\nExamples\n\njulia> g = Graph()\n\njulia> n1 = Node(1, MA, Dict(:c => 1, :weights => [1.4, -0.5]), μ=0.0, σ=0.1)\njulia> n2 = Node(2, AR, Dict(:weights => [1.1, -0.2]), μ=0.0, σ=0.1)\n\njulia> add_edge!(g, n1.id, n2.id)\n\njulia> g.nodes[n1.id] = n1\njulia> g.nodes[n2.id] = n2\n\njulia> simulate!(g, output_dir=\"./results\")\n\njulia> save_results(g)\n\n\n\n\n\n","category":"type"},{"location":"#PredNets.MA","page":"Home","title":"PredNets.MA","text":"This struct represents a moving average (MA) model. It stores the model's degree, the weights of the model, a constant c, a noise generator, a vector to store the noise values, the number of observations, and a DataFrame to store observed, predicted and mixed values.\n\n\n\n\n\n","category":"type"},{"location":"#PredNets.Model","page":"Home","title":"PredNets.Model","text":"Model is an abstract supertype for all models.\n\n\n\n\n\n","category":"type"},{"location":"#PredNets.Node","page":"Home","title":"PredNets.Node","text":"A Node object is used to represent a node in a graph. Each node has an ID, a noise generator, a model and a dictionary of nodes it is connected to.\n\nFields:\n\nid::Int64: unique identifier for the node\nnoise_generator::Normal: a Normal distribution used to add noise to observed values\nmodel::Model: the statistical model used by the node to generate predictions\nnodes::Dict: a dictionary with key-value pairs of the node's connected nodes\n\n\n\n\n\n","category":"type"},{"location":"#PredNets._observe!-Union{Tuple{M}, Tuple{M, Float64}} where M<:Model","page":"Home","title":"PredNets._observe!","text":"_observe!(model::M, value::Float64)\n\n_observe! is a helper function that is not meant to be called by the user. It takes a Model struct and a Float64  value. It increments the n attribute of the model, and inserts a row with the observed value in the observed  column of the DataFrame.\n\n\n\n\n\n","category":"method"},{"location":"#PredNets.add_edge!-Tuple{Any, Any, Any}","page":"Home","title":"PredNets.add_edge!","text":"add_edge!(graph::Graph, u::Int, v::Int)\n\nAdd an edge between the nodes with IDs u and v to the graph.\n\nArguments\n\ngraph: a Graph object to add the edge to.\nu: the ID of the first node to connect.\nv: the ID of the second node to connect.\n\nExamples\n\n\njulia> g = Graph()\njulia> add_edge!(g, 1, 2)\njulia> add_edge!(g, 2, 3)\n\n\n\n\n\n","category":"method"},{"location":"#PredNets.create_graph_plot-Tuple{Graph}","page":"Home","title":"PredNets.create_graph_plot","text":"Generates a graph visualization and saves it to a PNG file in the given directory.\n\nArguments\n\ngraph::Graph: The Graph object to visualize.\noutput_dir::String: The path to the directory where the visualization will be saved. Defaults to the current directory.\n\n\n\n\n\n","category":"method"},{"location":"#PredNets.deserialize-Tuple{String}","page":"Home","title":"PredNets.deserialize","text":"deserialize(path::String)\n\nDeserialize a graph from a YAML file at path.\n\nArguments\n\npath: the path to the YAML file containing the graph information.\n\nExamples\n\njulia> g = deserialize(\"graph.yaml\")\n\n\n\n\n\n","category":"method"},{"location":"#PredNets.get_prediction-Union{Tuple{T}, Tuple{T, Int64}} where T<:Model","page":"Home","title":"PredNets.get_prediction","text":"get_prediction(model::Model, timestep::Int64)\n\nReturns the predicted value at the given timestep. \n\nIf the provided timestep is less than the degree of the model,  the function returns NaN.\n\n\n\n\n\n","category":"method"},{"location":"#PredNets.link_nodes!-Tuple{Node, Node}","page":"Home","title":"PredNets.link_nodes!","text":"link_nodes!(left::Node, right::Node)\n\nAdds a connection between two nodes.\n\nArguments:\n\nleft::Node: the first node\nright::Node: the second node\n\n\n\n\n\n","category":"method"},{"location":"#PredNets.mix!-Union{Tuple{M}, Tuple{M, Int64, Dict{Int64, Float64}}} where M<:Model","page":"Home","title":"PredNets.mix!","text":"mix!(model::M, timestep::Int64, _values::Dict{Int64,Float64};\n    mix_func::Function = x::Dict{Int64,Float64} -> mean(values(x)))\n\nComputes the prediction of the node and its 1-delta neighbors at the given timestep using the mixing function mix_func  and adds it to the mixed column of the df DataFrame. \n\nThe dictionary _values contains the values of all of the nodes at the given timestep. If any of these values is NaN, the mixed value should be NaN.\n\n\n\n\n\n","category":"method"},{"location":"#PredNets.observe!-Union{Tuple{T}, Tuple{Model, T}} where T<:Number","page":"Home","title":"PredNets.observe!","text":"observe!(model::Model, value::T)\n\nModifies the provided model object by observing the provided value and updating the models, as well as the mixed column of the df DataFrame.\n\n\n\n\n\n","category":"method"},{"location":"#PredNets.observe_and_predict!-Tuple{Node, Int64, Float64}","page":"Home","title":"PredNets.observe_and_predict!","text":"observe_and_predict!(node::Node, timestep::Int64, value::Float64)\n\nAdds a new value to a node's model and generates a new prediction for the given timestep\n\nArguments:\n\nnode::Node: the node to add the value to and generate a prediction for\ntimestep::Int64: the timestep to generate a prediction for\nvalue::Float64: the observed value to add to the model\n\n\n\n\n\n","category":"method"},{"location":"#PredNets.predict!-Union{Tuple{T}, Tuple{T, Int64}} where T<:Model","page":"Home","title":"PredNets.predict!","text":"predict!(model::Model, timestep::Int64)\n\nPredicts the value at the given timestep and adds the result to the predicted column of the df DataFrame. If the provided timestep is less than the degree of the model or greater than the number of observed data points, the prediction should be NaN.\n\n\n\n\n\n","category":"method"},{"location":"#PredNets.save_results-Tuple{Graph}","page":"Home","title":"PredNets.save_results","text":"save_results(graph::Graph; output_dir=\"path\")\n\nSaves the results of a graph simulation to a directory.\n\nArguments:\n\ngraph::Graph: The Graph object containing the simulation results to save.\noutput_dir::Union{Nothing, String}: The path to the directory where the simulation results will be saved, or nothing to use a temporary directory.\n\nReturns:\n\nnothing.\n\n\n\n\n\n","category":"method"},{"location":"#PredNets.save_results-Tuple{Node}","page":"Home","title":"PredNets.save_results","text":"Plots and saves the prediction results for a given node in a directory.\n\nArgs:\n\nnode: the Node whose prediction results should be plotted and saved.\noutput_dir: a string representing the directory where the results should be saved.\nkw: additional keyword arguments that are passed to the Plots.jl plotting function.\n\n\n\n\n\n","category":"method"},{"location":"#PredNets.select_model-Tuple{String}","page":"Home","title":"PredNets.select_model","text":"select_model(x::String)\n\nReturns a Model Type based on the input string.\n\n\n\n\n\n","category":"method"},{"location":"#PredNets.serialize-Tuple{Graph, String}","page":"Home","title":"PredNets.serialize","text":"serialize(graph::Graph, file::String)\n\nSerialize a graph to a YAML file at file.\n\nArguments\n\ngraph: the graph to serialize.\nfile: the file path to save the YAML file.\n\n\n\n\n\n","category":"method"},{"location":"#PredNets.serialize-Tuple{T} where T<:Model","page":"Home","title":"PredNets.serialize","text":"serialize(model::Model)\n\nSerializes the model object into a Dict{Symbol, Any}.\n\n\n\n\n\n","category":"method"},{"location":"#PredNets.simulate!-Tuple{Graph}","page":"Home","title":"PredNets.simulate!","text":"simulate!(graph::Graph; \nprocess::Union{Nothing, Vector{Float64}}=nothing, \noutput_dir::Union{String, Nothing}=nothing\n)\n\nSimulates the process of a graph using the given data, or the graph's own data if none is provided.\n\nArguments:\n\ngraph::Graph: The Graph object to simulate.\nprocess::Union{Nothing, Vector{Float64}}: The data to use for the simulation, or nothing to use the graph's own data. Defaults to nothing.\noutput_dir::Union{String, Nothing}: The path to the directory where the simulation results will be saved, or nothing to use a temporary directory. Defaults to nothing.\n\n\n\n\n\n","category":"method"}]
}
