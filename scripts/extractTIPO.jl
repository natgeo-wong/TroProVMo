using DrWatson
@quickactivate "TroProVMo"

using ERA5Reanalysis

addGeoRegions(srcdir("TropicalRegions.txt"))

sgeo = GeoRegion("TRP_IPO")
e5ds = ERA5Monthly(start=Date(1979),stop=Date(2021),path=datadir())
evar = SingleVariable("sst")
egeo = ERA5Region("TRP")

extract(sgeo,e5ds,evar,egeo)

plist = era5Pressures()
plist = plist[plist.>=10]; npre = length(plist)

for ipre in 1 : npre
    evar_w = PressureVariable("w",hPa=plist[ipre])
    extract(sgeo,e5ds,evar_w,egeo)
end