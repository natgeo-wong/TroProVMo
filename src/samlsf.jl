using DelimitedFiles
using NCDatasets
using Printf
using Statistics

include(srcdir("common.jl"))

function printlsf(
    flsf    :: AbstractString, 
    lsfdata :: Array{<:Real,2}, 
    p       :: Real;
    prjname :: String = ""
)

    file = lsfdir(flsf;prjname)
    fdir = dirname(file); if !isdir(fdir); mkpath(fdir); end

    nz = size(lsfdata,1)

    open(file,"w") do io
        @printf(io,"z[m] p[mb] tpls[K/s] qls[kg/kg/s] uls_hor[m/s] vls_hor[m/s] wls[m/s]\n")
    end

    open(file,"a") do io
        for t in [0.0,10000.0]
            @printf(io,"%10.2f, %10d, %10.2f\n",t,nz,p)
            for iz = 1 : nz
                @printf(
                    io,"%16.8f\t%16.8f\t%16.8f\t%16.8f\t%16.8f\t%16.8f\t%16.8f\n",
                    lsfdata[iz,1],lsfdata[iz,2],lsfdata[iz,3],lsfdata[iz,4],
                    lsfdata[iz,5],lsfdata[iz,6],lsfdata[iz,7]
                )
            end
        end
    end

end

function readlsf(lsfname::String; prjname::String="")
	
	flsf = lsfdir(lsfname;prjname)
	data = readdlm(flsf)
	data = data[2:end,:]; nrow = size(data,1)
	data = data[2:Int(nrow/2),:]
	
	z  = Float64.(data[:,1])
	p  = Float64.(data[:,2])
	pt = Float64.(data[:,3])
	q  = Float64.(data[:,4])
	u  = Float64.(data[:,5])
	v  = Float64.(data[:,6])
	w  = Float64.(data[:,7])
	
	return z,p,pt,q,u,v,w
	
end	