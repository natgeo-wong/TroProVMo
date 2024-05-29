using DrWatson
@quickactivate "TroProVMo"
using Logging
using Printf

include(srcdir("common.jl"))
include(srcdir("sam.jl"))

prjname = "DetrainmentDecay"
schname = "DGW"
radname = "P"

if schname == "DGW"
    wtgvec = [0.01,0.02,0.05,0.1,0.2]
else
    wtgvec = [0.2,0.5,1,2]
end
sstvec = collect(300:0.1:305)
wlsvec = vcat(0:0.02:1)/10

oprm = prmtemplatedir(schname,"$radname.prm";prjname)

for wtgii in wtgvec

    pwrname = powername(wtgii,schname)
    folname = prmdir(schname,radname,pwrname;prjname); mkpath(folname)

    if schname == "DGW"
          wtgdmp = wtgii; wtgrlx = 1
    else; wtgrlx = wtgii; wtgdmp = 1
    end

    for wls in wlsvec
        runname = "w_$(@sprintf("%05.3f",wls))mps"
        open(joinpath(folname,"$(runname).prm"),"w") do fprm
            open(oprm,"r") do rprm
                s = read(rprm,String)
                s = replace(s,"[runname]" => runname)
                s = replace(s,"[sst]" => @sprintf("%5.1f",300))
                s = replace(s,"[bool]" => "true")
                s = replace(s,"[am]"  => @sprintf("%7e",wtgdmp))
                s = replace(s,"[tau]" => @sprintf("%7e",wtgrlx))
                write(fprm,s)
            end
        end
        @info "Creating new prm file for $prjname $schname $radname $pwrname $runname"
    end

    for sst in sstvec
        runname = "SST$(@sprintf("%5.1f",sst))K"
        open(joinpath(folname,"$(runname).prm"),"w") do fprm
            open(oprm,"r") do rprm
                s = read(rprm,String)
                s = replace(s,"[runname]" => runname)
                s = replace(s,"[sst]" => @sprintf("%5.1f",sst))
                s = replace(s,"[bool]" => "true")
                s = replace(s,"[am]"  => @sprintf("%7e",wtgdmp))
                s = replace(s,"[tau]" => @sprintf("%7e",wtgrlx))
                write(fprm,s)
            end
        end
        @info "Creating new prm file for $prjname $schname $radname $pwrname $runname"
    end
    
end
