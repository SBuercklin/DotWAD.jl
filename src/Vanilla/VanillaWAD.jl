#=
    High level WAD
=#

struct VanillaWAD{TL, TP, TC, TPA}
    game::Symbol
    wadtype::Symbol
    lumps::TL
    PLAYPAL::TP
    COLORMAP::TC
    PATCHES::TPA
end
