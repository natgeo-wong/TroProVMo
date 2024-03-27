using DrWatson

expdir(args...; prjname = "") = joinpath(projectdir("exp",prjname), args...)
rundir(args...; prjname = "") = joinpath(projectdir("run",prjname), args...)

prmdir(args...; prjname = "") = joinpath(expdir("prm"; prjname), args...)
lsfdir(args...; prjname = "") = joinpath(expdir("lsf"; prjname), args...)
snddir(args...; prjname = "") = joinpath(expdir("snd"; prjname), args...)

runtemplatedir(args...; prjname = "") = joinpath(rundir("runtemplates";prjname), args...)
prmtemplatedir(args...; prjname = "") = joinpath(rundir("prmtemplates";prjname), args...)