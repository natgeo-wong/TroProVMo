using DrWatson
@quickactivate "TroProVMo"
using Logging
using Printf

include(srcdir("common.jl"))
include(srcdir("sam.jl"))

prjname = "WTGLargeScale"
radname = "P"

wlsvec = vcat(-1:0.2:2); wlsvec = wlsvec[.!iszero.(wlsvec)]

oprm = rundir("prmtemplates",schname,"$(radname).prm";prjname)

for wls in wlsvec

    expname = wlsname(wls)
    folname = prmdir("RCE",radname,expname;prjname); mkpath(folname)

    for imem = 1 : 5

        memberx = "member$(@sprintf("%02d",imem))"
        open(joinpath(folname,"$(memberx).prm"),"w") do fprm
            open(oprm,"r") do rprm
                s = read(rprm,String)
                s = replace(s,"[expname]" => expname)
                s = replace(s,"[memberx]" => memberx)
                s = replace(s,"[en]" => "$(imem)")
                write(fprm,s)
            end
        end
        @info "Creating new prm file for $prjname RCE $radname $expname member $imem"

    end

end
