using DataFrames

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
    model.df[!, "predicted"][timestep] = prediction
end
nothing

function serialize(model::AR)
    Dict{Symbol,Any}(
        :weights => reverse(model.weights)
    )
end