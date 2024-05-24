using NCDatasets
using Printf
using Statistics
using Trapz

dampingstrprnt(am::Real)     = replace(   "damping$(@sprintf("%06.2f",am ))")
relaxscalestrprnt(tau::Real) = replace("relaxscale$(@sprintf("%06.2f",tau))")

function powername(
    power  :: Real,
    scheme :: AbstractString
)

    if scheme == "DGW"
        return dampingstrprnt(power)
    else
        return relaxscalestrprnt(power)
    end

end

function wlsname(
    wls :: Real
)

    if wls > 0
        return "uplift$(@sprintf("%4.2f",abs(wls)))e-2"
    elseif wls < 0
        return "subside$(@sprintf("%4.2f",abs(wls)))e-2"
    else
        return "neutral$(@sprintf("%4.2f",0))e-2"
    end

end

function fluxtq0(scheme :: AbstractString)

    if scheme == "P_FSF"
        return [10.,90.]
    elseif scheme == "T_FSF"
        return [20.,120.]
    else # for non fixed-surface fluxes, dummy vector of ones
        return [1.,1.]
    end

end

function fluxt0(
    flux   :: Real,
    scheme :: AbstractString
)

    fluxt,fluxq = fluxtq0(scheme)
    return fluxt * (1 + flux / (fluxt+fluxq))

end

function fluxq0(
    flux   :: Real,
    scheme :: AbstractString
)

    fluxt,fluxq = fluxtq0(scheme)
    return fluxq * (1 + flux / (fluxt+fluxq))

end

function outstatname(
    prjname :: AbstractString,
    schname :: AbstractString,
    radname :: AbstractString,
    expname :: AbstractString,
    runname :: AbstractString,
)

    fnc = datadir(
        prjname,schname,radname,expname,"OUT_STAT",
        "SAM_TroProVMo-$(prjname)-$(expname)-$runname.nc"
    )

    return fnc

end

function retrievedims(
    prjname :: AbstractString,
    schname :: AbstractString,
    radname :: AbstractString,
    expname :: AbstractString,
    runname :: AbstractString,
)

    ds = NCDataset(outstatname(prjname,schname,radname,expname,runname))
    z = ds["z"][:]
    p = ds["p"][:]
    t = ds["time"][:]
    close(ds)

    return z,p,t

end

function retrievedims_fnc(fnc::AbstractString)

    rce = NCDataset(fnc)
    z = rce["z"][:]
    p = rce["p"][:]
    t = rce["time"][:]
    close(rce)

    return z,p,t

end

function retrieve2Dvar(
    varname :: AbstractString,
    prjname :: AbstractString,
    schname :: AbstractString,
    radname :: AbstractString,
    expname :: AbstractString,
    runname :: AbstractString,
)

    ds = NCDataset(outstatname(prjname,schname,radname,expname,runname))
    var = ds[varname][:]
    close(ds)

    return var

end

function retrieve2Dvar_fnc(varname::AbstractString, fnc::AbstractString)

    ds = NCDataset(fnc)
    var = ds[varname][:]
    close(ds)

    return var

end

function retrieve3Dvar(
    varname :: AbstractString,
    prjname :: AbstractString,
    schname :: AbstractString,
    radname :: AbstractString,
    expname :: AbstractString,
    runname :: AbstractString,
)

    ds = NCDataset(outstatname(prjname,schname,radname,expname,runname))
    var = ds[varname][:,:]
    close(ds)

    return var

end

function retrieve3Dvar_fnc(varname::AbstractString, fnc::AbstractString)

    ds = NCDataset(fnc)
    var = ds[varname][:,:]
    close(ds)

    return var

end

function calcrh(QV,TAIR,P)

    RH = zeros(size(QV)); np = size(RH,1); nt = size(RH,2)

    for it = 1 : nt, ip = 1 : np
    	RH[ip,it] = QV[ip,it] / tair2qsat(TAIR[ip,it],P[ip]*100)
    end

    return RH

end

function tair2qsat(T,P)

    tb = T - 273.15
    if tb <= 0
    	esat = exp(43.494 - 6545.8/(tb+278)) / (tb+868)^2
    else
    	esat = exp(34.494 - 4924.99/(tb+237.1)) / (tb+105)^1.57
    end


    r = 0.622 * esat / max(esat,P-esat)
    return r / (1+r)

end

function calcswp(RH,QV,P)

	pvec = vcat(0,reverse(P)) * 100; nt = size(RH,2)
	QVsat = zeros(length(pvec))
	swp = zeros(nt)

    for it = 1 : nt
		QVsat[2:end] .= reverse(QV[:,it]) ./ reverse(RH[:,it])
		swp[it] = trapz(pvec,QVsat) / 9.81 / 1000
    end

	return swp

end

function t2d(t::Vector{<:Real}, days::Integer)

    tstep = round(Integer,(length(t)-1)/(t[end]-t[1]))
    t = mod.(t[(end-tstep+1):end],1); tmin = argmin(t)
    tshift = tstep-tmin+1; t = circshift(t,tshift)
    t = vcat(t[end]-1,t,t[1]+1)
    beg = days*tstep - 1

    return t*tstep,tstep,tshift,beg

end
