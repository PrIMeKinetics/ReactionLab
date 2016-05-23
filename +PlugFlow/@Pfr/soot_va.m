function pfr_va(rPfr,y0)
% prf_va(pfrObj,initConditions)
%
% run V=const, adiabatic kinetics, SOOT

%  a version from pfr_va for the soot project
%  added an external source to H production
%  June 19, 2015, myf

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1 $
% Last modified: February 14, 2010

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
%options = odeset('RelTol',1e-4,...
%   'AbsTol',[repmat(1e-18,1,length(y0)-1) 100]);

f2run = rr_va(rm_speData_Cv,2-nc,dU,mU-1,rm_mex);

runTime = cputime;
   [t,y] = ode15s(f2run,tout,y0,options);
runTime = cputime - runTime;

rPfr.Results = {t,y,runTime};


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
         ydot(end,1) = -(T.^(mU_1:-1:0) * dU' * rNet) / cv_tot;
         
         % a source of H production
%          ydot(4,1) = ydot(4,1) + 1e-8;
%          ydot(4,1) = ydot(4,1) + 0.02 * t;
 
      end
   end

end