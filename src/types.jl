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

function LumpDirEntry(io::IOStream)
	filepos = read(io, Int32)
	sze = read(io, Int32)
	name = read(io, 8)
	return LumpDirEntry(filepos, sze, SVector{8}(name))
end

function Base.getproperty(lde::LumpDirEntry, s::Symbol)
	return s === :name ? String(getfield(lde, :name)) : getfield(lde, s)
end