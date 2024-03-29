using DrWatson
@quickactivate "TroProVMo"

include(srcdir("samsnd.jl"))
include(srcdir("samlsf.jl"))

prjname = "EnergeticvsMechanistic"
radname = "P_FSF"

z,p,_,_,_,_ = readsnd("$(radname).snd";prjname); nz = length(z)

function wforcing(z,p=zeros(length(z));zbl,w₀)

    nz = length(z)
    lsfdata = zeros(nz,7)

    lsfdata[:,1] .= z
    if !iszero(sum(p))
        lsfdata[:,2] .= p
    end

    w = w₀ .* (z - (z.^2)/2/zbl)/zbl*2
    if w₀ > 0
        w[w.<0] .= 0
    else
        w[w.>0] .= 0
    end
    lsfdata[:,7] .= w
    
    return lsfdata

end

for w in vcat(0,0.1:0.1:0.5,1:5)/10
    wstring = @sprintf("%04.2f",w)
    fid = joinpath(radname,"w_$(wstring)mps.lsf")
    printlsf(fid,wforcing(z,p,zbl=1500,w₀=w),1009.32;prjname)
end