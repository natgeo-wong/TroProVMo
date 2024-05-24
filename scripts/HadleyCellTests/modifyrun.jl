using DrWatson
@quickactivate "TroProVMo"
using Printf

include(srcdir("common.jl"))
include(srcdir("sam.jl"))

prjname = "HadleyCellTests"
radname = "P"
email   = ""
doBuild = true

if schname == "DGW"
    wtgvec = [0,0.02,0.05,0.1,0.2,0.5,1,2,5,10,20,50]
else
    wtgvec = [sqrt(2),2,2*sqrt(2.5),5,5*sqrt(2)]
    wtgvec = vcat(0,wtgvec/10,1,wtgvec)
end
wlsvec = vcat(-1:0.2:2); wlsvec = wlsvec[.!iszero.(wlsvec)]

mfid = open(runtemplatedir("modelrun.sh";prjname),"r"); str_m = read(mfid,String)
bfid = open(runtemplatedir("Build.csh";  prjname),"r"); str_b = read(bfid,String)

for wls in wlsvec
    runname = wlsname(wls)

    folname = rundir("DE2019Advection",radname;prjname)
    open(joinpath(folname,"$(memberx).sh"),"w") do wrun
        nstr_m = replace(str_m ,"[email]"   => email)
        nstr_m = replace(nstr_m,"[time]"  => "1-12:00")
        nstr_m = replace(nstr_m,"[exproot]" => expdir(prjname))
        nstr_m = replace(nstr_m,"[expname]" => "DE2019Advection")
        nstr_m = replace(nstr_m,"[radname]" => radname)
        nstr_m = replace(nstr_m,"[runname]" => runname)
        write(wrun,nstr_m)
    end

    if doBuild
        open(joinpath(folname,"Build.csh"),"w") do wrun
            nstr_b = replace(str_b ,"[datadir]" => datadir(prjname))
            nstr_b = replace(nstr_b,"[expname]" => "DE2019Advection")
            nstr_b = replace(nstr_b,"[radname]" => radname)
            write(wrun,nstr_b)
        end
    end

    folname = rundir("FullSubsidence",radname;prjname)
    open(joinpath(folname,"$(memberx).sh"),"w") do wrun
        nstr_m = replace(str_m ,"[email]"   => email)
        nstr_m = replace(nstr_m,"[time]"  => "1-12:00")
        nstr_m = replace(nstr_m,"[exproot]" => expdir(prjname))
        nstr_m = replace(nstr_m,"[expname]" => "FullSubsidence")
        nstr_m = replace(nstr_m,"[radname]" => radname)
        nstr_m = replace(nstr_m,"[runname]" => runname)
        write(wrun,nstr_m)
    end

    if doBuild
        open(joinpath(folname,"Build.csh"),"w") do wrun
            nstr_b = replace(str_b ,"[datadir]" => datadir(prjname))
            nstr_b = replace(nstr_b,"[expname]" => "FullSubsidence")
            nstr_b = replace(nstr_b,"[radname]" => radname)
            write(wrun,nstr_b)
        end
    end

end

close(mfid)
close(bfid)