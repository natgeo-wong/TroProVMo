using DrWatson
@quickactivate "TroProVMo"

using Dates
using DifferentialEquations
using FFTW
using Logging
using LinearAlgebra
using NCDatasets
using SparseArrays

@info "$(now()) - TroProVMo - Internal gravity wave calculation"; flush(stderr)

# Constants
N2 = 0.01^2  # square of buoyancy frequency, in 1/second^2
L = 40e6     # horizontal domain size, in m
H = 20e3      # model top height, in m
T = 10 * 86400  # integration time, in seconds

# Grid settings
nx = 200; const nz = 400
dx = L / nx; dz = H / (nz + 1)
x = ((1:nx) .- 0.5) .* dx
z = (1:nz) .* dz
@info "$(now()) - TroProVMo - Domain is $(nx) in x by $(nz) in z"; flush(stderr)

# Heating definition
xscale = 1.e6    # in m
zscale = 1.5e3     
dosteady = true     # steady or transient heating

Qx = 1.e-4 .* exp.(-(x .- L/2).^2 ./ xscale^2)
Qk = fft(Qx)
# Qz = 1.0 .* sin.(pi .* min.(1, z ./ zscale))
Qz = z .< zscale

const Q = Qz * Qk'
Qri = reinterpret(Float64,Q)
const Qr = Qri[1:2:end,:]
const Qi = Qri[2:2:end,:]

# Laplacian matrix
e1 = ones(nz)
A = spdiagm(0 => -2*e1, 1 => ones(nz-1), -1 => ones(nz-1)) / dz^2
b = zeros(nz)
Ainv = inv(Matrix(A))

# Horizontal wavenumber
alfa = collect(0:nx-1) ./ L
alfa[alfa .> nx/2 ./ L] .-= nx / L
const alfac = alfa * 2 * π
const nalfa = nx ÷ 2 + 1
const npnts = nz * nalfa

@info "$(now()) - TroProVMo - Initializing Jacobian for computation ..."; flush(stderr)
# Jacobian computation
const Jacobian = zeros(nz*nalfa, nz*nalfa)
for i = 2:nalfa
    ioffset = nz * (i - 1)
    Jacobian[ioffset.+(1:nz), ioffset.+(1:nz)] = (alfac[i]^2) * (N2) .* Ainv
end
const JacobianT = sparse(Jacobian')

@info "$(now()) - TroProVMo - Setting up Initial Conditions and Forcings ..."; flush(stderr)
# Initial condition
y0 = zeros(2*nz*nalfa,2)
const forcing1 = zeros(npnts)
const forcing2 = zeros(npnts)
const tmpmat   = zeros(npnts)
for i = 2:nalfa
    ioffset = nz * (i - 1)
    forcing1[ioffset+1:ioffset+nz] = -(alfac[i]^2) .* Qr[:,i]
    forcing2[ioffset+1:ioffset+nz] = -(alfac[i]^2) .* Qi[:,i]
end

@info "$(now()) - TroProVMo - Defining ODE System of Equations ..."; flush(stderr)
function ode_fun!(dydt, y, p, t)
    (nza, J, forcinga, forcingb, tmpmat) = p
    dydt[1:nza,1] .= y[nza.+(1:nza),1]; dydt[nza.+(1:nza),1] .= forcinga
    dydt[1:nza,2] .= y[nza.+(1:nza),2]; dydt[nza.+(1:nza),2] .= forcingb
    mul!(tmpmat,J,view(y,1:nza,1)); dydt[nza.+(1:nza),1] .+= tmpmat
    mul!(tmpmat,J,view(y,1:nza,2)); dydt[nza.+(1:nza),2] .+= tmpmat
    return 
end

# Setup and solve the ODE
@info "$(now()) - TroProVMo - Solving the ODE computation ..."; flush(stderr)
prob = ODEProblem(ode_fun!, y0, (0.0, T), (npnts, JacobianT, forcing1, forcing2, tmpmat))
sol = solve(prob, alg_hints = [:stiff], reltol=1e-6, abstol=1e-10, saveat=3600)

w = zeros(nz,nx,length(sol.t))
buoy = zeros(nz,nx,length(sol.t))

fw = zeros(ComplexF64,nz,200)
fb = zeros(ComplexF64,nz,200)

@info "$(now()) - TroProVMo - Converting output from Fourier Space to Real Space ..."; flush(stderr)
for i in 1 : length(sol.t)

    fw[:,1:101] = reshape(sol.u[i][1:nz*nalfa,1], nz, nalfa) .+ im * reshape(sol.u[i][1:nz*nalfa,2], nz, nalfa)
    fb[:,1:101] = -reshape(sol.u[i][nz*nalfa+1:2*nz*nalfa,1], nz, nalfa) .- im * reshape(sol.u[i][nz*nalfa+1:2*nz*nalfa,2], nz, nalfa)
    fb[:,2:nalfa] = fb[:, 2:nalfa] ./ (alfac[2:nalfa] .^ 2)'  # Broadcasting operation

    for j in (nalfa+1):nx
        fw[:, j] = conj(fw[:, nx-j+2])
        fb[:, j] = conj(fb[:, nx-j+2])
    end

    # alfa=0 case handled differently
    for k in 1:nz
        fb[k, 1] = Qz[k]*Qk[1]  # Assuming getQt() and other necessary functions are adapted for Julia
    end
    
    w[:, :, i] = A \ real(ifft(fw, 2))  # Inverse FFT along the 2nd dimension
    buoy[:, :, i] = real(ifft(fb, 2))

end

fnc = datadir("gravitywave.nc")
if isfile(fnc); rm(fnc,force=true) end
ds = NCDataset(fnc,"c")

ds.dim["time"] = length(sol.t)
ds.dim["x"]    = nx
ds.dim["z"]    = nz

nct = defVar(ds,"t",Float64,("time",))
ncx = defVar(ds,"x",Float64,("x",))
ncz = defVar(ds,"z",Float64,("z",))
ncw = defVar(ds,"w",Float64,("z","x","time"))
ncb = defVar(ds,"b",Float64,("z","x","time"))

nct["t"][:] = sol.t
ncx["x"][:] = x
ncz["z"][:] = z
ncw["w"][:,:,:] = w
ncb["b"][:,:,:] = buoy

close(ds)