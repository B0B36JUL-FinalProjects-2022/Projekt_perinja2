using DataFrames
"""
Autoregressive (`AR`) model struct.

# Fields
- `deg`: integer value representing the degree of the model
- `weights`: vector of Float64 representing the model weights
- `n`: integer value representing the number of data points used in the model
- `df`: DataFrame with columns:
    - observed: vector of Float64 representing the observed values
    - predicted: vector of Float64 representing the predicted values
    - mixed: vector of Float64 representing the mixed values
"""
mutable struct AR <: Model
    
    deg::Int64
    weights::Vector{Float64}
    n::Int64
    df::DataFrame

    """
    Constructs a new AR model object with the provided weights.
    The degree of the model is set to the length of the weights.
    The `df` property is initialized as an empty DataFrame with columns for 
    `observed`, `predicted`, and `mixed` values.
    """
    function AR(weights::Vector{Float64})
        deg = length(weights)
        new(deg,
            reverse(weights),
            0,
            DataFrame(observed=Vector{Float64}(),
                predicted=Vector{Float64}(),
                mixed=Vector{Float64}()
            )
        )
    end
end

AR(weights::Vector{T}) where {T<:Number} = AR(convert.(Float64, weights))

AR(; weights) = AR(convert.(Float64, weights))


function predict!(model::AR, timestep::Int64)
    prediction = NaN
    if model.deg <= timestep <= model.n
        prediction = model.df.observed[timestep-model.deg+1:timestep]' * model.weights
    end
    model.df.predicted[timestep] = prediction
end

function serialize(model::AR)
    Dict{Symbol,Any}(
        :weights => reverse(model.weights)
    )
end

nothing