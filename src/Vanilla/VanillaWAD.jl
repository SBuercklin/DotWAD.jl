#=
    High level WAD
=#

struct VanillaWAD{TL, TP, TC, TPA, T1, T2}
    game::Symbol
    wadtype::Symbol
    lumps::TL
    PLAYPAL::TP
    COLORMAP::TC
    PATCHES::TPA
    TEXTURE1::T1
    TEXTURE2::T2
end
