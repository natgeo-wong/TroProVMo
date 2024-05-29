using DrWatson
@quickactivate "TroProVMo"

using Interpolations

include(srcdir("samsnd.jl"))
include(srcdir("samlsf.jl"))

prjname = "DetrainmentDecay"
radname = "P"

z,p,_,_,_,_ = readsnd("$(radname).snd";prjname); nz = length(z)

function wforcing(z,p=zeros(length(z));w₀)

    ds  = NCDataset(datadir("gravitywave.nc"))
	zi	= ds["z"][:]
	wi 	= ds["w"][:,101:102,(end-20):end]
	close(ds)

    itp = interpolate(zi,wi)

    nz = length(z)
    lsfdata = zeros(nz,7)

    lsfdata[:,1] .= z
    if !iszero(sum(p))
        lsfdata[:,2] .= p
    end

    for iz = 1 : nz
        lsfdata[iz,7] = itp(zi[iz]) * w₀
    end
    
    return lsfdata

end

for w in vcat(0:0.1:1)/10
    wstring = @sprintf("%04.2f",w)
    fid = joinpath(radname,"w_$(wstring)mps.lsf")
    printlsf(fid,wforcing(z,p,w₀=w),1009.32;prjname)
end