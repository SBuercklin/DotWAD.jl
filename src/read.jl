function parse_WAD(f)
    return open(f, "r") do io
        wadtype, nlumps, dir_offset = read_header(io)
        lump_dir = read_directory(io, nlumps, dir_offset)

        return lump_dir
    end
end

# Assumes the IOStream points to the start of the .WAD file/header
function read_header(io::IOStream)
    header = read(io, 12)
    header_ints = reinterpret(Int32, @view header[5:12])
    
    wadtype = String(@view header[1:4])
    nlumps = first(header_ints)
    lump_ptr = last(header_ints)

    return wadtype, nlumps, lump_ptr
end

function read_directory(io::IOStream, nlumps, dir_offset)
    seek(io, dir_offset)

    Δ = sizeof(LumpDirEntry)

    # Read the lumpdirectory all at once
    lumpdir_data = read(io, nlumps * Δ)

    lumpdir = [LumpDirEntry(lumpdir_data[(1:16) .+ (i-1) * Δ]) for i in 1:nlumps]

    return lumpdir
end

function determine_doom_version(lumpnames)
    doom1 = r"(E[1-4]M[1-9])"
    doom2 = r"MAP((0[1-9])|([1-2][0-9])|3[0-2])"

    isd1 = length(filter(m -> !isnothing(m), match.(doom1, lumpnames))) > 0
    isd2 = length(filter(m -> !isnothing(m), match.(doom2, lumpnames))) > 0

    if isd1
        return "DOOM1"
    elseif isd2
        return "DOOM2"
    else
        return "UNKNOWN"
    end
end

function read_PLAYPAL(io::IOStream, offset, npals=14)
    seek(io, offset)
    palettes = ntuple(npals) do _
        colors = read(io, 768)
        return DoomBase.Palette(colors)
    end

    playpal = DoomBase.PLAYPAL(palettes)
    return playpal
end

function read_graphic(io::IOStream, offset, dsize)
    seek(io, offset)
    graphic_data = read(io, dsize)

    width, height = reinterpret(UInt16, @view graphic_data[1:4])
    leftoff, topoff = reinterpret(Int16, @view graphic_data[5:8])

    offsets = reinterpret(UInt32, @view graphic_data[8 .+ (1:4*width)]) 

    cols = Column.(Ref(graphic_data), offsets, height)

    return DoomBase.DoomGraphic(width, height, leftoff, topoff, cols)
end

function read_linedefs(io::IOStream, offset, dsize)
    seek(io, offset)

    _linedata = read(io, dsize)
    linedata = reinterpret(NTuple{7, Int16}, _linedata)
    lines = map(l -> DoomBase.LineDef(l...), linedata)

    return lines
end

function read_vertexes(io::IOStream, offset, dsize)
    seek(io, offset)
    _vertdata = read(io, dsize)
    vertdata = reinterpret(NTuple{2, Int16}, _vertdata)
    verts = map(v -> DoomBase.Vertex(v...), vertdata)

    return verts
end

function read_segs(io::IOStream, offset, ssize)
    seek(io, offset)
    _segdata = read(io, ssize)
    segdata = reinterpret(NTuple{6,  Int16}, _segdata)
    segs = map(s -> DoomBase.Seg(s...), segdata)

    return segs
end

function read_subsectors(io::IOStream, offset, ssize)
    seek(io, offset)
    _subdata = read(io, ssize)
    subdata = reinterpret(NTuple{2, Int16}, _subdata)
    subsectors = map(s -> DoomBase.Subsector(s...), subdata)

    return subsectors

end