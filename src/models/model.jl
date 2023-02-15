using DataFrames
using Plots
using Statistics

const _row_template = (observed=NaN, predicted=NaN, mixed=NaN);

"""
Model is an abstract supertype for all models.
"""
abstract type Model end;

"""
    predict!(model::Model, timestep::Int64)

Predicts the value at the given timestep and adds the result to the predicted column of the df DataFrame.
If the provided timestep is less than the degree of the model or greater than the number of observed data points,
the prediction should be NaN.
"""
function predict!(model::T, timestep::Int64) where {T<:Model} 
    error("This function has to be implemented for $T.")
end

"""
    _observe!(model::M, value::Float64)

_observe! is a helper function that is not meant to be called by the user. It takes a Model struct and a Float64 
value. It increments the n attribute of the model, and inserts a row with the observed value in the observed 
column of the DataFrame.
"""
function _observe!(model::M, value::Float64) where {M<:Model}
    model.n = model.n + 1
    insert!(model.df, model.n, (_row_template..., observed=value))
    nothing
end

"""
    observe!(model::Model, value::T)

Modifies the provided model object by observing the provided value and updating the models,
as well as the mixed column of the df DataFrame.
"""
observe!(model::Model, value::T) where {T<:Number} = _observe!(model, convert(Float64, value))

"""
    mix!(model::M, timestep::Int64, _values::Dict{Int64,Float64};
        mix_func::Function = x::Dict{Int64,Float64} -> mean(values(x)))

Computes the prediction of the node and its 1-delta neighbors at the given timestep using the mixing function mix_func 
and adds it to the mixed column of the df DataFrame. 

The dictionary _values contains the values of all of the nodes at the given timestep.
If any of these values is NaN, the mixed value should be NaN.
"""
function mix!(model::M, timestep::Int64, _values::Dict{Int64,Float64};
    mix_func::Function=x::Dict{Int64,Float64} -> mean(values(x))) where {M<:Model}
    value = any(isnan.(values(_values))) ? NaN : mix_func(_values)
    model.df[!, "mixed"][timestep] = value
end

"""
    get_prediction(model::Model, timestep::Int64)

Returns the predicted value at the given timestep. 

If the provided timestep is less than the degree of the model, 
the function returns NaN.
"""
function get_prediction(model::T, timestep::Int64) where {T<:Model}
    1 <= timestep - model.deg + 1 || NaN
    model.df[!, "predicted"][timestep]
end

"""
    serialize(model::Model)

Serializes the model object into a `Dict{Symbol, Any}`.
"""
function serialize(model::T) where {T<:Model}
    error("This function has to be implemented for $T.")
end