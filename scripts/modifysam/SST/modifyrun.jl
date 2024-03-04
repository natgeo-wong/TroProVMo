using DrWatson
@quickactivate "TroProVMo"
using Printf

include(srcdir("sam.jl"))

email   = ""
schname = "DGW"
radname = "P"
tprm    = projectdir("exp","tmp.prm")
sstvec  = vcat(295:299,299.5:0.1:299.9,300.1:0.1,300.5,301:305)

if schname == "DGW"
    wtgvec = [0.02,0.05,0.1,0.2,0.5,1,2,5,10,20,50,100,200,500]
else
    wtgvec = [sqrt(2),2,2*sqrt(2.5),5,5*sqrt(2)]
    wtgvec = vcat(wtgvec/10,1,wtgvec,10,wtgvec*10)
end


mrun = projectdir("run","modifysam","runtemplates","modelrun.sh")
brun = projectdir("run","modifysam","runtemplates","Build.csh")

open(mrun,"r") do frun
    s = read(frun,String)
    for wtgii in wtgvec, sst in sstvec
        
        csename = "SST-$(schname)_$(radname)"
        expname = powername(wtgii)
        runname = "SST$(@sprintf("%5.1f",sst))K"

        open(nrun = projectdir("run",csename,expname,"$(runname).sh"),"w") do wrun
            sn = replace(s ,"[email]"    => email)
            sn = replace(sn,"[dirname]"  => projectdir())
            sn = replace(sn,"[csename]"  => csename)
            sn = replace(sn,"[expname]"  => expname)
            sn = replace(sn,"[runname]"  => runname)
            sn = replace(sn,"[sndname]"  => radname)
            sn = replace(sn,"[lsfname]"  => "noforcing")
            write(wrun,sn)
        end

    end
end

open(brun,"r") do frun
    s = read(frun,String)
    for wtgii in wtgvec, sst in sstvec
        
        csename = "SST-$(schname)_$(radname)"
        expname = powername(wtgii)

        open(projectdir("run",csename,expname,"Build.csh"),"w") do wrun
            sn = replace(s ,"[datadir]" => datadir())
            sn = replace(sn,"[csename]" => csename)
            sn = replace(sn,"[expname]" => expname)
            write(wrun,sn)
        end

    end
end