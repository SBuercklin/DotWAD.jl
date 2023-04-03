module Vanilla

using StaticArrays
using Intervals

struct VanillaParser end

const DOOMCOLOR = NTuple{3, UInt8}

include("types.jl")

include("parsing.jl")

include("VanillaWAD.jl")

include("utils.jl")

export parse_WAD

end