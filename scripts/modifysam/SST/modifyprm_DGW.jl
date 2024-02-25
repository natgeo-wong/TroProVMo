using DrWatson
@quickactivate "TroProVMo"
using Logging
using Printf

include(srcdir("sam.jl"))

rad    = "P"
tprm   = projectdir("exp","tmp.prm")
wtgvec = [0.02,0.05,0.1,0.2,0.5,1,2,5,10,20,50,100,200,500]
sstvec = vcat(295:299,299.5:0.1:299.9,300.1:0.1:300.5,301:305)

for wtgii in wtgvec, sst in sstvec
    expname = dampingstrprnt(wtgii)
    runname = "SST$(@sprintf("%5.1f",sst))K"
    oprm = projectdir("run","modifysam","SST","prmtemplates","DGW_P.prm")
    nprm = projectdir("exp","prm","SST-DGW_$(rad)",expname,"$(runname).prm")
    open(tprm,"w") do fprm
        open(oprm,"r") do rprm
            s = read(rprm,String)
            s = replace(s,"[tau]" => @sprintf("%7e",1))
            s = replace(s,"[sst]" => @sprintf("%5.1f",sst))
            s = replace(s,"[bool]" => "true")
            s = replace(s,"[am]"  => @sprintf("%7e",wtgii))
            s = replace(s,"[wtgstring]" => expname)
            write(fprm,s)
        end
    end
    mkpath(projectdir("exp","prm","SST-DGW_$(rad)",expname))
    mv(tprm,nprm,force=true)
    @info "Creating new prm file for SST-DGW_$(rad) $expname $runname"
end
