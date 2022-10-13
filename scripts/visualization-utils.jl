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