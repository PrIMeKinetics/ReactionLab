function [rSpe,Tdot,rNet,rF,rR] = ri_pt(rPfr,t,yy)
% [rSpe,Tdot,rNet,rF,rR] = ri_pt(pfrObj,time,[concentrations T])
%
% run P=const, isothermal kinetics

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1 $
% Last modified: February 14, 2010

rm = rPfr.RxnModel;
rDat = rm.rDat;
nRxn = length(rDat.primeId);
mexx = rm.mex;

[~,m] = size(yy);
nSpe = m - 1;

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
                             
   rSpe(:,i1) = rSpe(:,i1) - c.* ( sum(rSpe(:,i1))/sum(c) );

end