push!(LOAD_PATH, "$(pwd())/src")

using MyModule

x = MyModule.serialize(MyModule.SetNoise())

out = MyModule.parse_message(x)

@assert out === MyModule.SetNoise()
pwd()