using Dates
using DrWatson
using Logging
using NCDatasets
using Printf
using Statistics
using Trapz

function createsstlist()

    sstvec = 300 : 0.1 : 305; sstvec = sstvec[2:end]; nsst = length(sstvec)
    sstlist = Vector{String}(undef,nsst)
    for isst in 1 : nsst
        sstlist[isst] = "SST$(@sprintf("%5.1f",sstvec[isst]))K"
    end

    return sstvec,sstlist

end

function createwlist()

    wvec = vcat(0:0.02:1)/10; wvec = wvec[2:end]; nw = length(wvec)
    wlist = Vector{String}(undef,nw)
    for iw in 1 : nw
        wlist[iw] = "w_$(@sprintf("%05.3f",wvec[iw]))mps"
    end

    return wvec,wlist

end

function extractw(
    schname :: String,
    radname :: String,
    expname :: String;
    doSST   :: Bool = true,
    nt      :: Int = 2400,
    tperday :: Int = 24,
)

    if !doSST
        members,nclist = createwlist()
    else
        members,nclist = createsstlist() 
    end
    nnc = length(nclist)
    wwtg = zeros(64,nt,nnc) * NaN
    wobs = zeros(64,nt,nnc) * NaN
    wls  = zeros(64,nt,nnc) * NaN
    rho  = zeros(64,nt,nnc) * NaN
    z = zeros(64,nnc) * NaN
    p = zeros(64,nnc) * NaN
    t = 0 : nt
    t = collect(t[1:(end-1)] .+ t[2:end]) / 2
    t = t / tperday

    for ids = 1 : nnc

        fnc = datadir(
            "EnergeticvsMechanistic","$schname","$radname","$expname","OUT_STAT",
            "SAM_TroProVMo-EnergeticvsMechanistic-$(nclist[ids]).nc"
        )
        if isfile(fnc)
            ods = NCDataset(fnc)
            try
                z[:,ids] .= ods["z"][:]
                p[:,ids] .= ods["p"][:]
                wwtg[:,:,ids] .= ods["WWTG"][:,:]
                wobs[:,:,ids] .= ods["WOBS"][:,:]
                wls[:,:,ids] .= ods["WOBSREF"][:,:]
                rho[:,:,ids] .= ods["RHO"][:,:]
            catch
                @warn "Unable to extract vertical velocity data from $(fnc)"
            end
            close(ods)
        else
            @warn "No file exists at $(fnc), please run this configuration again ..."
        end

    end

    nfol = datadir("EnergeticvsMechanistic","w"); mkpath(nfol)
    if !doSST
        fnc = joinpath(nfol,"$(schname)-$(radname)-$(expname)-wforcing.nc")
    else
        fnc = joinpath(nfol,"$(schname)-$(radname)-$(expname)-sstforcing.nc")
    end
    if isfile(fnc); rm(fnc,force=true) end

    nds = NCDataset(fnc,"c",attrib = Dict(
        "Conventions" => "CF-1.6",
        "history"     => "Created on $(Dates.now()) using NCDatasets.jl",
        "comments"    => "Creating NetCDF files in the same format that data is saved on the Climate Data Store"
    ))

    nds.dim["time"] = nt
    nds.dim["level"] = 64
    nds.dim["member"] = nnc

    nctime = defVar(nds,"time",Float64,("time",),attrib = Dict(
        "units"     => "days after model-day 0",
        "full_name" => "Day"
    ))

    ncz = defVar(nds,"z",Float64,("level",),attrib = Dict(
        "units"     => "m",
        "full_name" => "height"
    ))

    ncp = defVar(nds,"p",Float64,("level","member"),attrib = Dict(
        "units"     => "hPa",
        "full_name" => "pressure_level"
    ))

    ncmem = defVar(nds,"member",Float64,("member",),)

    ncwwtg = defVar(nds,"wwtg",Float64,("level","time","member"),attrib = Dict(
        "units"     => "m s**-1",
        "long_name" => "weak_temperature_gradient_vertical_velocity",
        "full_name" => "WTG Vertical Velocity"
    ))

    ncwobs = defVar(nds,"wobs",Float64,("level","time","member"),attrib = Dict(
        "units"     => "m s**-1",
        "long_name" => "total_observed_vertical_velocity",
        "full_name" => "Total Observed Vertical Velocity"
    ))

    ncwls = defVar(nds,"wls",Float64,("level","time","member"),attrib = Dict(
        "units"     => "m s**-1",
        "long_name" => "large_scale_vertical_velocity_forcing",
        "full_name" => "Large-Scale Vertical Velocity Forcing"
    ))

    ncωwtg = defVar(nds,"ωwtg",Float64,("level","time","member"),attrib = Dict(
        "units"     => "Pa s**-1",
        "long_name" => "weak_temperature_gradient_pressure_velocity",
        "full_name" => "WTG Pressure Velocity"
    ))

    ncωobs = defVar(nds,"ωobs",Float64,("level","time","member"),attrib = Dict(
        "units"     => "m s**-1",
        "long_name" => "total_observed_pressure_velocity",
        "full_name" => "Total Observed Pressure Velocity"
    ))

    ncωls = defVar(nds,"ωls",Float64,("level","time","member"),attrib = Dict(
        "units"     => "m s**-1",
        "long_name" => "large_scale_pressure_velocity_forcing",
        "full_name" => "Large-Scale Pressure Velocity Forcing"
    ))

    ncrho = defVar(nds,"ρ",Float64,("level","time","member"),attrib = Dict(
        "units"     => "m s**-1",
        "long_name" => "large_scale_pressure_velocity_forcing",
        "full_name" => "Large-Scale Pressure Velocity Forcing"
    ))

    nctime[:] = t
    ncz[:] = dropdims(mean(z,dims=2),dims=2)
    ncp[:] = p
    ncmem[:] = members
    ncwwtg[:,:,:] = wwtg
    ncwobs[:,:,:] = wobs
    ncwls[:,:,:]  = wls
    ncωwtg[:,:,:] = - wwtg .* 9.81 .* rho
    ncωobs[:,:,:] = - wobs .* 9.81 .* rho
    ncωls[:,:,:]  = - wls  .* 9.81 .* rho
    ncrho[:,:,:]  = rho

    close(nds)


end

function extractw(
    schname :: String,
    radname :: String,
    expname :: String;
    doSST   :: Bool = true,
    nt      :: Int = 2400,
    tperday :: Int = 24,
)

    if !doSST
        members,nclist = createwlist()
    else
        members,nclist = createsstlist() 
    end
    nnc = length(nclist)
    wwtg = zeros(64,nt,nnc) * NaN
    wobs = zeros(64,nt,nnc) * NaN
    wls  = zeros(64,nt,nnc) * NaN
    rho  = zeros(64,nt,nnc) * NaN
    z = zeros(64,nnc) * NaN
    p = zeros(64,nnc) * NaN
    t = 0 : nt
    t = collect(t[1:(end-1)] .+ t[2:end]) / 2
    t = t / tperday

    for ids = 1 : nnc

        fnc = datadir(
            "EnergeticvsMechanistic","$schname","$radname","$expname","OUT_STAT",
            "SAM_TroProVMo-EnergeticvsMechanistic-$(nclist[ids]).nc"
        )
        if isfile(fnc)
            ods = NCDataset(fnc)
            try
                z[:,ids] .= ods["z"][:]
                p[:,ids] .= ods["p"][:]
                wwtg[:,:,ids] .= ods["WWTG"][:,:]
                wobs[:,:,ids] .= ods["WOBS"][:,:]
                wls[:,:,ids] .= ods["WOBSREF"][:,:]
                rho[:,:,ids] .= ods["RHO"][:,:]
            catch
                @warn "Unable to extract vertical velocity data from $(fnc)"
            end
            close(ods)
        else
            @warn "No file exists at $(fnc), please run this configuration again ..."
        end

    end

    nfol = datadir("EnergeticvsMechanistic","w"); mkpath(nfol)
    if !doSST
        fnc = joinpath(nfol,"$(schname)-$(radname)-$(expname)-wforcing.nc")
    else
        fnc = joinpath(nfol,"$(schname)-$(radname)-$(expname)-sstforcing.nc")
    end
    if isfile(fnc); rm(fnc,force=true) end

    nds = NCDataset(fnc,"c",attrib = Dict(
        "Conventions" => "CF-1.6",
        "history"     => "Created on $(Dates.now()) using NCDatasets.jl",
        "comments"    => "Creating NetCDF files in the same format that data is saved on the Climate Data Store"
    ))

    nds.dim["time"] = nt
    nds.dim["level"] = 64
    nds.dim["member"] = nnc

    nctime = defVar(nds,"time",Float64,("time",),attrib = Dict(
        "units"     => "days after model-day 0",
        "full_name" => "Day"
    ))

    ncz = defVar(nds,"z",Float64,("level",),attrib = Dict(
        "units"     => "m",
        "full_name" => "height"
    ))

    ncp = defVar(nds,"p",Float64,("level","member"),attrib = Dict(
        "units"     => "hPa",
        "full_name" => "pressure_level"
    ))

    ncmem = defVar(nds,"member",Float64,("member",),)

    ncwwtg = defVar(nds,"wwtg",Float64,("level","time","member"),attrib = Dict(
        "units"     => "m s**-1",
        "long_name" => "weak_temperature_gradient_vertical_velocity",
        "full_name" => "WTG Vertical Velocity"
    ))

    ncwobs = defVar(nds,"wobs",Float64,("level","time","member"),attrib = Dict(
        "units"     => "m s**-1",
        "long_name" => "total_observed_vertical_velocity",
        "full_name" => "Total Observed Vertical Velocity"
    ))

    ncwls = defVar(nds,"wls",Float64,("level","time","member"),attrib = Dict(
        "units"     => "m s**-1",
        "long_name" => "large_scale_vertical_velocity_forcing",
        "full_name" => "Large-Scale Vertical Velocity Forcing"
    ))

    ncωwtg = defVar(nds,"ωwtg",Float64,("level","time","member"),attrib = Dict(
        "units"     => "Pa s**-1",
        "long_name" => "weak_temperature_gradient_pressure_velocity",
        "full_name" => "WTG Pressure Velocity"
    ))

    ncωobs = defVar(nds,"ωobs",Float64,("level","time","member"),attrib = Dict(
        "units"     => "m s**-1",
        "long_name" => "total_observed_pressure_velocity",
        "full_name" => "Total Observed Pressure Velocity"
    ))

    ncωls = defVar(nds,"ωls",Float64,("level","time","member"),attrib = Dict(
        "units"     => "m s**-1",
        "long_name" => "large_scale_pressure_velocity_forcing",
        "full_name" => "Large-Scale Pressure Velocity Forcing"
    ))

    ncrho = defVar(nds,"ρ",Float64,("level","time","member"),attrib = Dict(
        "units"     => "m s**-1",
        "long_name" => "large_scale_pressure_velocity_forcing",
        "full_name" => "Large-Scale Pressure Velocity Forcing"
    ))

    nctime[:] = t
    ncz[:] = dropdims(mean(z,dims=2),dims=2)
    ncp[:] = p
    ncmem[:] = members
    ncwwtg[:,:,:] = wwtg
    ncwobs[:,:,:] = wobs
    ncwls[:,:,:]  = wls
    ncωwtg[:,:,:] = - wwtg .* 9.81 .* rho
    ncωobs[:,:,:] = - wobs .* 9.81 .* rho
    ncωls[:,:,:]  = - wls  .* 9.81 .* rho
    ncrho[:,:,:]  = rho

    close(nds)


end