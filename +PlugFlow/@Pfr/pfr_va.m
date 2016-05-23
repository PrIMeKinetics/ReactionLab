function pfr_va(rPfr,y0,indicator)
% pfr_va(pfrObj,initConditions,speciesForMaximum)
%
% run V=const, adiabatic up to ignition

% Copyright 1999-2016 Michael Frenklach
% Modified: February 14, 2010
% Modified:    March 19, 2015, myf: added 'event' for ignition
% Modified: October 07, 2015, Jim Oreluk: added ye, indicator for events
% Modified:   April 06, 2016, Jim Oreluk: Added nargin < 3 for indicator.

if nargin < 3
   indicator = 0;
end

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
if indicator ~= 0
    options1 = odeset(options,'Events', @(t, y) findMaximum(t, y, indicator));
    [t,y,te,ye,ie] = ode15s(f2run,tout,y0,options1);
    rPfr.Results = {t,y,runTime,te,ye};
else
    [t,y] = ode15s(f2run,tout,y0,options);
    rPfr.Results = {t,y,runTime};
end

runTime = cputime - runTime;

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

    function [value,isterminal,direction] = findMaximum(t,y,indicator)
        ydot = f2run(t,y);
        value = ydot(indicator);   % 14-OH
        %       value = ydot(2);   % 2-CO
        %       value = sum(y(1:end-1)) * ydot(end) + y(end) * sum(ydot(1:end-1)); % dP/dt = 0
        isterminal =  0;   % stop at local maximum
        direction =  -1;   % local maximum
    end
end
