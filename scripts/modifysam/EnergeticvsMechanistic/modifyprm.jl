using DrWatson
@quickactivate "TroProVMo"
using Logging
using Printf

include(srcdir("sam.jl"))

schname = "DGW"
radname = "P_FSF"

if schname == "DGW"
    wtgvec = [0.01,0.02,0.05,0.1,0.2]
else
    wtgvec = [0.2,0.5,1,2]
end
sstvec = collect(300.5:0.5:302)
fsfvec = collect(10:10:50)
wlsvec = vcat(0.05,0.1:0.1:0.5)

tprm = expdir("tmp.prm")
oprm = rundir("modifysam","EnergeticvsMechanistic","prmtemplates",schname,"$radname.prm")

for wtgii in wtgvec

    expname = powername(wtgii,schname)
    mkpath(prmdir("EnergeticvsMechanistic",schname,radname,expname))

    if schname == "DGW"
          wtgdmp = wtgii; wtgrlx = 1
    else; wtgrlx = wtgii; wtgdmp = 1
    end

    for sst in sstvec
        runname = "w_0.00mps_fsf+00Wpm2_SST$(@sprintf("%5.1f",sst))K"
        nprm = prmdir("EnergeticvsMechanistic",schname,radname,expname,"$(runname).prm")
        open(tprm,"w") do fprm
            open(oprm,"r") do rprm
                s = read(rprm,String)
                s = replace(s,"[runname]" => runname)
                s = replace(s,"[sst]" => @sprintf("%5.1f",sst))
                s = replace(s,"[bool]" => "true")
                s = replace(s,"[am]"  => @sprintf("%7e",wtgdmp))
                s = replace(s,"[tau]" => @sprintf("%7e",wtgrlx))
                s = replace(s,"[fluxt0]" => @sprintf("%7e",fluxt0(0,radname)))
                s = replace(s,"[fluxq0]" => @sprintf("%7e",fluxq0(0,radname)))
                write(fprm,s)
            end
        end
        mv(tprm,nprm,force=true)
        @info "Creating new prm file for EnergeticvsMechanistic $(schname) $(radname) $expname $runname"
    end

    for fsf in fsfvec
        runname = "w_0.00mps_fsf+$(@sprintf("%02d",fsf))Wpm2_SST300.0K"
        nprm = prmdir("EnergeticvsMechanistic",schname,radname,expname,"$(runname).prm")
        open(tprm,"w") do fprm
            open(oprm,"r") do rprm
                s = read(rprm,String)
                s = replace(s,"[runname]" => runname)
                s = replace(s,"[sst]" => @sprintf("%5.1f",300))
                s = replace(s,"[bool]" => "true")
                s = replace(s,"[am]"  => @sprintf("%7e",wtgdmp))
                s = replace(s,"[tau]" => @sprintf("%7e",wtgrlx))
                s = replace(s,"[fluxt0]" => @sprintf("%7e",fluxt0(fsf,radname)))
                s = replace(s,"[fluxq0]" => @sprintf("%7e",fluxq0(fsf,radname)))
                write(fprm,s)
            end
        end
        mv(tprm,nprm,force=true)
        @info "Creating new prm file for EnergeticvsMechanistic $(schname) $(radname)  $expname $runname"
    end

    for wls in wlsvec
        runname = "w_$(@sprintf("%04.2f",wls))mps_fsf+00Wpm2_SST300.0K"
        nprm = prmdir("EnergeticvsMechanistic",schname,radname,expname,"$(runname).prm")
        open(tprm,"w") do fprm
            open(oprm,"r") do rprm
                s = read(rprm,String)
                s = replace(s,"[runname]" => runname)
                s = replace(s,"[sst]" => @sprintf("%5.1f",300))
                s = replace(s,"[bool]" => "true")
                s = replace(s,"[am]"  => @sprintf("%7e",wtgdmp))
                s = replace(s,"[tau]" => @sprintf("%7e",wtgrlx))
                s = replace(s,"[fluxt0]" => @sprintf("%7e",fluxt0(0,radname)))
                s = replace(s,"[fluxq0]" => @sprintf("%7e",fluxq0(0,radname)))
                write(fprm,s)
            end
        end
        mv(tprm,nprm,force=true)
        @info "Creating new prm file for EnergeticvsMechanistic $(schname) $(radname)  $expname $runname"
    end
    
end
