function rm = rxnmodel()
%  rxnModelStruct = rxnmodel

%   for PWA

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.1$
% Last modified: March 4, 2010, myf

rm = LOCAL_initRxnModel;

return


function rm = LOCAL_initRxnModel
% initializes a new member of class rxnmodel
   rm.title     = '';   % short id
   rm.path      = '';
   rm.comment   = '';
   rm.rxnset    = '';   % rxnsetName
   rm.version   =  0;
   rm.protect   =  0;
   rm.const     = '';   % 'v|p|t|vt|pt'
   rm.q         =  0;   % = 0 adiabatic, 1 otherwise
      range.T    = [];  % [minTemperature maxTemperature]
      range.P    = [];  % [minPressure    maxPressure   ]
      range.phi  = [];  % [minPHI         maxPHI        ]
      range.conc = [];  % for concentration ranges
   rm.range    = range;
      order.Cvp = [];   % for C_{v|p}
      order.E   = [];   % for delta-H or delta-U
      order.Keq = [];   % for equilibrium constant
      order.k   = [];   % for temperature dependence of rate coef
      order.P   = [];   % for pressure dependence of rate coef
   rm.order    = order; % for polynomial fits of above
   rm.speData  = LOCAL_speData;
   rm.stoM     = [];    % stoichiometric matrix NUM(rxn) X NUM(spe)
   rm.rDat     = LOCAL_rxnRecord;  % struct with all rxn data, i.e., = yy
   rm.mex      = LOCAL_mexRecord;  % structure for a mex file input
   [fitPoints,dev,plotData] = LOCAL_initFitData;
   rm.xdata    = fitPoints;  % points at which fitting is done
   rm.dev      = dev;   % [max deviation, ave deviation, # for ave]
   rm.plotData = plotData;
   rm.data.key = '';
   rm.data.rec = [];
return


function speData = LOCAL_speData
% return a new spcies record
   speData.primeId = {}; 
   speData.list = {};   % list of all species; {spe1 spe2 ... 'N2'}
   speData.molw = [];   % molecular weights (g/cm3)
   speData.Cv   = [];   % polynomial of species Cv; [p1; p2; ... ]
                        %    Cv/T = a*(1/T)^i + b*(1/T)^(i-1) + ... 
                        %    p = [a b ... ]'
   speData.Cp   = [];   % as above for Cp
   speData.U    = [];   %    U = a*T^n + b*T^(n-1) + ...
   speData.H    = [];   % as above for H
   speData.Uf   = [];   % 
   speData.HF   = [];   % 
   speData.S    = [];   %
   speData.G    = [];   %
return


function yy = LOCAL_rxnRecord
% return a new reaction record
   yy.rNo     = [];  % index of rxnObj
   yy.primeId = {};
   yy.eq      = {};  % rxn equations
   yy.forw    = [];  % indeces of species for FORWARD rxn
   yy.rev     = [];  % indeces of species for REVERSE rxn
   yy.k       = [];  % forward rate coefficient [A n E] if .m = 0 or 1
                     %   polynomial fits of A, n, and E in P if .m= 2
                     %       .k = [pA; pN; pE];  p = [a b ... ];
                     %   log(A) = a*log(P)^i + b*log(P)^(i-1) + ...
                     %     N,E  = a*log(P)^i + b*log(P)^(i-1) + ...
   yy.eqK     = [];  % equilibrium constant     [log(a) n e]
                     %    or a polynomial of log(Keq) = p(1/T)
   yy.m       = 0;   % = 0 independent of M
                     % = 1 if rate*[M]
                     % = 2 if M-dependent (unimol,chemAct)
   yy.dU      = [];  % polynomial of delta-U
   yy.dH      = [];  % polynomial of delta-H
   yy.dG      = [];  % polynomial of delta-G
   yy.dn      = [];  % delta-n
return


function zz = LOCAL_mexRecord
% return a new record for mex file input
   zz.sForw  = [];   % = [nSpe speInd1 speInd2 ...; ... ]'
   zz.sRev   = [];   % as above for Reverse
   zz.indRxn = [];   % = [isReverse ind_kPres; ...]'
   zz.kArr   = [];   % = [ log(a) n e ; ...]'
   zz.indArr = [];   % = [indM colSpeInd iRxn; ...]'
   zz.kPres  = [];   % = [coefA coefN coefE; ...]' (P-depnd)
   zz.eqK    = [];   % = [ log(a) n e ; ...]'
   zz.dG     = [];   % delta-G for the species formation reactions
return


function [f,d,p] = LOCAL_initFitData
% new record for fit quality: deviations and plots
                 p.ind = 0;
   d.Cv  = [];   p.Cv  = {};   f.T    = [];
   d.Cp  = [];   p.Cp  = {};   f.invT = [];  % = 1/linspace(1/T)
   d.dU  = [];   p.dU  = {};   f.P    = [];
   d.dH  = [];   p.dH  = {};   f.logP = [];  % = logspace(P)
   d.dG  = [];   p.dG  = {};
   d.eqK = [];   p.eqK = {};
   d.k   = [];   p.k   = {};
   d.U   = [];   p.U   = {};
   d.H   = [];   p.H   = {};
   d.S   = [];   p.S   = {};
return