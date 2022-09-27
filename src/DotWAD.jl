module DotWAD

using DoomBase
using StaticArrays

export parse_WAD

# Stages of parsing a WAD file
include("read.jl")

# Useful utilities for reading files
include("utils.jl")

# Abstractions for parsing
include("types.jl")

end # module DotWAD
