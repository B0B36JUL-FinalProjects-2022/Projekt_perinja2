using Pkg
Pkg.activate(pwd())

using DataFrames
using Plots


mutable struct AR
    deg::Int64
    weights::Vector{Float64}
    n:: Int64
    df:: DataFrame

    function AR(deg::Int64, weights::Vector{Float64})
        deg == length(weights) || error("AR model of degree {}")
        new(deg, 
            reverse(weights), 
            1,  
            DataFrame(
                observed=Float64[], 
                predicted=Float64[], 
                mixed=Float64[])
        )
    end
    

end


model = AR(2, [1.1, -0.3])

row_template = (observed=NaN, predicted=NaN, mixed=NaN)

function observe!(model::AR, value::Float64)
    curr_row = (row_template..., observed=value)
    insert!(model.df, model.n, curr_row)
    model.n = model.n + 1
    nothing
end 
observe!(model::AR, value::T) where T<:Number = observe!(model, convert(Float64, value))

# observe!(model, 1.1)
# observe!(model, 1.2)
# observe!(model, 1.3)

function predict!(model::AR, timestep::Int64)
    1 <= timestep-model.deg+1 || return nothing
    @show model.df.observed[timestep-model.deg+1:timestep]'
    model.df[!, "predicted"][timestep] =  model.df.observed[timestep-model.deg+1:timestep]' * model.weights
    model.df[!, "predicted"][timestep] 
end
predict!(model::AR, value::T) where T<:Number = predict!(model, convert(Float64, value))

function plt(df::DataFrame; kw...)
    x = 1:nrow(df)
    plot(x, df[!, "observed"], label="observed", kw...)
    plot!(x, df[!, "predicted"], label="predicted", kw...)
    plot!(x, df[!, "mixed"], label="mixed", kw...)

end

for i in 1:15
    observe!(model, i)
    @show predict!(model, i)
end

plt(model.df)