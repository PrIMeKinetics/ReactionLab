function rm = hdf5rm(hdf5path,stateData,vp,heatOption)
% rmObj = hdf5rm(HDF5path,stateData,'v|p',heatOption)
%    rm  must be an empty rxnmodel object,
%                                                               
%  create structure object for the use with a mex file
%    for V = const, P = const

%    for PWA

% Copyright 1999-2015 Michael Frenklach
% Modified: March  4, 2010, myf
% Modified: March 18, 2015, myf: changed reading table of char in get
%                                added foParamNames

%#function hdf5read
%#function calcDev fit2arrhenius fit2polyInvT fit2polyT fitCvp
%#function fitEnergyRxn fitEnergySpe fitHeatRxn fitKeq k_fitTP

rm = PlugFlow.ReactionModel.rxnmodel;

order.Cvp = 4;
order.E   = 4;
order.P   = 4;
rm.order = order;

plotInd = 1;
rm.plotData.ind = plotInd;

rsName = get('/title');
rm.title = rsName;

% determine ranges of P and T
P0 = stateData.P.value;
if vp == 'p'
   range.P = [P0/2  P0*2];       % for isobaric run
else
   range.P = [P0/2  P0*100];     % for isochoric run
end
T0 = stateData.T.value;
if heatOption == 't'
   range.T = [T0-200  T0+200];   % for isothermal run
else
   range.T = [T0-200  3000];     % for adiabatic run
end
rm.range = range;

T = rm.range.T;
P = rm.range.P;
if length(T) == 2
   T = linspace(min(T),max(T),30);
end
rm.xdata.T = T;
lenT = length(T);
invT = 1./linspace(1/T(1),1/T(end),lenT);
rm.xdata.invT = invT;
if length(P) == 2
   P = linspace(min(P),max(P),30);
end
rm.xdata.P = P;
logP = logspace(log10(P(1)),log10(P(end)),length(P));
rm.xdata.logP = logP;

% determine reaction species and set the thermo data
   % get species data: determine reaction species only
allSpeList = get('/speciesData/speciesNames');
spePrimeId = get('/speciesData/speciesPrimeID');

rm.speData.list    = allSpeList;
rm.speData.primeId = spePrimeId;
rm.speData.molw = get('/speciesData/speciesMolWeight');

   % species thermo
thermoCoef = get('/speciesData/thermoPolynomials/thermoCoef')';
[rm,CESval] = fitData.fitCvp(thermoCoef,1:length(allSpeList),vp,rm);   %CESval = [ Cp|v, H|U, S ]

% reaction data
   % getting reaction rate data
rev          = get('/reactionData/isReversible')';
rm.rDat.eq   = get('/reactionData/reactionEquations');
rm.rDat.primeId = get('/reactionData/reactionPrimeID');
rxnType      = get('/reactionData/reactionRateType');
falloff      = get('/reactionData/reactionFalloff')';
arrParam     = get('/reactionData/arrheniusData/arrheniusParam');
arrInd       = get('/reactionData/arrheniusData/arrheniusRxnIndex')';
collider     = get('/reactionData/arrheniusData/arrheniusCollider')';
falloffType  = get('/reactionData/falloffData/falloffType');
foParamNames = get('/reactionData/falloffData/paramNames');
foParamVal   = get('/reactionData/falloffData/paramValues');

if ischar(falloffType)
   falloffType = {falloffType};
end

   % stoichiometric matrices
sForw = get('/reactionData/reactantSpeciesIndex');
 sRev = get('/reactionData/productSpeciesIndex' );

   % reaction heat
sF = sForw(2:end,:);
sR =  sRev(2:end,:);
dn = double(sRev(1,:)) - double(sForw(1,:));     % delta-N of reactions
[pE,rm] = fitData.fitHeatRxn(sF,sR,dn,thermoCoef,1:length(allSpeList),vp,rm);

   % equlibrium constants
[cKeq,rm] = fitData.fitKeq(sF,sR,dn,rev,CESval,'arrhenius',rm);
   
   % reaction rates -> organizing P-dependent rates
indM_012 = collider;   % 0 no M;  1 third body;  2 unimol or chem-activ

   % unimolecular and chemical-activation
indPrxn = find(falloff);   % indeces of P-dependend rxns
lenP = length(indPrxn);
arr2rem = [];
mex_kPres = zeros((rm.order.E + 1)*3,lenP);
for i1 = 1:lenP
   iP = indPrxn(i1);
   indPar = find(arrInd == iP);
   indM_012(indPar) = 2;
   colInd = collider(indPar);
   ind0 = find(colInd ==  0);    % index of k without M
   indM = find(colInd == -1);    % index of k with    M
   if isempty(indM)
      error(['there is no M collider in reaction ' int2str(iP)]);
   end
   i0 = indPar(ind0);
   k0 = arrParam(:,i0);
   iM = indPar(indM);
   kM = arrParam(:,iM);
   [~,kFitP,rm] = fitData.k_fitTP(k0,kM,T,P,rxnType{iP},...
                  falloffType{i1},foParamNames(:,i1),foParamVal(:,i1),rm);
   kFitP_transposed = kFitP';
   mex_kPres(:,i1) = kFitP_transposed(:);
   indPar([ind0 indM]) = [];
      % dividing k_i/k_M  for calculation of effective pressure
   arrParam(1,indPar) = arrParam(1,indPar)./kM(1);       % A
   arrParam(2,indPar) = arrParam(2,indPar) - kM(2);      % n
   arrParam(3,indPar) = arrParam(3,indPar) - kM(3);      % e
   arr2rem = [arr2rem i0 iM];
end
arrInd(arr2rem)     = [];
collider(arr2rem)   = [];
arrParam(:,arr2rem) = [];
indM_012(arr2rem)    = [];

% third-body: set the reaction with M last
i3m = arrInd(collider == -1);   % indexes of rxns with M;
%                               %   only third-body left by now
for i1 = i3m
   ind3M = find(arrInd == i1);
   colInd = collider(ind3M);
   if colInd(end) ~= -1          % if M is not last   
      indM = find(colInd == -1);    % index of k with M
      iNew = ind3M([1:indM-1 indM+1:length(colInd) indM]);
      arrInds   = arrInd(iNew);
      colliders = collider(iNew);
      arrParams = arrParam(:,iNew);
      indM_012s = indM_012(iNew);
      arrInd(ind3M)     = arrInds;
      collider(ind3M)   = colliders;
      arrParam(:,ind3M) = arrParams;
      indM_012(ind3M)   = indM_012s;
   end
   indM_012(ind3M) = 1;               % index for rxns with M
   collider(ind3M(end)) = 0;          % change -1 to 0 for the C code
end
   
% organizing the data for the pfr code
mex.sForw  = double(sForw);
mex.sRev   =  double(sRev);
mex.indRxn = [double(rev); double(falloff)];
mex.eqK = [log(cKeq(:,1)) cKeq(:,2:3)]';
mex.kArr = [log(arrParam(1,:)); arrParam(2:3,:)];
mex.indArr = [double(indM_012); double(collider); double(arrInd)];
mex.kPres  = mex_kPres;

rm.mex = mex;


   function y = get(field)
      st = hdf5read(hdf5path,field);
%       if isa(st,'double')
      if isnumeric(st)
         y = st;
         return;
      end
      [n,m] = size(st);
      if n == 1 && m == 1
         y = st.('Data');
      else
         y = cell(n,m);
         for i3 = 1:n
            for j3 = 1:m
               y{i3,j3} = st(i3,j3).('Data');
            end
         end
      end
   end

end