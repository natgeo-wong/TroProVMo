using DrWatson
@quickactivate "TroProVMo"

include(srcdir("samsnd.jl"))
include(srcdir("samlsf.jl"))

z,p,_,_,_,_ = readsnd("P"); nz = length(z)

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

printlsf(joinpath("EvM","w_0.50.lsf"),wforcing(z,p,zbl=1500,w₀=0.50),1009.32)
printlsf(joinpath("EvM","w_0.40.lsf"),wforcing(z,p,zbl=1500,w₀=0.40),1009.32)
printlsf(joinpath("EvM","w_0.30.lsf"),wforcing(z,p,zbl=1500,w₀=0.30),1009.32)
printlsf(joinpath("EvM","w_0.20.lsf"),wforcing(z,p,zbl=1500,w₀=0.20),1009.32)
printlsf(joinpath("EvM","w_0.10.lsf"),wforcing(z,p,zbl=1500,w₀=0.10),1009.32)
printlsf(joinpath("EvM","w_0.05.lsf"),wforcing(z,p,zbl=1500,w₀=0.05),1009.32)