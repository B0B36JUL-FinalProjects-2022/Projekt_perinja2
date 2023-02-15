"""
Autoregressive moving average (`ARMA`) model struct.

# Fields
- `ar`: AR struct representing the autoregressive part of the model
- `ma`: MA struct representing the moving average part of the model
- `deg`: integer value representing the degree of the model
- `n`: integer value representing the number of data points used in the model
- `df`: DataFrame with columns:
    - `observed`: vector of Float64 representing the observed values
    - `predicted`: vector of Float64 representing the predicted values
    - `mixed`: vector of Float64 representing the mixed values
"""
mutable struct ARMA <: Model

    ar::AR
    ma::MA
    deg::Int64
    n::Int64
    df::DataFrame

    """
    Constructs a new `ARMA` model object with the provided AR and MA parameters, and optional mean and standard deviation.
    The `ar_params` and `ma_params` dictionaries are used to create new `AR` and `MA` objects respectively.
    The degree of the `ARMA` model is set to the maximum degree between the `AR` and `MA` objects.
    The `df` property is initialized as an empty DataFrame with columns for `observed`, `predicted`, and `mixed` values.
    """
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

function ARMA(; ar_params::Dict{Symbol,Any}, ma_params::Dict{Symbol,Any}, kw...)
    ARMA(ar_params, ma_params; kw...)
end

function observe!(model::ARMA, value::Float64)
    observe!(model.ar, value)
    observe!(model.ma, value)
    _observe!(model, value)
    nothing
end

observe!(model::ARMA, value::T) where {T<:Number} = observe!(model, convert(Float64, value))

function predict!(model::ARMA, timestep::Int64)
    predictions = predict!(model.ar, timestep), predict!(model.ma, timestep)
    prediction = any(isnothing.(predictions)) ? NaN : sum(predictions)
    model.df.predicted[timestep] = prediction
end

function serialize(model::ARMA)
    Dict{Symbol,Any}(
        :ar_params => serialize(model.ar),
        :ma_params => serialize(model.ma),
        :μ => model.ma.μ,
        :σ => model.ma.σ
        )
end