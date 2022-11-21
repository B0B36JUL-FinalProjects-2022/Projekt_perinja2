export SetNoise, Link, Measurement, Kill, Ok, Error, Message
export  serialize, parse_message, string_to_struct, convert

import Base: convert

using JSON3
using InteractiveUtils

get_current_ip() = string(Sockets.getipaddr())

abstract type Message end

struct SetNoise <: Message
    μ::Real
    σ::Real
end

function  SetNoise(;μ = 0, σ = 1)
    σ < 0 && DomainError("σ with negative value provided")
    return SetNoise(μ, σ)
end

struct Link <: Message    
    destination_ip::String
    destination_port::Int
    destination_id::Int
end

function  Link(; destination_ip::String, destination_port::Int, destination_id::Int)
    return Link(destination_ip, destination_port, destination_id)
end

struct Measurement <: Message
    time::Int
    value::Real
end
function Measurement(;time::Real, value::Real)
    return Measurement(time, value)
end 

struct Kill <: Message
    save_results::Bool
end
function Kill(;save_results::Bool=True)
    Kill(save_results)
end 

struct Ok <: Message 
    ID::Int
end
function Ok(; ID::Int)
    return Ok(ID)
end

struct Error <: Message 
    ID::Int
end
function Error(; ID::Int)
    return Error(ID)
end

string_to_struct() = Dict(string(x)=>x for x in InteractiveUtils.subtypes(Message))
parse_message(::Type{T}, msg::JSON3.Object) where T <: Message = T(;msg...)

function parse_message(msg::String)
    
    parsed_msg = JSON3.read(msg)
    T = string_to_struct()[parsed_msg.cmd]
    V = parsed_msg.value

    parse_message(T, V)
end

serialize(Message::T) where T <: Message = """{"cmd":"$(string(T))","value":$(JSON3.write(Message))}"""


# Base.push!(A::Channel{AbstractString}, b::Message) = push!(A, MyModule.serialize(b))
convert(::Type{String}, m::T) where T<:Message = serialize(m)
# push!(C::Type{Channel{String}}, m::T) where T<: Message = push!(C, serialize(m))
# @assert SetNoise() === parse_message(serialize(SetNoise()))
# @assert Link("src", 1, 1) === parse_message(serialize(Link("src", 1, 1)))
# @assert Measurement(1,1) === parse_message(serialize(Measurement(1,1)))
# @assert Kill() === parse_message(serialize(Kill()))