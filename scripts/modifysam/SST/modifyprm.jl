using DrWatson
@quickactivate "TroProVMo"
using Logging
using Printf

include(srcdir("sam.jl"))

schname = "DGW"
radname = "P"

sstvec  = vcat(
    295:297,297.5:0.5:299,299.5:0.1:299.9,
    300.1:0.1:300.5,301:0.5:302.5,303:305
)

if schname == "DGW"
    wtgvec = [0.05,0.1,0.2,0.5,1,2,5,10,20,50,100,200]
else
    wtgvec = [2,2*sqrt(2.5),5]
    wtgvec = vcat(0.1,wtgvec/10,1,wtgvec,10,wtgvec*10,100)
end

tprm    = projectdir("exp","tmp.prm")

for wtgii in wtgvec, sst in sstvec

    expname = powername(wtgii,schname)
    runname = "SST$(@sprintf("%5.1f",sst))K"
    oprm = projectdir("run","modifysam","SST","prmtemplates","$(schname)_$(radname).prm")
    nprm = projectdir("exp","prm","SST-$(schname)_$(radname)",expname,"$(runname).prm")

    if schname == "DGW"
           wtgdmp = wtgii; wtgrlx = 1
    else;  wtgrlx = wtgii; wtgdmp = 1
    end

    open(tprm,"w") do fprm
        open(oprm,"r") do rprm
            s = read(rprm,String)
            s = replace(s,"[expname]" => expname)
            s = replace(s,"[runname]" => runname)
            s = replace(s,"[sst]" => @sprintf("%5.1f",sst))
            s = replace(s,"[bool]" => "true")
            s = replace(s,"[am]"  => @sprintf("%7e",wtgdmp))
            s = replace(s,"[tau]" => @sprintf("%7e",wtgrlx))
            write(fprm,s)
        end
    end
    mkpath(projectdir("exp","prm","SST-$(schname)_$(radname)",expname))
    mv(tprm,nprm,force=true)
    @info "Creating new prm file for SST-$(schname)_$(radname) $expname $runname"
    
end
