function setThermo(rs,thList)
% setThermo(ReactionSetObj,Nasa7list)
%   i.e., convert the Nasa7 object
%   into ThermoPP object for species

% Copyright 2006-2010 Michael Frenklach
% $Revision: 1.0 $
% Last modified: May 2, 2010

speList = rs.Species;
   
elem = rs.Elements.Values;
ids = {elem.RefElemId};
speExtra = {};
for i1 = 1:length(ids)
   spePrimeId = ids{i1};
   if isempty(speList.find('PrimeId',spePrimeId))
      speExtra = [speExtra spePrimeId];
   end
end
speExtra = unique(speExtra);

for i1 = 1:length(speExtra)
   spePrimeId = speExtra{i1};
   speList = speList.add(ReactionLab.SpeciesData.Species(spePrimeId));
   thPrimeId = ReactionLab.Util.gate2primeData('getBestCurrentId',{'primeID',spePrimeId,'thp'});
   thDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',spePrimeId,thPrimeId});
   thList(spePrimeId) = ReactionLab.ThermoData.Nasa7(thDoc);
end

% check that the reference state is the same
thObjCell = [thList.values];
thObj = [thObjCell{:}];
refStateStruct = [thObj.RefState];
refT = unique([refStateStruct.T]);
if length(refT) > 1
   disp(refT);
   error('different reference T');
end
refP = unique([refStateStruct.P]);
if length(refP) > 1
   disp(refP);
   error('different reference P');
end

speObjs = rs.Species.Values;   % the list rs's species
numSpe = length(speObjs);
Hwait = waitbar(0,'setting thermo','Name',['Loading from PrIMe: ' rs.Title]);
for i1 = 1:numSpe
   waitbar(i1/numSpe,Hwait,['setting thermo of ' speObjs(i1).Key ],...
                            'Name',['Loading from PrIMe: ' rs.Title]       );
   speObjs(i1).setThermo(speList,rs.Elements,thList);
end
close(Hwait);