function whadleycoeff(w₀,schname)

    if schname == "DGW"
        if w₀ > 0
            return [1,-0.2,0,0,0]
        else
            return [1,0,0,0,0]
            w = w₀ .*  sin.(z/ztrop*pi)
        end
    elseif schname == "SPC"
        if w₀ > 0
            return [1,-0.3,0.1,-0.03,0.01]
        else
            return [1,0.2,-0.3,0.4]
        end
    end

end