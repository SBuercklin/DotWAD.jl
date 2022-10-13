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

io = open(WAD_DIR, "r")

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

###############
#=
    Graphics
=#
###############
gfx_names = ("WIOSTK\0\0", "STFST01\0", "WALL00_1", "MISGB0\0\0")
gfx_idxs = map(gname -> findfirst(l -> l.name == gname, ldir), gfx_names)

gfx_lumps = getindex.(Ref(ldir), gfx_idxs)

gfxs = map(gfx -> DotWAD.read_graphic(io, gfx.filepos, gfx.size), gfx_lumps)

f = visualize_graphic(gfxs[4], palette)