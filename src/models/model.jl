using DataFrames
using Plots
using Statistics


abstract type Model end;

row_template = (observed=missing, predicted=missing, mixed=missing);

function _observe!(model::M, value::Float64) where M<:Model
    insert!(model.df, model.n, (row_template..., observed=value))
    model.n = model.n + 1
    nothing
end

observe!(model::Model, value::T) where {T<:Number} = _observe!(model, convert(Float64, value))

function plt(df::DataFrame; kw...)
    x = 1:nrow(df)
    plot(x, df[!, "observed"], label="observed", kw...)
    plot!(x, df[!, "predicted"], label="predicted", kw...)
    plot!(x, df[!, "mixed"], label="mixed", kw...)

end

function mix!(model::M, timestep::Int64, values::Dict{Int64, Any}, mix_func::Function=x::Dict{Int64,Float64} -> mean(values(x))) where {M<:Model}
    model.df[!, "mixed"][timestep] = mix_func(values)
end

function get_prediction(model::M, timestep::Int64) where {M<:Model}
    1 <= timestep - model.deg + 1 || return nothing
    model.df[!, "predicted"][timestep]
end
