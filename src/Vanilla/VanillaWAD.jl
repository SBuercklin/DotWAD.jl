#=
    High level WAD
=#

struct VanillaWAD{TL, TP}
    game::Symbol
    wadtype::Symbol
    lumps::TL
    PLAYPAL::TP
end
