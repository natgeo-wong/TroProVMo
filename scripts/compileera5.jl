using DrWatson
@quickactivate "TroProVMo"

using ERA5Reanalysis

addGeoRegions(srcdir("TropicalRegions.txt"))

e5ds = ERA5Monthly(start=Date(1979),stop=Date(2021),path=datadir())
egeo = ERA5Region("TRP_IPO")
elsd = getLandSea(e5ds,egeo)
nlon = length(elsd.lon)
nlat = length(elsd.lat)
plist = era5Pressures()
plist = plist[plist.>=10]; npre = length(plist)

evar_sst = SingleVariable("sst")
evar_w   = Vector{PressureVariable}(undef,npre)
for ipre in 1 : npre
    evar_w[ipre] = PressureVariable("w",hPa=plist[ipre])
end

w = zeros(nlon,nlat,12,npre)
sst = zeros(nlon,nlat,12)

for dt in e5ds.start : Year(1) : e5ds.stop

    ds = read(e5ds,evar_sst,egeo,dt)
    sst[:,:,:] += nomissing(ds[evar_sst.ID][:,:,:],NaN)
    close(ds)

    for ipre in 1 : npre
        ds = read(e5ds,evar_w[ipre],egeo,dt)
        w[:,:,:,ipre] += ds[evar_w[ipre].ID][:,:,:]
        close(ds)
    end

end

sst ./= (year(e5ds.stop)-year(e5ds.start)+1)
w   ./= (year(e5ds.stop)-year(e5ds.start)+1)

fnc = datadir("compile-$(egeo.string)-sstw.nc")
if isfile(fnc); rm(fnc,force=true) end
eds = NCDataset(fnc,"c")

eds.dim["longitude"] = nlon
eds.dim["latitude"]  = nlat
eds.dim["month"]     = 12
eds.dim["level"]     = npre

nclon = defVar(eds,"longitude",Float32,("longitude",),attrib = Dict(
    "units"     => "degrees_east",
    "long_name" => "longitude",
))

nclat = defVar(eds,"latitude",Float32,("latitude",),attrib = Dict(
    "units"     => "degrees_north",
    "long_name" => "latitude",
))

ncsst = defVar(eds,evar_sst.ID,Float64,("longitude","latitude","month"),attrib = Dict(
    "long_name"     => evar_sst.long,
    "full_name"     => evar_sst.name,
    "units"         => evar_sst.units,
))

ncw = defVar(eds,evar_w[1].ID,Float64,("longitude","latitude","month","level"),attrib = Dict(
    "long_name"     => evar_w[1].long,
    "full_name"     => evar_w[1].name,
    "units"         => evar_w[1].units,
))

nclon[:] = elsd.lon
nclat[:] = elsd.lat
ncsst[:,:,:] = sst
ncw[:,:,:,:] = w

close(eds)
