struct LumpDirEntry
	filepos::Int32
	size::Int32
	name::SVector{8, UInt8}	
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