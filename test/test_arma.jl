using Pkg
using LinearAlgebra
using PredNets
using Test
using Distributions


sampler = Normal(1, 5)

model = ARMA(Dict{Symbol, Any}(:weights=>[1., 1.]), 
            Dict(:weights=>[1., 1.], :c=>1)
            )
sampled_values = Vector{Float64}()
N = 50

for t in 1:N
    value = rand(sampler)
    push!(sampled_values, value)
    observe!(model, value)
    prediction = predict!(model, t)
    mix!(model, t, Dict{Int64, Float64}(0=>0, 1 =>prediction))
end

@test model.deg == 2
@test model.n == 50
@test model.ar.weights == [1., 1.]
@test model.ma.weights == [1., 1.]

@test model.df.observed == sampled_values

man_pred = model.ar.df.predicted + model.ma.df.predicted
@test man_pred[model.deg:end] ≈ model.df.predicted[model.deg:end]

@test model.df.predicted[model.deg:end] ./2 ≈ model.df.mixed[model.deg:end]

println("test_arma.jl: tests passed")
nothing