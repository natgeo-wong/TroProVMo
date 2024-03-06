using DrWatson
@quickactivate "TroProVMo"
using Printf

include(srcdir("sam.jl"))

schname = "DGW"
radname = "P"
doBuild = true
email   = ""

sstvec  = vcat(295:0.5:298,298.5:0.1:299.9,300.1:0.1:301.5,302:0.5:305)

if schname == "DGW"
    wtgvec = [0.05,0.1,0.2,0.5,1,2,5,10,20,50,100,200]
else
    wtgvec = [2,2*sqrt(2.5),5]
    wtgvec = vcat(0.1,wtgvec/10,1,wtgvec,10,wtgvec*10,100)
end

mrun = projectdir("run","modifysam","runtemplates","modelrun.sh")
brun = projectdir("run","modifysam","runtemplates","Build.csh")

open(mrun,"r") do frun
    s = read(frun,String)
    for wtgii in wtgvec, sst in sstvec
        
        csename = "SST-$(schname)_$(radname)"
        expname = powername(wtgii,schname)
        runname = "SST$(@sprintf("%5.1f",sst))K"

        open(projectdir("run",csename,expname,"$(runname).sh"),"w") do wrun
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

if doBuild
    open(brun,"r") do frun
        s = read(frun,String)
        for wtgii in wtgvec, sst in sstvec
            
            csename = "SST-$(schname)_$(radname)"
            expname = powername(wtgii,schname)

            open(projectdir("run",csename,expname,"Build.csh"),"w") do wrun
                sn = replace(s ,"[datadir]" => datadir())
                sn = replace(sn,"[csename]" => csename)
                sn = replace(sn,"[expname]" => expname)
                write(wrun,sn)
            end

        end
    end
end