using DrWatson
@quickactivate "TroProVMo"
using Printf

include(srcdir("sam.jl"))

email = ""

expinit = "P"
wtgvec  = [0.1,sqrt(2)/10,0.2,sqrt(2.5)/5,0.5,sqrt(2)/2,1]
sstvec  = vcat(295:299,299.5,300,300.5,301:305)

mrun = projectdir("run","modifysam","runtemplates","modelrun.sh")
brun = projectdir("run","modifysam","runtemplates","Build.csh")

open(mrun,"r") do frun
    s = read(frun,String)
    for wtgii in wtgvec, sst in sstvec
        
        expname = "$(expinit)$(dampingstrprnt(wtgii))"
        runname = "$(@sprintf("%5.1f",sst))"

        for ensembleii in 1 : 5

            mstr = @sprintf("%d",ensembleii)
            nrun = projectdir("run","DGW",expname,runname,"ensemble$(mstr).sh")

            open(nrun,"w") do wrun
                sn = replace(s ,"[email]"    => email)
                sn = replace(sn,"[project]"  => projectdir())
                sn = replace(sn,"[expname]"  => expname)
                sn = replace(sn,"[runname]"  => runname)
                sn = replace(sn,"[sndname]"  => "$(expinit)")
                sn = replace(sn,"[lsfname]"  => "noforcing")
                sn = replace(sn,"[schname]"  => "DGW")
                sn = replace(sn,"[memberx]" => "member$(mstr)")
                write(wrun,sn)
            end

        end

    end
end

open(brun,"r") do frun
    s = read(frun,String)
    for wtgii in wtgvec, sst in sstvec
        
        expname = "$(expinit)$(dampingstrprnt(wtgii))"
        runname = "$(@sprintf("%5.1f",sst))"
        nrun = projectdir("run","DGW",expname,runname,"Build.csh")

        open(nrun,"w") do wrun
            sn = replace(s ,"[datadir]" => datadir())
            sn = replace(sn,"[schname]" => "DGW")
            sn = replace(sn,"[expname]" => expname)
            sn = replace(sn,"[runname]" => runname)
            write(wrun,sn)
        end

    end
end