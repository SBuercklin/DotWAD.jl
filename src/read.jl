function parse_WAD(f)
    return open(f, "r") do io
        wadtype, nlumps, dir_offset = read_header(io)
        lump_dir = read_directory(io, nlumps, dir_offset)

        return lump_dir
    end
end

# Assumes the IOStream points to the start of the .WAD file/header
function read_header(io::IOStream)
    wadtype = read_string(io, 4)
    nlumps = read(io, Int32)
    lump_ptr = read(io, Int32)

    return wadtype, nlumps, lump_ptr
end

function read_directory(io::IOStream, nlumps, dir_offset)
    seek(io, dir_offset)

    lumpdir = [LumpDirEntry(io) for _ in 1:nlumps]

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