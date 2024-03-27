using DrWatson
@quickactivate "TroProVMo"
using Printf

include(srcdir("common.jl"))
include(srcdir("sam.jl"))

schname = "DGW"
radname = "P_FSF"
doBuild = true
email   = ""

if schname == "DGW"
    wtgvec = [0.01,0.02,0.05,0.1,0.2]
else
    wtgvec = [0.2,0.5,1,2]
end
sstvec = collect(300.5:0.5:302)
fsfvec = collect(10:10:50)
wlsvec = vcat(0.05,0.1:0.1:0.5)

mrun = rundir("modifysam","runtemplates","modelrun.sh")
brun = rundir("modifysam","runtemplates","Build.csh")

open(mrun,"r") do frun

    s = read(frun,String)
    csename = joinpath("EnergeticvsMechanistic",schname,radname)

    for wtgii in wtgvec

        expname = powername(wtgii,schname)
        
        for sst in sstvec
            runname = "w_0.00mps_fsf+00Wpm2_SST$(@sprintf("%5.1f",sst))K"
            lsfname = joinpath("EnergeticvsMechanistic",radname,"w_0.00mps")
            open(rundir(csename,expname,"$(runname).sh"),"w") do wrun
                sn = replace(s ,"[email]"    => email)
                sn = replace(sn,"[dirname]"  => projectdir())
                sn = replace(sn,"[csename]"  => csename)
                sn = replace(sn,"[expname]"  => expname)
                sn = replace(sn,"[runname]"  => runname)
                sn = replace(sn,"[sndname]"  => "$(radname)_FSF")
                sn = replace(sn,"[lsfname]"  => lsfname)
                write(wrun,sn)
            end
        end
        
        for fsf in fsfvec
            runname = "w_0.00mps_fsf+$(@sprintf("%02d",fsf))Wpm2_SST300.0K"
            lsfname = joinpath("EnergeticvsMechanistic",radname,"w_0.00mps")
            open(rundir(csename,expname,"$(runname).sh"),"w") do wrun
                sn = replace(s ,"[email]"    => email)
                sn = replace(sn,"[dirname]"  => projectdir())
                sn = replace(sn,"[csename]"  => csename)
                sn = replace(sn,"[expname]"  => expname)
                sn = replace(sn,"[runname]"  => runname)
                sn = replace(sn,"[sndname]"  => "$(radname)_FSF")
                sn = replace(sn,"[lsfname]"  => lsfname)
                write(wrun,sn)
            end
        end
        
        for wls in wlsvec
            wlsname = @sprintf("%04.2f",wls)
            runname = "w_$(@sprintf("%04.2f",wls))mps_fsf+00Wpm2_SST300.0K"
            lsfname = joinpath("EnergeticvsMechanistic",radname,"w_$(wlsname)mps")
            open(rundir(csename,expname,"$(runname).sh"),"w") do wrun
                sn = replace(s ,"[email]"    => email)
                sn = replace(sn,"[dirname]"  => projectdir())
                sn = replace(sn,"[csename]"  => csename)
                sn = replace(sn,"[expname]"  => expname)
                sn = replace(sn,"[runname]"  => runname)
                sn = replace(sn,"[sndname]"  => "$(radname)_FSF")
                sn = replace(sn,"[lsfname]"  => lsfname)
                write(wrun,sn)
            end
        end

    end
end

if doBuild
    open(brun,"r") do frun
        s = read(frun,String)
        for wtgii in wtgvec, sst in sstvec
            
            csename = "EvM-$(schname)_$(radname)"
            expname = powername(wtgii,schname)

            open(rundir(csename,expname,"$(runname).sh"),"w") do wrun
                sn = replace(s ,"[datadir]" => datadir())
                sn = replace(sn,"[csename]" => csename)
                sn = replace(sn,"[expname]" => expname)
                write(wrun,sn)
            end

        end
    end
end