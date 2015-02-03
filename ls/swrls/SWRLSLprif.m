function [y] = SWRLSLprif( u,d,e,L,N )
% SWRLSLprif - Sliding Window A Priori Error Feedback
%              Recursive Least Squares Lattice
%
% [y] = SWRLSLprif( u,d,e,L,N )
%
% u         - Input signal;
% d         - desired signal;
% e         - regularization factor (usually large);
% L         - memory length;
% N         - number of taps.
%
% y         - Output signal.
%
% (C) Bartosz Zator (braton@gmail.com)
% $Date: Jun-2006$
% $Revision: 03-Nov-2006$
%
% References:
% A.H. SAYED, "Fundamentals of Adaptive Filtering", John Wiley & Sons 2003
% ch. 11-15 
%
% K. ZHAO, F. LING, H. LEV-ARI, J.G. PROAKIS, "Sliding Window
% Order-Recursive Least-Squares Algorithms", IEEE Transactions
% On Signal Processing, vol. 42, no. 8, August 1994.
%

% Ensure row vectors ------------------------------------------------------
s=size(u); if s(1)>s(2), u=u.'; end
s=size(d); if s(1)>s(2), d=d.'; end
% Initialization ----------------------------------------------------------
uLen = length(u);
Pfd=e*ones(1,N);Pbu=Pfd;Pbd=Pfd;
gconvup=ones(1,N+1);gconvdp=gconvup;
kd=zeros(1,N);kbd=kd;kfd=kd;
bpriup=zeros(1,N+1);bpridp=bpriup;
y=zeros(1,uLen);
Pfu=zeros(1,N);Pbup=Pfd;Pbdp=Pfu;
fpriu=zeros(1,N+1);fprid=fpriu;bpriu=fpriu;bprid=fpriu;epriu=fpriu;
eprid=fpriu;gconvu=bpriu;gconvd=fpriu;
ku=zeros(1,N);kfu=ku;kbu=ku;
% Filtering ---------------------------------------------------------------
for i=1:uLen
    gconvd(1)=single(1);gconvu(1)=single(1);
    bprid(1)=(i-L+1>0)*u(max(i-L+1,1));bpriu(1)=u(i);
    fprid(1)=(i-L+1>0)*u(max(i-L+1,1));fpriu(1)=u(i);
    eprid(1)=(i-L+1>0)*d(max(i-L+1,1));epriu(1)=d(i);
    for m=1:N
        % Time Update
        Pfu(m)=Pfd(m)+abs(fpriu(m))^2*gconvup(m);
        Pfd(m)=Pfu(m)-abs(fprid(m))^2*gconvdp(m);
        Pbup(m)=Pbu(m);Pbu(m)=Pbd(m)+abs(bpriu(m))^2*gconvu(m);
        Pbdp(m)=Pbd(m);Pbd(m)=Pbu(m)-abs(bprid(m))^2*gconvd(m);
        % Order Update
        gconvu(m+1)=gconvu(m)-abs(gconvu(m)*bpriu(m))^2/Pbu(m);
        gconvd(m+1)=gconvd(m)+abs(gconvd(m)*bprid(m))^2/Pbd(m);
        epriu(m+1)=epriu(m)-kd(m)*bpriu(m);
        bpriu(m+1)=bpriup(m)-kbd(m)*fpriu(m);
        fpriu(m+1)=fpriu(m)-kfd(m)*bpriup(m);
        ku(m)=kd(m)+bpriu(m)'*gconvu(m)*epriu(m+1)/Pbu(m);
        kbu(m)=kbd(m)+fpriu(m)'*gconvup(m)*bpriu(m+1)/Pfu(m);
        kfu(m)=kfd(m)+bpriup(m)'*gconvup(m)*fpriu(m+1)/Pbup(m);
        eprid(m+1)=eprid(m)-ku(m)*bprid(m);
        bprid(m+1)=bpridp(m)-kbu(m)*fprid(m);
        fprid(m+1)=fprid(m)-kfu(m)*bpridp(m);
        kd(m)=ku(m)-bprid(m)'*gconvd(m)*eprid(m+1)/Pbd(m);
        kbd(m)=kbu(m)-fprid(m)'*gconvdp(m)*bprid(m+1)/Pfd(m);
        kfd(m)=kfu(m)-bpridp(m)'*gconvdp(m)*fprid(m+1)/Pbdp(m);
    end
    gconvdp=gconvd;gconvup=gconvu;
    bpridp=bprid;bpriup=bpriu;
    y(i)=d(i)-epriu(N+1);
end