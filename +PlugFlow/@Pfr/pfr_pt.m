function pfr_pt(rPfr,y0)
% pfr_pt(pfrObj,initConditions)
%
% run P=const isothermal kinetics

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

f2run = rr_pt;

runTime = cputime;
   [t,y] = ode15s(f2run,tout,y0,options);
runTime = cputime - runTime;

rPfr.Results = {t,y,runTime};


   function fhandle = rr_pt
   % initialize nested function to be used with ode solver
   
      fhandle = @f_rr_pt;
   
      function ydot = f_rr_pt(t,y)
      % nested function to be used with ode solver

         c = y;
         c(end) = [];

         [ydot,rNet,rF,rR] = Codes.rxnrates(y,mexx.sForw,mexx.sRev,mexx.indRxn,...
                                              mexx.indArr,mexx.kArr,mexx.kPres,mexx.eqK);
                                   
         rSpe = ydot;
         rSpe(end) = [];
         rSpe = rSpe - c.* ( sum(rSpe)/sum(c) );
         ydot = [rSpe; 0];
      end
   end

end