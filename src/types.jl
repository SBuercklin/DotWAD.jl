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
    println(io, "Lump NAME: $(lde.name)")
    println(io, "Lump SIZE: $(lde.size)")
    println(io, "Lump POSITION: $(lde.filepos)")
end

function LumpDirEntry(v::AbstractVector{UInt8})
    filepos = only(reinterpret(Int32, @view v[1:4]))
    sze = only(reinterpret(Int32, @view v[5:8]))
    name = @view v[9:end]
    return LumpDirEntry(filepos, sze, SVector{8}(name))
end

function Base.getproperty(lde::LumpDirEntry, s::Symbol)
    return s === :name ? String(getfield(lde, :name)) : getfield(lde, s)
end

struct Post
    topdelta::UInt8
    length::UInt8
    data::Vector{UInt8}
    unused::NTuple{2, UInt8}
end

function Post(v::AbstractVector{UInt8})
    td = v[1]
    l = v[2]
    un1 = v[3]
    data = v[4:end-1]
    un2 = v[end]

    return Post(td, l, data, (un1, un2))
end

struct Column
    data::Vector{UInt8}
end

function Column(posts::AbstractVector{Post})
    sort!(posts; by = p -> p.topdelta)

    data = Vector{UInt8}()
    for p in posts
        append!(data, p.data)
    end

    return Column(data)
end

function Column(data::AbstractVector{UInt8}, offset)
    posts = col_data_to_posts(data, offset)

    return Column(posts)
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