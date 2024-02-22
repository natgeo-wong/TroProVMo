using DrWatson
@quickactivate "TroProVMo"
using Logging
using Printf

include(srcdir("sam.jl"))

expinit = "P"
tprm    = projectdir("exp","tmp.prm")
wtgvec  = [0.1,sqrt(2)/10,0.2,sqrt(2.5)/5,0.5,sqrt(2)/2,1]
sstvec  = vcat(295:299,299.5,300,300.5,301:305)

for powerii in wtgvec, sst in sstvec
    expname = "$(expinit)$(dampingstrprnt(powerii))"
    conii = "$(@sprintf("%5.1f",sst))"
    mkpath(projectdir("exp","prm","DGW",expname,conii))
    for imember = 1 : 5
        mstr = @sprintf("%d",imember)
        oprm = projectdir("run","modifysam","prmtemplates","DGW_$(expinit).prm")
        nprm = projectdir("exp","prm","DGW",expname,conii,"member$(mstr).prm")
        open(tprm,"w") do fprm
            open(oprm,"r") do rprm
                s = read(rprm,String)
                s = replace(s,"[xx]" => mstr)
                s = replace(s,"[en]" => "$(imember)")
                s = replace(s,"[tau]" => @sprintf("%7e",1))
                s = replace(s,"[sst]" => @sprintf("%5.1f",sst))
                s = replace(s,"[bool]" => "true")
                s = replace(s,"[am]"  => @sprintf("%7e",powerii))
                s = replace(s,"e+" => "e")
                write(fprm,s)
            end
        end
        mkpath(projectdir("exp","prm","DGW",expname,conii))
        mv(tprm,nprm,force=true)
        @info "Creating new prm file for DGW $expname $conii ensemble member $imember"
    end
end
