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
            0,
            DataFrame(observed=[],predicted=[],mixed=[]))
    end

end

AR(weights::Vector{T}) where T<:Number = AR(convert.(Float64, weights))

function AR(;weights::Vector{Any})
    typeof(weights[1]) <: Number && error("Weights values must be subtype of Number.")
    AR(weights)
end

# AR(weights::Vector{N}) where {T<:Number, N<:Number} = MA(convert.(Float64, weights), convert(Float64, c); kw...) 
AR(;weights) = AR(convert.(Float64, weights))

function predict!(model::AR, timestep::Int64)
    prediction = NaN
    if model.deg <= timestep <= model.n
        prediction = model.df.observed[timestep-model.deg+1:timestep]' * model.weights
    end
    model.df[!, "predicted"][timestep] = prediction
end
nothing