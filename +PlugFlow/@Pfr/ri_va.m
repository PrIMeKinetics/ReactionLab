function [rSpe,Tdot,rNet,rF,rR] = ri_va(rPfr,t,yy)
% [rSpe,Tdot,rNet,rF,rR] = ri_va(pfrObj,time,[concentrations T])
%
% V = const, adiabatic

% Copyright 1999-2015 Michael Frenklach
% Modified: February 14, 2010
% Modified:    March 18, 2015

rm = rPfr.RxnModel;
rDat = rm.rDat;
% dU = reshape([rDat.dU],length(rDat(1).dU),length(rDat))';
dU = rDat.dU;
cvp = rm.speData.Cv;
[nc,nSpe] = size(cvp);
[nRxn,mU] = size(dU);
mexx = rm.mex;

Tarray = yy(:,end);
lenTime = length(t);
rSpe = zeros(nSpe,lenTime);
rF   = zeros(nRxn,lenTime);  rR = rF;  rNet = rF;
Tdot = zeros(1,lenTime);
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
   
   %    species Cv
   cv = T.^(2-nc:1) * cvp;    % Cv(1xNspe)
   cv_tot = cv * c;

   %      delta-U for reactions
   Tdot(i1) = -(T.^(mU-1:-1:0) * dU' * rNeti) / cv_tot;
end