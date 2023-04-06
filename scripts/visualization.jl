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

# Textures
patch_map = DotWAD.Vanilla.idx_to_patch(wad)

(max_patches, t_idx) = findmax(wad.TEXTURE1.texture_data) do t
    return t.num_patches
end

t = wad.TEXTURE1.texture_data[t_idx]

visualize_texture_to_gif(t, patch_map, palette; filename = "MAX_PATCHES.gif")
