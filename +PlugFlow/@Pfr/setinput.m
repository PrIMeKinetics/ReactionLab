function y = setinput(rPfr,stateData)
%inputArray = setinput(PfrObj,stateData)
%
% create array of [init_conc T0]

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1 $
% Last modified: February 10, 2010

rm = rPfr.RxnModel;
modelPrimeId = rm.speData.primeId;

comp = stateData.MixtureComposition;
inputPrimeId = {comp.primeid};
molFract     = [comp.value];

y = zeros(1,length(modelPrimeId));
for i1 = 1:length(inputPrimeId)
   p = inputPrimeId{i1};
   ind = find(strcmpi(modelPrimeId,p));
   if isempty(ind)
      error(['species ' p ' is not in the model list'])
   elseif length(ind) > 1
      error(['species ' p ' is not unique in the model list'])
   else
      y(ind) = molFract(i1);
   end
end
T = stateData.T.value;
y = y * stateData.P.value/(82.05*T);

y = [y T];