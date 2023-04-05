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
gfxs = wad.PATCHES

f = visualize_graphic(gfxs[1], palette)

t = wad.TEXTURE1.texture_data[1]
t.num_patches
String(t.name)
t.patches

f1 = visualize_graphic(gfxs[t.patches[1].patch_idx + 1], palette)
f2 = visualize_graphic(gfxs[t.patches[2].patch_idx + 1], palette)
f3 = visualize_graphic(gfxs[t.patches[3].patch_idx + 1], palette)
f4 = visualize_graphic(gfxs[t.patches[4].patch_idx + 1], palette)
f5 = visualize_graphic(gfxs[t.patches[5].patch_idx + 1], palette)