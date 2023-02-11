using DataFrames
using Distributions

include("model.jl")

mutable struct MA <: Model
    deg::Int64
    weights::Vector{Float64}
    c::Float64
    noise_gen::Normal
    noises::Vector{Float64}
    n::Int64
    df::DataFrame

    function MA(weights::Vector{Float64}, c::Float64; μ::Float64=0., σ::Float64=1.)
        deg = length(weights)
        new(deg,
            weights,
            convert(Float64, c),
            Normal(μ, σ),
            Vector{Float64}(),
            0,
            DataFrame(observed=[],predicted=[],mixed=[]))
    end
    MA(weights::Vector{N}, c::T; kw...) where {T<:Number, N<:Number} = MA(convert.(Float64, weights), convert(Float64, c); kw...) 
    MA(;weights::Vector{M}, c::T, kw...) where {T <: Number, M<:Number}= MA(weights, c; kw...)

end


function observe!(model::MA, value::Float64)
    push!(model.noises, rand(model.noise_gen))
    _observe!(model, value)
    nothing
end
observe!(model::MA, value::T) where {T<:Number} = observe!(model, convert(Float64, value))

function predict!(model::MA, timestep::Int64)
    prediction = NaN
    if model.deg <= timestep <= model.n
        prediction = model.noises[timestep-model.deg+1:timestep]' * model.weights + model.noises[timestep]
    end
    model.df[!, "predicted"][timestep] = prediction
end
nothing