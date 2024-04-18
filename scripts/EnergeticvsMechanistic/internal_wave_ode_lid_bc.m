%Demo for internal gravity wave
%function internal_wave_ode
clear all
%close all
N2=0.01^2;  %in 1/second^2, square of buoyancy frequency
L=40e6;     %in m, horizontal domain size
H=3e4;      %in m, model top height
T=2*86400;  %in seconds, integration time

%choose the number of grid points to use
nx=200;nt=120;nz=29;
%define grid. In z, we assume rigid lids at 0 and H
dx=L/nx;dz=H/(nz+1);dt=T/nt;
x=((0:nx-1)'+0.5)*dx;
z=((1:nz)')*dz;
t=(1:nt)'*dt;

%define heating
xscale=1.e6;    %in m
zscale=H;     
dosteady=0;     %steady or transient heating

%Gaussian shaped heating in x
Qx=1.e-4*exp(-(x-L/2).^2/(xscale)^2);

%Fourier transform in the x direction of the heating
Qk=fft(Qx);

%vertical structure of the heating. Feel free to use your own shape
Qz=1.*sin(pi*min(1,z/zscale))+0.*sin(2*pi*min(1,z/zscale));

%full 2-dimensional structure
Q=Qz*Qk.';

%make the Laplacian matrix
e1=ones(nz,1); % build a vector of ones
A=spdiags([e1 -2*e1 e1],[-1 0 1],nz,nz)/dz^2; %build the Laplacian matrix with diagonals
b=zeros(nz,1); %boundary  condition

%define horizontal wavenumber alfa
alfa=(0:nx-1)/L;
subs=find(alfa>nx/2/L);
alfa(subs)=alfa(subs)-nx/L;
alfa=2*pi*alfa;

%Given the symmetry in the Fourier transform, only do half of wavenumbers
%,the other half can be filled with complex conjugates
nalfa=nx/2+1;

%compute the Jacobian, which makes the implicit solver much more efficient
for i=2:nalfa
    ioffset=nz*(i-1);
    Jacobian(ioffset+(1:nz),ioffset+(1:nz))=(alfa(i)^2)*(N2)*inv(A);
end
fullJacobian(nz*nalfa+(1:nz*nalfa),1:nz*nalfa)=Jacobian;
fullJacobian(1:nz*nalfa,nz*nalfa+(1:nz*nalfa))=eye(nz*nalfa);

%Initial condition
y0=zeros(2*nz*nalfa,1);
%integrate using the ode solver
opts=odeset('reltol',1.e-4,'abstol',1.e-10,'Jacobian',fullJacobian);
[ode_time,ode_y]=ode23s(@(t,y) ode_fun(t,y,nalfa,nz,Jacobian,alfa,Q,dosteady),[0 T],y0,opts);

%interpolate the solution to regular time grid for display purpose
for i=1:size(ode_y,2)
    ode_y2d(:,i)=interp1(ode_time,ode_y(:,i),t);
end

%Inverse Fourier Transform to the real spatial domain 
for i=1:size(t)
    fw=reshape(ode_y2d(i,1:nz*nalfa),[nz nalfa]);
    fb=-reshape(ode_y2d(i,nz*nalfa+(1:nz*nalfa)),[nz nalfa]);
    fb(:,2:nalfa)=fb(:,2:nalfa)./repmat(alfa(2:nalfa).^2,[nz 1]);
    
    for j=nalfa+1:nx
        fw(:,j)=conj(fw(:,nx-j+2));
        fb(:,j)=conj(fb(:,nx-j+2));
    end
    %alfa=0 case needs to be treated differently as buoyancy will have 0/0.
    for k=1:nz
        fb(k,1)=integral(@(t) getQt(t,Qz(k)*Qk(1),dosteady),0,t(i));    
    end
    w(:,:,i)=A\real(ifft(fw,[],2));
    buoy(:,:,i)=real(ifft(fb,[],2));
end

%output
for i=2:numel(t)
    subplot(2,1,1)
    contourf((x-L/2)/1e6,z/1e3,w(:,:,i),0.1*[-15.5:1:15.5]);
    set(gca,'clim',[-1. 1.])
    ylabel('Z (km)')
    xlabel('X (1000km)')
    title(['Vertical velocity at hour ',num2str(t(i)/3600)]);
    colorbar
    subplot(2,1,2)
    contourf((x-L/2)/1e6,z/1e3,buoy(:,:,i),0.1*[-15.5:1:15.5]);
    set(gca,'clim',[-1 1])
    ylabel('Z (km)')
    xlabel('X (1000km)')
    title(['Buoyancy at hour ',num2str(t(i)/3600)]);
    colorbar
    
    pause(0.05);
    
end

%Define heating as a function of time
function Qt=getQt(t,Qz,dosteady)
    if(dosteady)
        Qt=Qz*ones(size(t)); %steady forcing
    else
        duration=86400./2; %heat over half a day
        %multiply the fourier components of foricng by a time varying component
        Qt=Qz*sin(pi*min(1,max(0,t)/duration));
    end
    return,Qt;
end

%the right hand of the 1st order initial value ODE system
function dydt=ode_fun(t,y,nalfa,nz,Jacobian,alfa,Q,dosteady)
    Qt=getQt(t,Q,dosteady);
    for i=2:nalfa
        ioffset=nz*(i-1);
        forcing(ioffset+(1:nz),1)=-(alfa(i)^2)*Qt(:,i);
    end
    dydt=y;
    dydt(1:nz*nalfa)=y(nz*nalfa+(1:nz*nalfa));
    %The Jacobian here solves the boundary value ode problem
    dydt(nz*nalfa+(1:nz*nalfa))=forcing+Jacobian*y(1:nz*nalfa);
    return,dydt;
end
