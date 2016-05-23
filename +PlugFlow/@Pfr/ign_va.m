function ign_va(rPfr,y0)
% ign_va(pfrObj,initConditions)
%
% run V=const, adiabatic up to ignition

% Copyright 1999-2015 Michael Frenklach
% Modified: February 14, 2010
% Modified:    March 19, 2015, myf: added 'event' for ignition

rm = rPfr.RxnModel;
rDat = rm.rDat;
% dU  = reshape([rDat.dU],length(rDat(1).dU),length(rDat))';
dU = rDat.dU;
rm_speData_Cv = rm.speData.Cv;
[nc,nspe] = size(rm_speData_Cv);
[nU,mU] = size(dU);
rm_mex = rm.mex;

resTime = rPfr.ResidenceTime;
tout = [0 resTime];
options = odeset('RelTol',1e-4,'AbsTol',1e-18);
options1 = odeset(options,'Events',@findPmax);
%options = odeset('RelTol',1e-4,...
%   'AbsTol',[repmat(1e-18,1,length(y0)-1) 100]);

f2run = rr_va(rm_speData_Cv,2-nc,dU,mU-1,rm_mex);

runTime = cputime;
   [t,y,te,ye,ie] = ode15s(f2run,tout,y0,options1);
runTime = cputime - runTime;

rPfr.Results = {t,y,runTime,te};


   function fhandle = rr_va(cvp,two_nc,dU,mU_1,mexx)
   % initialize nested function to be used with ode solver

      fhandle = @f_rr_va;
   
      function ydot = f_rr_va(t,y)
      % nested function to be used with ode solver

         T = y(end);
         c = y;
         c(end) = [];

         [ydot,rNet,rF,rR] = Codes.rxnrates(y,mexx.sForw,mexx.sRev,mexx.indRxn,...
                                              mexx.indArr,mexx.kArr,mexx.kPres,mexx.eqK);
         %    species Cv
         cv = T.^(two_nc:1) * cvp;    % Cv(1xNspe)
         cv_tot = cv * c;

         %      delta-U for reactions
         ydot(end) = -(T.^(mU_1:-1:0) * dU' * rNet) / cv_tot;
      end
   end

   function [value,isterminal,direction] = findPmax(t,y)
      ydot = f2run(t,y);
      value = ydot(14);   % 14-OH
%       value = ydot(2);   % 2-CO
%       value = sum(y(1:end-1)) * ydot(end) + y(end) * sum(ydot(1:end-1)); % dP/dt = 0
      isterminal =  1;   % stop at local maximum
      direction =  -1;   % local maximum
   end

end