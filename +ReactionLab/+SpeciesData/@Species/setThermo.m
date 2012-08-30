function setThermo(spe,speList,elemList,thList)
% setThermo(SpeciesObj,SpeciesList,ElementsList,Nasa7objList)
%   i.e., convert the Nasa7 object
%   into ThermoPP object for the formation rxn
%   thList is containers.Map filles with Nasa7 objects

% Copyright 2006-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: January 13, 2011

th = ReactionLab.ThermoData.ThermoPP();

rxn = spe.formrxn(speList,elemList);

rxnSpe = rxn.Species;
numSpe = length(rxnSpe);
coef = [rxnSpe.coef];

speData = th.SpeciesData;
for i1 = 1:numSpe
   sTh(i1) = thList(rxnSpe(i1).primeId);   %  Nasa7 object
   speData(i1).speKey        = rxnSpe(i1).key;
   speData(i1).spePrimeId    = rxnSpe(i1).primeId;
   speData(i1).thermoPrimeId = sTh(i1).Id;
   speData(i1).coef          = coef(i1);
   if coef(i1) > 0
      th.Id      = sTh(i1).Id;
      th.DataRef = sTh(i1).DataRef;
      th.Comment = sTh(i1).Comment;
   end
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
   disp([sTh.RefState.P])
   error(['Reference states of ref elems are not the same for ' spe.Key]);
end

%  convert the Nasa7 object into ThermoPP object
% find overlapping T range
Tmin = max([sTh.Tmin]);
Tmax = min([sTh.Tmax]);
Tarray = ReactionLab.Util.makeTarray([Tmin Tmax]);

y = zeros(4,length(Tarray));
for i1 = 1:length(sTh)
   yy =  cphs(sTh(i1),Tarray);  % [Cp; H; S]
   y(4,:) = y(4,:) + yy(2,:) * coef(i1);   % calculate delta-H (Hf)
   if coef(i1) == 1
      y(1:3,:) = yy(1:3,:);     %  Cp, H, S of the product only
   end
end

spe.Thermo = th.setThermo(Tarray,y,{'Cp' 'K/K'; 'H' 'K'; 'S' 'K/K'; 'Hf' 'K'});