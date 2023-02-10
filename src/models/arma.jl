include("ar.jl")
include("ma.jl")


mutable struct ARMA <: Model
    ar::AR
    ma::MA
    deg::Int64
    n::Int64
    df::DataFrame

    function MA(ar_params::Dict{String,Any}, ma_params::Dict{String,Any}; μ::Float64=0.0, σ::Float64=1.0)
        ar = AR(; ar_params...)
        ma = MA(; ma_params, μ=μ, σ=σ)
        new(
            ar,
            ma,
            max(ar.deg, ma.deg),
            1,
            DataFrame(observed=[], predicted=[], mixed=[])
        )
    end
end

function observe!(model::ARMA, value::Float64)
    _observe!(model.ar, value)
    _observe!(model.ma, value)
    _observe!(model, value)
    nothing
end
observe!(model::ARMA, value::T) where {T<:Number} = observe!(model, convert(Float64, value))

function predict!(model::MA, timestep::Int64)
    model.n >= timestep - model.deg + 1 || return NaN
    model.df[!, "predicted"][timestep] = predict!(model.ar, timestep) + predict!(model.ma, timestep)
end
