using DrWatson

expdir(args...) = joinpath(projectdir("exp"), args...)
prmdir(args...) = joinpath(projectdir("exp","prm"), args...)
lsfdir(args...) = joinpath(projectdir("exp","lsf"), args...)
snddir(args...) = joinpath(projectdir("exp","snd"), args...)

rundir(args...) = joinpath(projectdir("run"), args...)