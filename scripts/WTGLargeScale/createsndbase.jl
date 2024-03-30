using DrWatson
@quickactivate "TroProVMo"

include(srcdir("sam.jl"))
include(srcdir("samsnd.jl"))
include(srcdir("samlsf.jl"))

prjname = "WTGLargeScale"
schname = "DGW"
radname = "D"
wlsvec = vcat(-1:0.2:2); wlsvec = wlsvec[.!iszero.(wlsvec)]

osnd = snddir("$(radname).snd";prjname)

for wls in wlsvec

    mkpath(snddir(schname,radname;prjname))
    nsnd = snddir(schname,radname,"$(wlsname(wls)).snd";prjname)
    cp(osnd,nsnd,force=true)

end