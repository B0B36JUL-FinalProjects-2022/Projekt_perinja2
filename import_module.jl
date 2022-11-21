using Pkg

Pkg.activate(pwd())
Pkg.add("InteractiveUtils")
push!(LOAD_PATH, "$(pwd())/src")

using MyModule

x = MyModule.serialize(MyModule.SetNoise())

out = MyModule.parse_message(x)

@assert out === MyModule.SetNoise()

channel = Channel{String}(10)
push!(channel, MyModule.Ok(1))