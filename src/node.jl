using Pkg
Pkg.activate(pwd())

using WebSockets
using Sockets
const LOCALIP = string(Sockets.getipaddr())

using ArgParse
using Distributions


include("AR.jl")

s = ArgParseSettings()
@add_arg_table s begin
    "--master_ip"
        help = "IP of master node"
    "--master_port", "-o"
        help = "PORT of master node"
        arg_type = Int
        default = 8080
    "--id"
        arg_type = Int
        help = "ID of a node"
    "--noise_mean", "-m"
        help = "expected noise of the receiver"
        arg_type = Float64
        default = 0.
    "--noise_var", "-v"
        help = "variance of noise of the receiver"
        arg_type = Float64
        default = 1.
    "weights"
        nargs = '*'      
        default = Any[]
        required = true
end

parsed_args = parse_args(ARGS, s)
@show parsed_args

noise_generator = Normal(parsed_args["noise_mean"], parsed_args["noise_var"])
weights = parse.(Float64, parsed_args["weights"])



nothing