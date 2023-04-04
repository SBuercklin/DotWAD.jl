find_lump(wad::VanillaWAD, lumpname) = find_lump(wad.lumps, lumpname)

function find_lump(lumps, lumpname)
    idx = find_lump_idx(lumps, lumpname)

    isnothing(idx) && return nothing

    return lumps[idx]
end

find_lump_idx(wad::VanillaWAD, lumpname) = find_lump_idx(wad.lumps, lumpname)
find_lump_idx(lumps, lumpname) = findfirst(isequal(lumpname) ∘ Base.Fix2(getproperty, :name), lumps)

function read_lump(io, lump)
    pos = lump.filepos
    lsize = lump.size
    seek(io, pos)

    return read(io, lsize)
end

# Returns a Vector of Intervals with each Interval defining the first and last 
#   location of a set of contiguous bytes to read.
# We use this to read the patch data in as few reads as possible
function get_data_intervals_from_lumps(patch_lumps)
    intervals = map(patch_lumps) do l
        return (l.filepos)..(l.filepos + l.size)
    end

    return sort(union(intervals); by = first)
end