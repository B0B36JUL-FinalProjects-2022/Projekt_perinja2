
mutable struct ARMA <: Model
    ar::AR
    ma::MA
    deg::Int64
    n::Int64
    df::DataFrame
    function ARMA(ar_params::Dict{Symbol,Any}, ma_params::Dict{Symbol,Any}; μ::Float64=0.0, σ::Float64=1.0)
        ar = AR(; ar_params...)
        ma = MA(; ma_params..., μ=μ, σ=σ)
        new(
            ar,
            ma,
            max(ar.deg, ma.deg),
            0,
            DataFrame(observed=[], predicted=[], mixed=[])
        )
    end
end

function ARMA(; ar_params::Dict{Symbol, Any}, ma_params::Dict{Symbol, Any}, kw...)
    ARMA(ar_params,ma_params; kw... )
end

function observe!(model::ARMA, value::Float64)
    observe!(model.ar, value)
    observe!(model.ma, value)
    _observe!(model, value)
    nothing
end
observe!(model::ARMA, value::T) where {T<:Number} = observe!(model, convert(Float64, value))

function predict!(model::ARMA, timestep::Int64)
    model.df[!, "predicted"][timestep] = predict!(model.ar, timestep) + predict!(model.ma, timestep)
end
