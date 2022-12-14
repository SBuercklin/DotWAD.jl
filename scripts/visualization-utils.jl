function clear_axes!(ax)
    ax.yticklabelsvisible = false
    ax.xticklabelsvisible = false
    ax.ygridvisible = false
    ax.xgridvisible = false
    ax.xticksvisible = false
    ax.yticksvisible = false

    return ax
end

function visualize_palette(p)
    fig = Figure()
    ax = Axis(fig[1,1]) 

    clear_axes!(ax)

    xlims!(ax, [0, 16.2])
    ylims!(ax, [-16.1, 0.1])

    idx = 1
    for x in 0:15
        for y in -1:-1:-16
            poly!(ax, Rect(x+0.1, y, 0.95, 0.95), color = palette.colors[idx])
            idx += 1
        end
    end

    return fig
end

function visualize_graphic(
    graphic, palette, transparency = DoomBase.DOOMCOLOR(UInt8(155), UInt8(0), UInt8(155))
    )
    graphic_size = (graphic.height, graphic.width)

    fig = Figure()
    ax = Axis(fig[1,1], aspect = /(reverse(graphic_size)...))

    clear_axes!(ax)

    im_colors = DoomBase.DoomGraphic_to_image(graphic, palette, transparency)

    image!(ax, reverse(im_colors'; dims = 2); interpolate = false)

    return fig
end

function linedefs_to_linestrings(lines, verts)
    ls = map(lines) do l
        (; start, terminate) = l
        v0 = verts[start+1]
        vf = verts[terminate+1]

        p0 = Point(v0.x, v0.y)
        pf = Point(vf.x, vf.y)

        return LineString(SVector(p0, pf))
    end

    return ls
end

function visualize_map(lines, verts, scaler = 0.5)
    x0, xf = extrema(v -> v.x, verts)
    y0, yf = extrema(v -> v.y, verts)

    dx = (xf - x0) * scaler
    dy = (yf - y0) * scaler

    ls = linedefs_to_linestrings(lines, verts)

    fig = Figure()
    ax = Axis(fig[1,1], aspect = DataAspect())
    limits!(ax, (x0 - dx, xf + dx), (y0 - dy , yf + dy))

    clear_axes!(ax)

    plot!(ax, ls)

    return fig
end

function segs_to_linestrings(segs, lines, verts)
    ls = map(segs) do s
        (; start, terminate) = s
        v0 = verts[start + 1]
        vf = verts[terminate + 1]

        p0 = Point(v0.x, v0.y)
        pf = Point(vf.x, vf.y)

        return LineString(SVector(p0, pf))
    end

    return ls
end

function subsector_to_linestrings(sub, segs, lines, verts)
    idx0 = 1 + sub.first_seg
    idxf = idx0 + sub.seg_count - 1

    subsegs = segs[idx0:idxf]

    return segs_to_linestrings(subsegs, lines, verts)
end

function visualize_map_subsegs(subs, segs, lines, verts, scaler = 0.05)
    f = visualize_map(lines, verts, scaler)
    ax = only(contents(f[1,1]))

    mapplot = only(plots(ax))

    sl = Slider(f[2,1], range = 1:length(subs), snap = true)
    on(sl.value) do idx
        all_plots = plots(ax)
        for p in filter(!isequal(mapplot), all_plots)
            delete!(ax, p)
        end

        ssec = subs[idx]
        ls = subsector_to_linestrings(ssec, segs, dlines, verts)

        plot!(ax, ls, color = :red, linewidth = 4)
    end

    return f
end