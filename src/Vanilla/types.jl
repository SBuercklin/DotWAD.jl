"""
    LumpDirEntry

Abstraction for an entry in the directory of lumps.

# Fields
- `filepos::Int32`: Pointer to the start of the lump data
- `size::Int32`: Number of bytes comprising the lump
- `name::SVector{8, UInt8}`: The name of the lump as a series of 8 ASCII bytes
"""
struct LumpDirEntry
    filepos::Int32
    size::Int32
    name::SVector{8, UInt8} 
end

function Base.show(io::IO, lde::LumpDirEntry)
    if get(io, :compact, false)
        print(io, "Lump $(lde.name)")
    else
        print(io, "Lump NAME: $(lde.name)\n")
        print(io, "     SIZE: $(lde.size)\n")
        print(io, "     POSITION: $(lde.filepos)")
    end
end

function LumpDirEntry(v::AbstractVector{UInt8})
    filepos = only(reinterpret(Int32, @view v[1:4]))
    sze = only(reinterpret(Int32, @view v[5:8]))
    name = @view v[9:end]
    return LumpDirEntry(filepos, sze, SVector{8}(name))
end

function Base.getproperty(lde::LumpDirEntry, s::Symbol)
    return s === :name ? rstrip(String(getfield(lde, :name)), '\0') : getfield(lde, s)
end

#=
    Raw Color Palettes
=#

# These map onto RGB{N0f8} from ColorTypes.jl, but we just want raw data here
struct Palette{TV}
    colors::SizedVector{256, DOOMCOLOR, TV}
end
function Palette(colors::AbstractVector, ncolors)
    color_vec = reinterpret(DOOMCOLOR, colors)

    return Palette(SizedVector{ncolors}(color_vec))
end
Base.getindex(p::Palette, idx) = getindex(p.colors, idx)

struct PLAYPAL
    palettes::NTuple{14, Palette}
end

struct COLORMAP{TV <: SizedVector}
    colormaps::TV
end

struct PNAMES
    N::UInt32
    pnames::Vector{SVector{8,UInt8}}
end

#=
    Level Geometry
=#

struct Vertex
    x::Int16
    y::Int16
end

struct LineDef
    start::Int16        # Refers to the index of the vertex in that map's vertexes lump
    terminate::Int16
    flags::Int16
    type::Int16
    tag::Int16
    front_side::Int16   # Refers to index of the sidedef in that map's sidedef lump
    back_side::Int16
end

struct Seg
    start::Int16
    terminate::Int16
    angle::Int16
    linedef::Int16
    direction::Int16
    offset::Int16
end

struct Subsector
    seg_count::Int16
    first_seg::Int16
end

struct Node
    x_start::Int16
    y_start::Int16
    dx::Int16
    dy::Int16
    r_bbox::NTuple{4, Int16}
    l_bbox::NTuple{4, Int16}
    r_child::Int16
    l_child::Int16
end

#=
    More Graphics Stuff
=#

struct Post
    topdelta::UInt8
    length::UInt8
    data::Vector{UInt8}
end

function Post(v::AbstractVector{UInt8})
    td = v[1]
    l = v[2]
    # un1 = v[3]
    data = v[4:end-1]
    # un2 = v[end]

    return Post(td, l, data)
end

"""
    struct Column

A `Column` is a collection of `Post`s describing a vertical slice of a Doom Graphic. Any
    pixel not included in a `Post` is transparent.
"""
struct Column
    posts::Vector{Post}
    height::UInt16
    function Column(posts::AbstractVector{Post}, height)
        sposts = sort(posts; by = p -> p.topdelta)

        return new(sposts, height)
    end
end

function Column(data::AbstractVector{UInt8}, offset, height)
    posts = col_data_to_posts(data, offset)

    return Column(posts, height)
end

function col_data_to_posts(data::AbstractVector{UInt8}, offset)
    rel_data = @view data[(1+offset):end]

    posts = Post[]

    # Each post is terminated by 0xFF
    while first(rel_data) != 0xFF
        # Figure out the length of the color pointers
        #   and there are 4 extra bytes per post
        post_data_length = rel_data[2]
        post_length = 4 + post_data_length

        push!(posts, Post(rel_data[1:post_length]))

        rel_data = @view rel_data[(post_length + 1):end]
    end

    return posts
end

"""
    struct DoomGraphic

A `DoomGraphic` represents a fundamental graphic determined by its size, offset, and 
    the data `Column`s comprising the graphic. We store the `Column`s explicitly because
    the `Column`s may contain transparencies. 

A `DoomGraphic` can be a `PATCH`, `SPRITE`, or ???
"""
struct DoomGraphic
    width::UInt16
    height::UInt16
    leftoffset::Int16
    topoffset::Int16
    cols::Vector{Column}
end

struct TexturePatch
    xoff::UInt16
    yoff::UInt16
    patch_idx::UInt16
    stepdir::UInt16 # unused
    colormap::UInt16 # unused
end

struct TextureData
    name::SVector{8, UInt8}
    width::UInt16
    height::UInt16
    num_patches::UInt16
    patches::Vector{TexturePatch}
end

struct Textures
    N::UInt32
    N_textures::Vector{UInt32}
    texture_data::Vector{TextureData}
end
