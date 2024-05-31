using DrWatson
@quickactivate "TroProVMo"

include(srcdir("sam.jl"))
include(srcdir("extractw_DD.jl"))

schname = "DGW"
radname = "P"

if schname == "DGW"
    pwrvec = [0.01,0.02,0.05,0.1,0.2]
else
    pwrvec = [0.2,0.5,1,2]
end

for pwr in pwrvec
    pwrname = powername(pwr,schname)
    extractw(schname,radname,pwrname,nt=2400,tperday=24,doSST=true)
    extractw(schname,radname,pwrname,nt=2400,tperday=24,doSST=false)
    extractw(schname,"$(radname)_FSF",pwrname,nt=2400,tperday=24,doSST=false)
end