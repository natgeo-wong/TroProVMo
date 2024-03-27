using DelimitedFiles
using NCDatasets
using Printf
using Statistics

include(srcdir("common.jl"))

function printsnd(
    fsnd    :: AbstractString, 
    snddata :: Array{<:Real,2}, 
    p       :: Real;
    prjname :: String = ""
)

    file = snddir(fsnd;prjname)
    fdir = dirname(file); if !isdir(fdir); mkpath(fdir); end

    nz = size(snddata,1)

    open(file,"w") do io
        @printf(io,"      z[m]      p[mb]      tp[K]    q[g/kg]     u[m/s]     v[m/s]\n")
    end

    open(file,"a") do io
        for t in [0.0,10000.0]
            @printf(io,"%10.2f, %10d, %10.2f\n",t,nz,p)
            for iz = 1 : nz
                @printf(
                    io,"%16.8f\t%16.8f\t%16.8f\t%16.8f\t%16.8f\t%16.8f\n",
                    snddata[iz,1],snddata[iz,2],snddata[iz,3],
                    snddata[iz,4],snddata[iz,5],snddata[iz,6]
                )
            end
        end
    end

end

function readsnd(sndname::String; prjname::String="")
	
	fsnd = snddir(sndname;prjname)
	data = readdlm(fsnd)
	data = data[2:end,:]; nrow = size(data,1)
	data = data[2:Int(nrow/2),:]
	
	z  = Float64.(data[:,1])
	p  = Float64.(data[:,2])
	pt = Float64.(data[:,3])
	q  = Float64.(data[:,4])
	u  = Float64.(data[:,5])
	v  = Float64.(data[:,6])
	
	return z,p,pt,q,u,v
	
end	