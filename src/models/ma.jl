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
        @show deg, typeof(deg)
        new(deg,
            weights,
            convert(Float64, c),
            Normal(μ, σ),
            Vector{Float64}(),
            1,
            DataFrame(observed=[],predicted=[],mixed=[]))
    end
    MA(;weights::Vector{Float64}, c::Float64, kw...) = MA(weights, c; kw...)
end

MA(weights::Vector{Float64}, c::T; kw...) where T<:Number = MA(weights, convert(Float64, c); kw...) 

function observe!(model::MA, value::Float64)
    push!(model.noises, rand(model.noise_gen))
    _observe!(model, value)
    nothing
end
observe!(model::MA, value::T) where {T<:Number} = observe!(model, convert(Float64, value))

function predict!(model::MA, timestep::Int64)
    model.n >= timestep - model.deg + 1 || return NaN
    @debug model.df.observed[timestep-model.deg+1:timestep]'
    model.df[!, "predicted"][timestep] =  model.noises[timestep-model.deg+1:timestep]' * model.weights + model.noises[timestep]
end


model = MA([1.1, -0.9, 0.2], 0.1)

nothing