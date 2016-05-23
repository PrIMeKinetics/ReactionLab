function [rSpe,Tdot,rNet,rF,rR] = ri_pa(rPfr,t,yy)
% [rSpe,Tdot,rNet,rF,rR] = ri_pa(pfrObj,time,[concentrations T])
%
% run P=const, adiabatic kinetics

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1 $
% Last modified: February 14, 2010

rm = rPfr.RxnModel;
rDat = rm.rDat;
% dH = reshape([rDat.dH],length(rDat(1).dH),length(rDat))';
dH = rDat.dH;
cpp = rm.speData.Cp;
[nc,nSpe] = size(cpp);
[nRxn,mH] = size(dH);
mexx = rm.mex;

Tarray = yy(:,end);
lenTime = length(t);
rSpe = zeros(nSpe,lenTime);
rF   = zeros(nRxn,lenTime);  rR = rF;  rNet = rF;
Tdot = zeros(lenTime);
for i1 = 1:length(t)

   y = yy(i1,:)';

   [ydot,rNeti,rFi,rRi] = Codes.rxnrates(y,mexx.sForw,mexx.sRev,mexx.indRxn,...
                                           mexx.indArr,mexx.kArr,mexx.kPres,mexx.eqK);   

   c = y(1:end-1);
   rSpe(:,i1) = ydot(1:end-1,1);
   rF(:,i1) = rFi';
   rR(:,i1) = rRi';
   rNet(:,i1) = rNeti';
   
   T = Tarray(i1);
   
   cp = T.^((2-nc):1) * cpp;  % Cp(1xNspe)
   cp_tot = cp * c;

   Tdot(i1) = -(T.^((mH-1):-1:0) * dH' * rNeti) / cp_tot;

%    rSpe = ydot;
   rSpe(:,i1) = rSpe(:,i1) - c.* (Tdot(i1)/T + sum(rSpe(:,i1))/sum(c) );
   %ydot = [rSpe; Tdot];
   
end