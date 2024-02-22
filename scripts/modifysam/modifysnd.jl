using DrWatson
@quickactivate "TroProVMo"
using Printf

include(srcdir("sam.jl"))
include(srcdir("samsnd.jl"))

expii = "T"

z,p,_,q,t,_ = readsnd(projectdir("exp","snd",expii))
nz = length(z)
snddata = zeros(nz,6)
snddata[:,1] .= z
snddata[:,2] .= p
snddata[:,4] .= q

t_h = t .+ 0.05; snddata[:,3] .= t_h .* (1000 ./p).^(287/1004)
createsndmean("$(expii)_warm",snddata;psfc=1009.32)

t_h = t .- 0.05; snddata[:,3] .= t_h .* (1000 ./p).^(287/1004)
createsndmean("$(expii)_cool",snddata;psfc=1009.32)

t_h = t .+ 0.1; snddata[:,3] .= t_h .* (1000 ./p).^(287/1004)
createsndmean("$(expii)_hot",snddata;psfc=1009.32)

t_h = t .- 0.1; snddata[:,3] .= t_h .* (1000 ./p).^(287/1004)
createsndmean("$(expii)_cold",snddata;psfc=1009.32)