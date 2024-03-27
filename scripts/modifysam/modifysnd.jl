using DrWatson
@quickactivate "TroProVMo"
using Printf

include(srcdir("sam.jl"))
include(srcdir("samsnd.jl"))

expii = "P"

z,p,_,q,t,_ = readsnd(snddir("$(expii).snd"))
nz = length(z)
snddata = zeros(nz,6)
snddata[:,1] .= z
snddata[:,2] .= p
snddata[:,4] .= q

snddata[:,3] .= (t.+0.05) .* (1000 ./p).^(287/1004)
createsndmean("$(expii)_warm.snd",snddata;psfc=1009.32)

snddata[:,3] .= (t.-0.05) .* (1000 ./p).^(287/1004)
createsndmean("$(expii)_cool.snd",snddata;psfc=1009.32)

snddata[:,3] .= (t.+0.10) .* (1000 ./p).^(287/1004)
createsndmean("$(expii)_hot.snd",snddata;psfc=1009.32)

snddata[:,3] .= (t.-0.10) .* (1000 ./p).^(287/1004)
createsndmean("$(expii)_cold.snd",snddata;psfc=1009.32)