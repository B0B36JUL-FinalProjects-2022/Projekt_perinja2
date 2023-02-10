using DataFrames

include("model.jl")

mutable struct AR <: Model
    deg::Int64
    weights::Vector{Float64}
    n::Int64
    df::DataFrame

    function AR(weights::Vector{Float64})
        deg = length(weights)
        new(deg,
            reverse(weights),
            1,
            DataFrame(observed=[],predicted=[],mixed=[]))
    end

    AR(;weights::Vector{Float64}) = AR(weights)
end

function predict!(model::AR, timestep::Int64)
    model.n >= timestep - model.deg + 1  || return NaN
    @debug model.df.observed[timestep-model.deg+1:timestep]'
    model.df[!, "predicted"][timestep] = model.df.observed[timestep-model.deg+1:timestep]' * model.weights
end

nothing