using Pkg
Pkg.activate("../$(pwd())")

using Test
using Distributions

include("../src/models/ar.jl")

sampler = Normal(1, 5)

model = AR([1.1, 1.1])
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
@test model.weights == [1.1, 1.1]

@test model.df.observed == sampled_values

man_pred = hcat(model.df.observed[1:end-1], model.df.observed[2:end]) * model.weights
@test man_pred ≈ model.df.predicted[model.deg:end]

@test model.df.predicted[model.deg:end] ./2 ≈ model.df.mixed[model.deg:end]

println("test_ar.jl: tests passed")
nothing