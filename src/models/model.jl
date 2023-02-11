using DataFrames
using Plots
using Statistics


abstract type Model end;

row_template = (observed=missing, predicted=missing, mixed=missing);

function _observe!(model::M, value::Float64) where M<:Model
    model.n = model.n + 1
    insert!(model.df, model.n, (row_template..., observed=value))
    nothing
end

observe!(model::Model, value::T) where {T<:Number} = _observe!(model, convert(Float64, value))

function mix!(model::M, timestep::Int64, _values::Dict{Int64, Float64}, mix_func::Function=x::Dict{Int64,Float64} -> mean(values(x))) where {M<:Model}
    model.df[!, "mixed"][timestep] = mix_func(_values)
end

function get_prediction(model::M, timestep::Int64) where {M<:Model}
    1 <= timestep - model.deg + 1 || return nothing
    model.df[!, "predicted"][timestep]
end
