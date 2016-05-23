function pfr_vt(rPfr,y0)
% prf_vt(pfrObj,initConditions)
%
% run V=const isothermal kinetics

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1 $
% Last modified: February 14, 2010

rm = rPfr.RxnModel;

mexx = rm.mex;

resTime = rPfr.ResidenceTime;
tout = [0 resTime];
options = odeset('RelTol',1e-4,'AbsTol',1e-18);
%options = odeset('RelTol',1e-4,...
%   'AbsTol',[repmat(1e-18,1,length(y0)-1) 100]);

f2run = rr_vt;

runTime = cputime;
   [t,y] = ode15s(f2run,tout,y0,options);
runTime = cputime - runTime;

rPfr.Results = {t,y,runTime};


   function fhandle = rr_vt
   % initialize nested function to be used with ode solver
   
      fhandle = @f_rr_vt;

      function ydot = f_rr_vt(t,y)
      % nested function to be used with ode solver

         c = y;
         c(end) = [];

         [ydot,rNet,rF,rR] = Codes.rxnrates(y,mexx.sForw,mexx.sRev,mexx.indRxn,...
                                              mexx.indArr,mexx.kArr,mexx.kPres,mexx.eqK);
         ydot(end) = 0;
      end
      
   end

end