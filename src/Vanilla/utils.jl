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

normalize_byte_name(s) = rstrip(String(s), '\0')

# Returns a Vector of Intervals with each Interval defining the first and last 
#   location of a set of contiguous bytes to read.
# We use this to read the patch data in as few reads as possible
function get_data_intervals_from_lumps(patch_lumps)
    intervals = map(patch_lumps) do l
        return (l.filepos)..(l.filepos + l.size)
    end

    return sort(union(intervals); by = first)
end

function idx_to_patch(wad)
    pnames = wad.PNAMES.pnames
    patches = wad.PATCHES
    patch_names = get_ordered_patch_names(wad)

    sorted_patch_idxs = map(pnames) do pn
        idx = findfirst(isequal(normalize_byte_name(pn)), patch_names)
        return idx
    end
    filter!(!isnothing, sorted_patch_idxs)
    sorted_patches = map(sorted_patch_idxs) do idx
        return patches[idx]
    end

    return sorted_patches
end

function get_ordered_patch_names(wad)
    pstart_idx = find_lump_idx(wad, "P_START")
    pend_idx = find_lump_idx(wad, "P_END")

    plumps = wad.lumps[pstart_idx:pend_idx] 
    filter!(l -> !iszero(l.size), plumps)

    return map(l -> normalize_byte_name(l.name), plumps)
end