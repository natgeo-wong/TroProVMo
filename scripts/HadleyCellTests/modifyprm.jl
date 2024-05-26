using DrWatson
@quickactivate "TroProVMo"
using Logging
using Printf

include(srcdir("common.jl"))
include(srcdir("sam.jl"))
include(srcdir("whadley.jl"))

prjname = "HadleyCellTests"
radname = "P"

wlsvec = vcat(-1:0.05:0,0:0.1:5); wlsvec = wlsvec[.!iszero.(wlsvec)]
oprm = rundir("prmtemplates","$(radname).prm";prjname)

for wls in wlsvec

    runname = wlsname(wls)

    folname = prmdir("DE2019Advection",radname;prjname); mkpath(folname)
    open(joinpath(folname,"$(runname).prm"),"w") do fprm
        open(oprm,"r") do rprm
            s = read(rprm,String)
            s = replace(s,"[expname]" => "DE2019Advection")
            s = replace(s,"[runname]" => runname)
            s = replace(s,"[doDE]" => "true")
            s = replace(s,"[wmax]" => @sprintf("%5e",wls*1.e-2))
            write(fprm,s)
        end
    end
    @info "Creating new prm file for $prjname DE2019Advection $radname $runname"

    folname = prmdir("FullSubsidence",radname;prjname); mkpath(folname)
    open(joinpath(folname,"$(runname).prm"),"w") do fprm
        open(oprm,"r") do rprm
            s = read(rprm,String)
            s = replace(s,"[expname]" => "FullSubsidence")
            s = replace(s,"[runname]" => runname)
            s = replace(s,"[doDE]" => "false")
            s = replace(s,"[wmax]" => @sprintf("%5e",wls*1.e-2))
            write(fprm,s)
        end
    end
    @info "Creating new prm file for $prjname FullSubsidence $radname $runname"

end