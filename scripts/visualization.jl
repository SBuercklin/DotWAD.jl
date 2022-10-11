# TODO: Replace this with Pluto notebooks

using DoomBase
using DotWAD

using GLMakie

###############
#=
    Setup
=#
###############
include("./scripts/visualization-utils.jl")

WAD_DIR = "./scripts/DOOM1.WAD"

###############
#=
    Get lump directory
=#
###############
# Load the lump directory
ldir = parse_WAD(WAD_DIR)

###############
#=
    Palettes
=#
###############
playpal_lump = ldir[findfirst(l -> l.name == "PLAYPAL\0", ldir)]
playpal = open(WAD_DIR, "r") do f
    return DotWAD.read_PLAYPAL(f, playpal_lump.filepos)    
end

palette = playpal.palettes[1]

f = visualize_palette(palette)
