using DrWatson
@quickactivate "TroProVMo"
using Printf

include(srcdir("common.jl"))
include(srcdir("sam.jl"))

prjname = "EnergeticvsMechanistic"
schname = "DGW"
radname = "P_FSF"
doBuild = true
email   = ""

if schname == "DGW"
    wtgvec = [0.01,0.02,0.05,0.1,0.2]
else
    wtgvec = [0.2,0.5,1,2]
end
sstvec = collect(300.5:0.5:305)
fsfvec = collect(10:10:90)
wlsvec = vcat(0,0.1:0.1:0.5,1:5)/10

mfid = open(runtemplatedir("modelrun.sh";prjname),"r"); str_m = read(mfid,String)
bfid = open(runtemplatedir("Build.csh";  prjname),"r"); str_b = read(bfid,String)

for wtgii in wtgvec

    pwrname = powername(wtgii,schname)
    folname = rundir(schname,radname,pwrname;prjname)
    
    for sst in sstvec
        runname = "w_0.00mps_fsf+00Wpm2_SST$(@sprintf("%5.1f",sst))K"
        lsfname = joinpath(radname,"w_0.00mps")
        open(joinpath(folname,"$(runname).sh"),"w") do wrun
            nstr_m = replace(str_m ,"[email]"   => email)
            nstr_m = replace(nstr_m,"[exproot]" => expdir(prjname))
            nstr_m = replace(nstr_m,"[schname]" => schname)
            nstr_m = replace(nstr_m,"[radname]" => radname)
            nstr_m = replace(nstr_m,"[pwrname]" => pwrname)
            nstr_m = replace(nstr_m,"[runname]" => runname)
            nstr_m = replace(nstr_m,"[sndname]" => radname)
            nstr_m = replace(nstr_m,"[lsfname]" => lsfname)
            write(wrun,nstr_m)
        end
    end
    
    for fsf in fsfvec
        runname = "w_0.00mps_fsf+$(@sprintf("%02d",fsf))Wpm2_SST300.0K"
        lsfname = joinpath(radname,"w_0.00mps")
        open(joinpath(folname,"$(runname).sh"),"w") do wrun
            nstr_m = replace(str_m ,"[email]"   => email)
            nstr_m = replace(nstr_m,"[exproot]" => expdir(prjname))
            nstr_m = replace(nstr_m,"[schname]" => schname)
            nstr_m = replace(nstr_m,"[radname]" => radname)
            nstr_m = replace(nstr_m,"[pwrname]" => pwrname)
            nstr_m = replace(nstr_m,"[runname]" => runname)
            nstr_m = replace(nstr_m,"[sndname]" => radname)
            nstr_m = replace(nstr_m,"[lsfname]" => lsfname)
            write(wrun,nstr_m)
        end
    end
    
    for wls in wlsvec
        wlsname = @sprintf("%04.2f",wls)
        runname = "w_$(wlsname)mps_fsf+00Wpm2_SST300.0K"
        lsfname = joinpath(radname,"w_$(wlsname)mps")
        open(joinpath(folname,"$(runname).sh"),"w") do wrun
            nstr_m = replace(str_m ,"[email]"   => email)
            nstr_m = replace(nstr_m,"[exproot]" => expdir(prjname))
            nstr_m = replace(nstr_m,"[schname]" => schname)
            nstr_m = replace(nstr_m,"[radname]" => radname)
            nstr_m = replace(nstr_m,"[pwrname]" => pwrname)
            nstr_m = replace(nstr_m,"[runname]" => runname)
            nstr_m = replace(nstr_m,"[sndname]" => radname)
            nstr_m = replace(nstr_m,"[lsfname]" => lsfname)
            write(wrun,nstr_m)
        end
    end

    if doBuild
        open(joinpath(folname,"Build.csh"),"w") do wrun
            nstr_b = replace(str_b ,"[datadir]" => datadir(prjname))
            nstr_b = replace(nstr_b,"[schname]" => schname)
            nstr_b = replace(nstr_b,"[radname]" => radname)
            nstr_b = replace(nstr_b,"[expname]" => pwrname)
            write(wrun,nstr_b)
        end
    end

end

close(mfid)
close(bfid)