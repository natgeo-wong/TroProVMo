using DrWatson
@quickactivate "TroProVMo"
using Printf

include(srcdir("sam.jl"))

email = ""

rad    = "P"
wtgvec = [0.02,0.05,0.1,0.2,0.5,1,2,5,10,20,50,100,200,500]
sstvec = vcat(295:298,299:299.9,300.1:301,302:305)

mrun = projectdir("run","modifysam","runtemplates","modelrun.sh")
brun = projectdir("run","modifysam","runtemplates","Build.csh")

open(mrun,"r") do frun
    s = read(frun,String)
    for wtgii in wtgvec, sst in sstvec
        
        csename = "SST-DGW_$(rad)"
        expname = dampingstrprnt(wtgii)
        runname = "SST$(@sprintf("%5.1f",sst))K"

        for ensembleii in 1 : 5

            mstr = @sprintf("%d",ensembleii)
            nrun = projectdir("run","SST-DGW_$(rad)",expname,"$(runname).sh")

            open(nrun,"w") do wrun
                sn = replace(s ,"[email]"    => email)
                sn = replace(sn,"[project]"  => projectdir())
                sn = replace(sn,"[csename]"  => csename)
                sn = replace(sn,"[expname]"  => expname)
                sn = replace(sn,"[runname]"  => runname)
                sn = replace(sn,"[sndname]"  => "$(expinit)")
                sn = replace(sn,"[lsfname]"  => "noforcing")
                write(wrun,sn)
            end

        end

    end
end

open(brun,"r") do frun
    s = read(frun,String)
    for wtgii in wtgvec, sst in sstvec
        
        csename = "SST-DGW_$(rad)"
        expname = "$(dampingstrprnt(wtgii))"
        nrun = projectdir("run","SST-DGW_$(rad)",expname,"Build.csh")

        open(nrun,"w") do wrun
            sn = replace(s ,"[datadir]" => datadir())
            sn = replace(sn,"[csename]" => csename)
            sn = replace(sn,"[expname]" => expname)
            write(wrun,sn)
        end

    end
end