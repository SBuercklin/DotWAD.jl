module Vanilla

using StaticArrays

struct VanillaParser end

const DOOMCOLOR = NTuple{3, UInt8}

include("types.jl")

include("parsing.jl")

include("VanillaWAD.jl")

export parse_WAD

end