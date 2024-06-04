using Dates
using DrWatson
using Logging
using NCDatasets
using Printf
using Statistics
using Trapz

function createflist()

    wlsvec = vcat(0.1:0.1:5)/10; nw = length(wlsvec)
    # wlsvec = vcat(0.1:0.1:0.5,1:0.5,3)/10; nw = length(wlsvec)
    zdvec  = [2,5,10]; nzd = length(zdvec)
    flist = Array{String,2}(undef,nw,nzd)
    for izd in 1 : nzd, iw in 1 : nw
        flist[iw,izd] = "w$(@sprintf("%05.3f",wlsvec[iw]))mps_zdecay$(@sprintf("%02d",zdvec[izd]))km"
    end

    return wlsvec,zdvec,flist

end

function extractw(
    schname :: String,
    radname :: String,
    expname :: String;
    nt      :: Int = 2400,
    tperday :: Int = 24,
)

    wlsvec,zdvec,flist = createflist()
    nw = length(wlsvec); nz = length(zdvec)
    wwtg = zeros(64,nt,nw,nz) * NaN
    wobs = zeros(64,nt,nw,nz) * NaN
    wls  = zeros(64,nt,nw,nz) * NaN
    rho  = zeros(64,nt,nw,nz) * NaN
    z = zeros(64,nw,nz) * NaN
    p = zeros(64,nw,nz) * NaN
    t = 0 : nt
    t = collect(t[1:(end-1)] .+ t[2:end]) / 2
    t = t / tperday

    for iz in 1 : nz, iw in 1 : nw

        fnc = datadir(
            "DetrainmentDecay","$schname","$radname","$expname","OUT_STAT",
            "SAM_TroProVMo-DetrainmentDecay-$(flist[iw,iz]).nc"
        )
        if isfile(fnc)
            ods = NCDataset(fnc)
            try
                z[:,iw,iz] .= ods["z"][:]
                p[:,iw,iz] .= ods["p"][:]
                wwtg[:,:,iw,iz] .= ods["WWTG"][:,:]
                wobs[:,:,iw,iz] .= ods["WOBS"][:,:]
                wls[:,:,iw,iz] .= ods["WOBSREF"][:,:]
                rho[:,:,iw,iz] .= ods["RHO"][:,:]
            catch
                @warn "Unable to extract vertical velocity data from $(fnc)"
            end
            close(ods)
        else
            @warn "No file exists at $(fnc), please run this configuration again ..."
        end

    end

    nfol = datadir("DetrainmentDecay","w"); mkpath(nfol)
    fnc = joinpath(nfol,"$(schname)-$(radname)-$(expname)-wforcing.nc")
    if isfile(fnc); rm(fnc,force=true) end

    nds = NCDataset(fnc,"c",attrib = Dict(
        "Conventions" => "CF-1.6",
        "history"     => "Created on $(Dates.now()) using NCDatasets.jl",
        "comments"    => "Creating NetCDF files in the same format that data is saved on the Climate Data Store"
    ))

    nds.dim["time"] = nt
    nds.dim["level"] = 64
    nds.dim["wperturb"] = nw
    nds.dim["zdecay"] = nz

    nctime = defVar(nds,"time",Float64,("time",),attrib = Dict(
        "units"     => "days after model-day 0",
        "full_name" => "Day"
    ))

    ncz = defVar(nds,"z",Float64,("level",),attrib = Dict(
        "units"     => "m",
        "full_name" => "height"
    ))

    ncp = defVar(nds,"p",Float64,("level","wperturb","zdecay"),attrib = Dict(
        "units"     => "hPa",
        "full_name" => "pressure_level"
    ))

    ncw = defVar(nds,"wperturb",Float64,("wperturb",),attrib = Dict(
        "units"     => "m s**-1",
        "full_name" => "vertical_velocity_perturbation"
    ))

    nczd = defVar(nds,"zdecay",Float64,("zdecay",),attrib = Dict(
        "units"     => "m",
        "full_name" => "vertical_velocity_decay_height"
    ))

    ncwwtg = defVar(nds,"wwtg",Float64,("level","time","wperturb","zdecay"),attrib = Dict(
        "units"     => "m s**-1",
        "long_name" => "weak_temperature_gradient_vertical_velocity",
        "full_name" => "WTG Vertical Velocity"
    ))

    ncwobs = defVar(nds,"wobs",Float64,("level","time","wperturb","zdecay"),attrib = Dict(
        "units"     => "m s**-1",
        "long_name" => "total_observed_vertical_velocity",
        "full_name" => "Total Observed Vertical Velocity"
    ))

    ncwls = defVar(nds,"wls",Float64,("level","time","wperturb","zdecay"),attrib = Dict(
        "units"     => "m s**-1",
        "long_name" => "large_scale_vertical_velocity_forcing",
        "full_name" => "Large-Scale Vertical Velocity Forcing"
    ))

    ncωwtg = defVar(nds,"ωwtg",Float64,("level","time","wperturb","zdecay"),attrib = Dict(
        "units"     => "Pa s**-1",
        "long_name" => "weak_temperature_gradient_pressure_velocity",
        "full_name" => "WTG Pressure Velocity"
    ))

    ncωobs = defVar(nds,"ωobs",Float64,("level","time","wperturb","zdecay"),attrib = Dict(
        "units"     => "m s**-1",
        "long_name" => "total_observed_pressure_velocity",
        "full_name" => "Total Observed Pressure Velocity"
    ))

    ncωls = defVar(nds,"ωls",Float64,("level","time","wperturb","zdecay"),attrib = Dict(
        "units"     => "m s**-1",
        "long_name" => "large_scale_pressure_velocity_forcing",
        "full_name" => "Large-Scale Pressure Velocity Forcing"
    ))

    ncrho = defVar(nds,"ρ",Float64,("level","time","wperturb","zdecay"),attrib = Dict(
        "units"     => "m s**-1",
        "long_name" => "large_scale_pressure_velocity_forcing",
        "full_name" => "Large-Scale Pressure Velocity Forcing"
    ))

    nctime[:] = t
    ncz[:] = dropdims(mean(z,dims=(2,3)),dims=(2,3))
    ncp[:,:,:] = p
    ncw[:] = wlsvec
    nczd[:] = zdvec * 1000
    ncwwtg[:,:,:,:] = wwtg
    ncwobs[:,:,:,:] = wobs
    ncwls[:,:,:,:]  = wls
    ncωwtg[:,:,:,:] = - wwtg .* 9.81 .* rho
    ncωobs[:,:,:,:] = - wobs .* 9.81 .* rho
    ncωls[:,:,:,:]  = - wls  .* 9.81 .* rho
    ncrho[:,:,:,:]  = rho

    close(nds)

end