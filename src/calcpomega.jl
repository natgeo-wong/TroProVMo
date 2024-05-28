using Trapz

function calcpω(pvec,ωvec)

    ii = pvec .>= 100
    iip = pvec[ii]
    iiω = ωvec[ii]

    return trapz(iip,iiω .* iip) / trapz(iip,iiω)

end