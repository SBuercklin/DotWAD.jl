# Reads an ASCII string of length `n` from the IO stream at location `seekto`
function read_string(io::IOStream, n, seekto=nothing)
    if !isnothing(seekto)
        seek(io, seekto)
    end

    return String(read(io, n))
end
