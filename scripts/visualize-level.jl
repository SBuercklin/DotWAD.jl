# TODO: Replace this with Pluto notebooks

using DoomBase
using DotWAD

using GeometryBasics
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

level_idx = findfirst(l -> l.name == "E1M1\0\0\0\0", ldir)
lumps = ldir[level_idx:(level_idx + 10)]

###############
#=
    Get line, vertex, seg, subsector data
=#
###############
vpos = lumps[5].filepos
vsize = lumps[5].size
verts = DotWAD.read_vertexes(io, vpos, vsize)

# Read linedefs
lpos = lumps[3].filepos
lsize = lumps[3].size
dlines = DotWAD.read_linedefs(io, lpos, lsize)

# Read Segs
spos = lumps[6].filepos
ssize = lumps[6].size
segs = DotWAD.read_segs(io, spos, ssize)

# Read Subsectors
subpos = lumps[7].filepos
subsize = lumps[7].size
subs = DotWAD.read_subsectors(io, subpos, subsize)

###############
#=
    Visualize level as linedefs
=#
###############
f = visualize_map(dlines, verts)

###############
#=
    Visualize level as linedefs with SSectors segs overlaid
=#
###############
f = visualize_map_subsegs(subs, segs, dlines, verts)