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

mrun = rundir("EnergeticvsMechanistic","runtemplates","modelrun.sh")
brun = rundir("EnergeticvsMechanistic","runtemplates","Build.csh")

open(mrun,"r") do frun

    s = read(frun,String)

    for wtgii in wtgvec

        expname = powername(wtgii,schname)
        folname = rundir("EnergeticvsMechanistic",schname,radname,expname)
        
        for sst in sstvec
            runname = "w_0.00mps_fsf+00Wpm2_SST$(@sprintf("%5.1f",sst))K"
            lsfname = joinpath("EnergeticvsMechanistic",radname,"w_0.00mps")
            open(joinpath(folname,"$(runname).sh"),"w") do wrun
                sn = replace(s ,"[email]"   => email)
                sn = replace(sn,"[dirname]" => projectdir())
                sn = replace(sn,"[schname]" => schname)
                sn = replace(sn,"[radname]" => radname)
                sn = replace(sn,"[expname]" => expname)
                sn = replace(sn,"[runname]" => runname)
                sn = replace(sn,"[sndname]" => radname)
                sn = replace(sn,"[lsfname]" => lsfname)
                write(wrun,sn)
            end
        end
        
        for fsf in fsfvec
            runname = "w_0.00mps_fsf+$(@sprintf("%02d",fsf))Wpm2_SST300.0K"
            lsfname = joinpath("EnergeticvsMechanistic",radname,"w_0.00mps")
            open(joinpath(folname,"$(runname).sh"),"w") do wrun
                sn = replace(s ,"[email]"   => email)
                sn = replace(sn,"[dirname]" => projectdir())
                sn = replace(sn,"[schname]" => schname)
                sn = replace(sn,"[radname]" => radname)
                sn = replace(sn,"[expname]" => expname)
                sn = replace(sn,"[runname]" => runname)
                sn = replace(sn,"[sndname]" => radname)
                sn = replace(sn,"[lsfname]" => lsfname)
                write(wrun,sn)
            end
        end
        
        for wls in wlsvec
            wlsname = @sprintf("%04.2f",wls)
            runname = "w_$(wlsname)mps_fsf+00Wpm2_SST300.0K"
            lsfname = joinpath("EnergeticvsMechanistic",radname,"w_$(wlsname)mps")
            open(joinpath(folname,"$(runname).sh"),"w") do wrun
                sn = replace(s ,"[email]"   => email)
                sn = replace(sn,"[dirname]" => projectdir())
                sn = replace(sn,"[schname]" => schname)
                sn = replace(sn,"[radname]" => radname)
                sn = replace(sn,"[expname]" => expname)
                sn = replace(sn,"[runname]" => runname)
                sn = replace(sn,"[sndname]" => radname)
                sn = replace(sn,"[lsfname]" => lsfname)
                write(wrun,sn)
            end
        end

    end

end

if doBuild
    open(brun,"r") do frun
        s = read(frun,String)
        for wtgii in wtgvec, sst in sstvec
            expname = powername(wtgii,schname)
            folname = rundir("EnergeticvsMechanistic",schname,radname,expname)
            open(joinpath(folname,"Build.csh"),"w") do wrun
                sn = replace(s ,"[datadir]" => datadir("EnergeticvsMechanistic"))
                sn = replace(sn,"[schname]" => schname)
                sn = replace(sn,"[radname]" => radname)
                sn = replace(sn,"[expname]" => expname)
                write(wrun,sn)
            end
        end
    end
end