using DrWatson
@quickactivate "TroProVMo"
using Printf

include(srcdir("common.jl"))
include(srcdir("sam.jl"))

prjname = "WTGLargeScale"
radname = "P"
email   = ""
doBuild = true

wlsvec = vcat(-1:0.2:2); wlsvec = wlsvec[.!iszero.(wlsvec)]

mfid = open(runtemplatedir("modelrun.sh";prjname),"r"); str_m = read(mfid,String)
bfid = open(runtemplatedir("Build.csh";  prjname),"r"); str_b = read(bfid,String)

for wls in wlsvec
    runname = wlsname(wls)
    folname = rundir(schname,radname,runname;prjname)
    for imem = 1 : 5

        memberx = "member$(@sprintf("%02d",imem))"
        open(joinpath(folname,"$(memberx).sh"),"w") do wrun
            nstr_m = replace(str_m ,"[email]"   => email)
            nstr_m = replace(nstr_m,"[exproot]" => expdir(prjname))
            nstr_m = replace(nstr_m,"[schname]" => schname)
            nstr_m = replace(nstr_m,"[radname]" => radname)
            nstr_m = replace(nstr_m,"[runname]" => runname)
            nstr_m = replace(nstr_m,"[memberx]" => memberx)
            write(wrun,nstr_m)
        end

        if doBuild
            open(joinpath(folname,"Build.csh"),"w") do wrun
                nstr_b = replace(str_b ,"[datadir]" => datadir(prjname))
                nstr_b = replace(nstr_b,"[schname]" => schname)
                nstr_b = replace(nstr_b,"[radname]" => radname)
                nstr_b = replace(nstr_b,"[runname]" => runname)
                write(wrun,nstr_b)
            end
        end

    end
end

close(mfid)
close(bfid)