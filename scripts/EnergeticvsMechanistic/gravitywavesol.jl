using DrWatson
@quickactivate "TroProVMo"

using ForwardDiff
using LinearAlgebra
using SparseArrays
using FFTW
using DifferentialEquations
using Interpolations

using PyCall, LaTeXStrings
pplt = pyimport("proplot")

# Demo for internal gravity wave

# Constants
N2 = 0.01^2  # square of buoyancy frequency, in 1/second^2
L = 40e6     # horizontal domain size, in m
H = 30e4      # model top height, in m
T = 100 * 86400  # integration time, in seconds

# Grid settings
nx = 200; nt = 120; nz = 600
dx = L / nx; dz = H / (nz + 1); dt = T / nt
x = ((1:nx) .- 0.5) .* dx
z = (1:nz) .* dz
t = (1:nt) .* dt

# Heating definition
xscale = 1.e6    # in m
zscale = 1.5e3     
dosteady = true     # steady or transient heating

Qx = 1.e-4 .* exp.(-(x .- L/2).^2 ./ xscale^2)
Qk = fft(Qx)
# Qz = 1.0 .* sin.(pi .* min.(1, z ./ zscale))
Qz = z .< zscale

Q = Qz * Qk'

# Laplacian matrix
e1 = ones(nz)
A = spdiagm(0 => -2*e1, 1 => ones(nz-1), -1 => ones(nz-1)) / dz^2
b = zeros(nz)

# Horizontal wavenumber
alfa = collect(0:nx-1) ./ L
alfa[alfa .> nx/2 ./ L] .-= nx / L
alfa *= 2 * π

nalfa = nx ÷ 2 + 1

# Jacobian computation
Jacobian = spzeros(nz*nalfa, nz*nalfa)
for i = 2:nalfa
    ioffset = nz * (i - 1)
    Jacobian[ioffset.+(1:nz), ioffset.+(1:nz)] = (alfa[i]^2) * (N2) .* inv(Matrix(A))
end
fullJacobian = spzeros(2*nz*nalfa, 2*nz*nalfa)
fullJacobian[nz*nalfa.+(1:nz*nalfa),1:(nz*nalfa)] .= Jacobian
fullJacobian[1:(nz*nalfa),nz*nalfa.+(1:nz*nalfa)] .= I(nz*nalfa)

# Initial condition
y0 = zeros(2*nz*nalfa,2)

# ODE system
function ode_fun!(dydt, y, p, t)
    (nalfa, nz, Jacobian, alfa, Qt) = p
    forcing1 = zeros(nz*nalfa)
    forcing2 = zeros(nz*nalfa)
    for i = 2:nalfa
        ioffset = nz * (i - 1)
        forcing1[ioffset+1:ioffset+nz] = -(alfa[i]^2) .* Qt[1:2:end,i]
        forcing2[ioffset+1:ioffset+nz] = -(alfa[i]^2) .* Qt[2:2:end,i]
    end
    dydt[1:nz*nalfa,1] = y[nz*nalfa+1:end,1]
    dydt[(nz*nalfa+1):end,1] = forcing1 + Jacobian * y[1:nz*nalfa,1]
    dydt[1:nz*nalfa,2] = y[nz*nalfa+1:end,2]
    dydt[(nz*nalfa+1):end,2] = forcing2 + Jacobian * y[1:nz*nalfa,2]
    return 
end

# Setup and solve the ODE

prob = ODEProblem(ode_fun!, y0, (0.0, T), (nalfa, nz, Jacobian, alfa, reinterpret(Float64,Q)))
sol = solve(prob, alg_hints = [:stiff], reltol=1e-6, abstol=1e-10, saveat=3600)

w = zeros(nz,nx,length(sol.t))
buoy = zeros(nz,nx,length(sol.t))

fw = zeros(ComplexF64,nz,200)
fb = zeros(ComplexF64,nz,200)

for i in 1 : length(sol.t)

    fw[:,1:101] = reshape(sol.u[i][1:nz*nalfa,1], nz, nalfa) .+ im * reshape(sol.u[i][1:nz*nalfa,2], nz, nalfa)
    fb[:,1:101] = -reshape(sol.u[i][nz*nalfa+1:2*nz*nalfa,1], nz, nalfa) .- im * reshape(sol.u[i][nz*nalfa+1:2*nz*nalfa,2], nz, nalfa)
    fb[:,2:nalfa] = fb[:, 2:nalfa] ./ (alfa[2:nalfa] .^ 2)'  # Broadcasting operation

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

