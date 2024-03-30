using DrWatson
@quickactivate "TroProVMo"
using Logging
using Printf

include(srcdir("common.jl"))
include(srcdir("sam.jl"))

prjname = "WTGLargeScale"
schname = "DGW"
radname = "P"

if schname == "DGW"
    wtgvec = [0,0.02,0.05,0.1,0.2,0.5,1,2,5,10,20,50]
else
    wtgvec = [sqrt(2),2,2*sqrt(2.5),5,5*sqrt(2)]
    wtgvec = vcat(0,wtgvec/10,1,wtgvec)
end
wlsvec = vcat(-1:0.2:2); wlsvec = wlsvec[.!iszero.(wlsvec)]

oprm = rundir("prmtemplates",schname,"$(radname).prm";prjname)

for wls in wlsvec

    expname = wlsname(wls)
    folname = prmdir(schname,radname,expname;prjname); mkpath(folname)

    for wtgii in wtgvec

        if !iszero(wtgii)

            if schname == "DGW"
                  wtgdmp = wtgii; wtgrlx = 1
            else; wtgrlx = wtgii; wtgdmp = 1
            end

            pwrname = powername(wtgii,schname)
            open(joinpath(folname,"$(pwrname).prm"),"w") do fprm
                open(oprm,"r") do rprm
                    s = read(rprm,String)
                    s = replace(s,"[expname]" => expname)
                    s = replace(s,"[runname]" => pwrname)
                    s = replace(s,"[wtgbool]" => "true")
                    s = replace(s,"[am]"      => @sprintf("%7e",wtgdmp))
                    s = replace(s,"[tau]"     => @sprintf("%7e",wtgrlx))
                    write(fprm,s)
                end
            end
            @info "Creating new prm file for $prjname $schname $radname $expname $pwrname"

        else

            for imem = 1 : 5
                memberx = "member$(@sprintf("%02d",imem))"
                open(joinpath(folname,"$(memberx).prm"),"w") do fprm
                    open(oprm,"r") do rprm
                        s = read(rprm,String)
                        s = replace(s,"[expname]" => expname)
                        s = replace(s,"[runname]" => memberx)
                        s = replace(s,"[wtgbool]" => "false")
                        s = replace(s,"[am]"      => @sprintf("%7e",1))
                        s = replace(s,"[tau]"     => @sprintf("%7e",1))
                        write(fprm,s)
                    end
                end
                @info "Creating new prm file for $prjname $schname $radname $expname ensemble member $imem"
            end

        end

    end

end
