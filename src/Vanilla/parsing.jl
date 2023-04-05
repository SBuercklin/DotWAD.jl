function parse_WAD(f)
    return open(_parse_WAD, f, "r")
end

function _parse_WAD(io)
    wadtype, nlumps, dir_offset = read_header(io)
    lump_dir = read_directory(io, nlumps, dir_offset)
    which_game = determine_doom_version(getproperty.(lump_dir, :name))

    playpal = read_PLAYPAL(io, lump_dir)
    colormap = read_COLORMAP(io, lump_dir)

    pnames = read_PNAMES(io, lump_dir)
    patches = read_patches(io, lump_dir)

    texture1 = read_textures(io, lump_dir, "TEXTURE1")
    texture2 = read_textures(io, lump_dir, "TEXTURE2")

    return VanillaWAD(which_game, wadtype, lump_dir, playpal, colormap, patches, texture1, texture2)
end

# Assumes the IOStream points to the start of the .WAD file/header
function read_header(io::IOStream)
    header = read(io, 12)
    header_ints = reinterpret(Int32, @view header[5:12])
 
    wadtype = Symbol(String(@view header[1:4]))
    nlumps = first(header_ints)
    lump_ptr = last(header_ints)

    return wadtype, nlumps, lump_ptr
end

# Reads the lump directory
function read_directory(io::IOStream, nlumps, dir_offset)
    seek(io, dir_offset)

    Δ = sizeof(LumpDirEntry)

    # Read the lumpdirectory all at once
    lumpdir_data = read(io, nlumps * Δ)

    lumpdir = [LumpDirEntry(lumpdir_data[(1:16) .+ (i-1) * Δ]) for i in 1:nlumps]

    return lumpdir
end

# Determine the doom version by looking for the level names
function determine_doom_version(lumpnames)
    doom1 = r"(E[1-4]M[1-9])"
    doom2 = r"MAP((0[1-9])|([1-2][0-9])|3[0-2])"

    isd1 = length(filter(m -> !isnothing(m), match.(doom1, lumpnames))) > 0
    isd2 = length(filter(m -> !isnothing(m), match.(doom2, lumpnames))) > 0

    if isd1
        return :DOOM1
    elseif isd2
        return :DOOM2
    else
        return :UNKNOWN
    end
end

# Read the PLAYPAL lump, get the full set of palettes
function read_PLAYPAL(io::IOStream, offset; npals=14, ncolors = 256)
    seek(io, offset)
    color_data = read(io, npals * ncolors * 3)

    partitioned_colors = Iterators.partition(color_data, ncolors * 3)
    palettes = Tuple(Palette(part, ncolors) for part in partitioned_colors)

    playpal = PLAYPAL(palettes)
    return playpal
end

function read_PLAYPAL(io::IOStream, lumpdirs::AbstractVector{LumpDirEntry})
    lump = find_lump(lumpdirs, "PLAYPAL")

    # e.g. if it's a PWAD we need not have a custom palette
    isnothing(lump) && return nothing

    offset = lump.filepos
    
    return read_PLAYPAL(io, offset)
end

function read_COLORMAP(io::IOStream, offset; nmaps = 34)
    seek(io, offset)
    cmap_data = read(io, nmaps * 256)

    partitioned_maps = Iterators.partition(cmap_data, 256)
    maps = collect(partitioned_maps)

    return COLORMAP(SizedVector{nmaps}(maps))

end

function read_COLORMAP(io::IOStream, lumpdirs::AbstractVector{LumpDirEntry})
    lump = find_lump(lumpdirs, "COLORMAP")

    isnothing(lump) && return nothing

    offset = lump.filepos

    return read_COLORMAP(io, offset)
end

function read_PNAMES(io::IOStream, lumpdirs)
    lump = find_lump(lumpdirs, "PNAMES")

    isnothing(lump) && return nothing

    offset = lump.filepos
    lumpsize = lump.size

    seek(io, offset)
    pname_data = read(io, lumpsize)

    N = only(reinterpret(UInt32, @view pname_data[1:4]))
    pnames = reinterpret(SVector{8, UInt8}, @view pname_data[5:end])

    return PNAMES(N, pnames)
end

# Right now we assume you have both P_START and P_END, though this is not necessarily
#   required by Doom
function read_patches(io::IOStream, lumpdirs)
    start_idx = find_lump_idx(lumpdirs, "P_START")
    end_idx = find_lump_idx(lumpdirs, "P_END")

    (isnothing(start_idx) || isnothing(end_idx)) && return nothing

    # Sort the patch lumps so they're in sequential order, filter out the marker lumps
    patch_lumps = lumpdirs[start_idx + 1:end_idx - 1]
    filter!(!iszero ∘ Base.Fix2(getproperty, :size), patch_lumps)
    sort!(patch_lumps; by = Base.Fix2(getproperty, :filepos))

    # TODO: turn this into a dict where we look up the patch by name
    return _read_patches_from_lumps(io, patch_lumps)
end

# Assume that the patch lumps are sorted by starting location
function _read_patches_from_lumps(io, patch_lumps)
    data_intervals = get_data_intervals_from_lumps(patch_lumps)

    # Read all the patch data into memory to reduce reads
    _patch_data = mapreduce(vcat, data_intervals) do i
        Δ = last(i) - first(i)
        seek(io, first(i))
        return read(io, Δ)
    end
    patch_data = @view _patch_data[:] # Do this so patch data is type stable

    patches = map(patch_lumps) do p
        p_size = p.size

        curr_patch_data = @view patch_data[1:p_size] # Split the current patch off
        patch_data = @view patch_data[(p_size+1):end] # Remainder of the patch data

        return read_graphic(curr_patch_data)
    end

    return patches
end

function read_graphic(graphic_data)
    width, height = reinterpret(UInt16, @view graphic_data[1:4])
    leftoff, topoff = reinterpret(Int16, @view graphic_data[5:8])

    offsets = reinterpret(UInt32, @view graphic_data[(9:(4*width + 8))]) 

    cols = Column.(Ref(graphic_data), offsets, height)

    return DoomGraphic(width, height, leftoff, topoff, cols)
end

# name is either TEXTURE1 or TEXTURE2
function read_textures(io, patch_lumps, name)
    patch_lump = find_lump(patch_lumps, name)

    isnothing(patch_lump) && return nothing

    texture_lump_data = read_lump(io, patch_lump)

    N = only(reinterpret(UInt32, texture_lump_data[1:4]))
    texture_offs = reinterpret(UInt32, texture_lump_data[5:(4*(N+1))])

    textures = map(texture_offs) do off
        relevant_data = @view texture_lump_data[(off + 1):end]
        name = SVector{8}(relevant_data[1:8])
        width, height = reinterpret(UInt16, relevant_data[13:16])
        num_patches = only(reinterpret(UInt16, relevant_data[21:22]))

        patches = collect(reinterpret(TexturePatch, relevant_data[23:(num_patches * 10 + 22)]))

        return TextureData(name, width, height, num_patches, patches)
    end

    return Textures(N, texture_offs, textures)
end

function read_linedefs(io::IOStream, offset, dsize)
    seek(io, offset)

    _linedata = read(io, dsize)
    linedata = reinterpret(NTuple{7, Int16}, _linedata)
    lines = map(l -> LineDef(l...), linedata)

    return lines
end

function read_vertexes(io::IOStream, offset, dsize)
    seek(io, offset)
    _vertdata = read(io, dsize)
    vertdata = reinterpret(NTuple{2, Int16}, _vertdata)
    verts = map(v -> Vertex(v...), vertdata)

    return verts
end

function read_segs(io::IOStream, offset, ssize)
    seek(io, offset)
    _segdata = read(io, ssize)
    segdata = reinterpret(NTuple{6,  Int16}, _segdata)
    segs = map(s -> Seg(s...), segdata)

    return segs
end

function read_subsectors(io::IOStream, offset, ssize)
    seek(io, offset)
    _subdata = read(io, ssize)
    subdata = reinterpret(NTuple{2, Int16}, _subdata)
    subsectors = map(s -> Subsector(s...), subdata)

    return subsectors

end
