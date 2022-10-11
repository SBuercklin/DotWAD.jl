function visualize_palette(p)
    fig = Figure()
    ax = Axis(fig[1,1])


    ax.yticklabelsvisible = false
    ax.xticklabelsvisible = false
    ax.ygridvisible = false
    ax.xgridvisible = false
    ax.xticksvisible = false
    ax.yticksvisible = false

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
