function setThermo(rxn,speList)
% setThermo(ReactionObj,SpeciesList)

% Copyright 2006-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: January 2, 2011

th = ReactionLab.ThermoData.ThermoPP();
th.Id  = rxn.PrimeId;

rxnSpe = rxn.Species;
numSpe = length(rxnSpe);
coef = [rxnSpe.coef];

speData = th.SpeciesData;
for i1 = 1:numSpe
   speObj = speList.find('primeId',rxnSpe(i1).primeId);
   sTh(i1) = speObj.Thermo;
   speData(i1).speKey        = speObj.Key;
   speData(i1).spePrimeId    = speObj.PrimeId;
   speData(i1).thermoPrimeId = sTh(i1).Id;
   speData(i1).coef          = coef(i1);
end
th.SpeciesData = speData;

refStates = [sTh.RefState];
refT = unique([refStates.T]);
refP = unique([refStates.P]);
if length(refT)==1 && length(refP)==1
   th.RefState.T = refT;
   th.RefState.P = refP;
else
   disp([sTh.RefState.T])
   disp([sTh.RefState.T])
   error(['Reference states of species are not the same for ' rxn.Eq]);
end

%  convert the Nasa7 object into ThermoPP object
% find overlapping T range
Tmin = max([sTh.Tmin]);
Tmax = min([sTh.Tmax]);
Tarray = ReactionLab.Util.makeTarray([Tmin Tmax]);

y = zeros(2,length(Tarray));
for i1 = 1:length(sTh)
   y =  y + sTh(i1).eval(Tarray,{'h' '';'s' ''}) * coef(i1);
end

rxn.Thermo = th.setThermo(Tarray,y,{'H' 'K'; 'S' 'K/K'});