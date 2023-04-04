# TODO: Replace this with Pluto notebooks
using DotWAD
using DotWAD.Vanilla: Column, DoomGraphic, Post, Palette

using ColorTypes: RGB, N0f8

using GLMakie
try
    using Makie
    Makie.inline!(true)
catch e
    nothing
end

###############
#=
    Setup
=#
###############
include(pkgdir(DotWAD, "scripts", "visualization-utils.jl"))

WAD_DIR = pkgdir(DotWAD,"scripts", "DOOM1.WAD")

wad = parse_WAD(WAD_DIR)

###############
#=
    Get lump directory
=#
###############
lumps = wad.lumps

###############
#=
    Palettes
=#
###############
playpal = wad.PLAYPAL

palette = playpal.palettes[1]

f = visualize_palette(palette)

###############
#=
    Graphics
=#
###############
# Visualizes a single patch
gfxs = map(gfx -> DotWAD.read_graphic(io, gfx.filepos, gfx.size), gfx_lumps)

f = visualize_graphic(gfxs[122], palette)