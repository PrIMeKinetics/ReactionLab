function thOut = nasa7toPP(spe,thList,refElemThermo)
% ThermoPParray = nasa7toPP(SpeciesObj,Nasa7ObjIds,refElemThermoList)
%   load Nasa7files from the spe data directory and
%   convert them into ThermoPP objects for a given species
%  refElemThermoList -- containers.Map of pairs { primeId, Nasa7ob }

% Copyright 2006-2011 Michael Frenklach
% $ Revision: 1.0 $
% Last modified: July 30, 2011

th0 = spe.Thermo;
th1 = th0;

speData = th0.SpeciesData;  % struct

% going through reference elements
refElTh = ReactionLab.ThermoData.Nasa7.empty(1,0);
coef = [];
j1 = 0;
for i1 = 1:length(speData)
   d = speData(i1);
   if d.coef < 0
      j1 = j1 + 1;
      coef(j1) = d.coef;
      if refElemThermo.isKey(d.spePrimeId)
         th7 = refElemThermo(d.spePrimeId);
      else
         thBCid = ReactionLab.Util.gate2primeData('getBestCurrentId',{'primeID',d.spePrimeId,'th'});
         thDoc  = ReactionLab.Util.gate2primeData('getDOM',{'primeId',d.spePrimeId,thBCid});
         th7    = ReactionLab.ThermoData.Nasa7(thDoc);
         refElemThermo(d.spePrimeId) = th7;
      end
      refElTh(j1) = th7;
      th1.SpeciesData(i1).thermoPrimeId = th7.Id;
   else
      indRHS = i1;
   end
end
Tmin = max([refElTh.Tmin]);
Tmax = min([refElTh.Tmax]);

% getting the species thermo files
th7out = cell(1,length(thList));
refStates = th0.RefState;
for i2 = 1:length(thList)
   if strcmp(thList{i2},th0.Id)
      th7out{i2} = th0;
   else
      thDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',spe.PrimeId,thList{i2}});
      th7 = ReactionLab.ThermoData.Nasa7(thDoc);
      th7out{i2} = th7;
   end
   refStates(i2) = th7out{i2}.RefState;
   Tmin = max([Tmin th7out{i2}.Tmin]);
   Tmax = min([Tmax th7out{i2}.Tmax]);
end

% check that the reference state is the same
% refStateStruct = [ [refElTh.RefState] refStates];
% refT = unique([refStateStruct.T]);
% if length(refT) > 1
%    disp(refT);
%    error('different reference T');
% end
% refP = unique([refStateStruct.P]);
% if length(refP) > 1
%    disp(refP);
%    error('different reference P');
% end

%  overlapping temperature array
Tarray = ReactionLab.Util.makeTarray([Tmin Tmax]);

% evaluate LHS (i.e., ref elements)
z = zeros(4,length(Tarray));
for i3 = 1:length(refElTh)
   zz = cphs(refElTh(i3),Tarray);  % [Cp; H; S]
   z(4,:) = z(4,:) + zz(2,:) * coef(i3);   % calculate delta-H (Hf)
end

%  convert the Nasa7 object into ThermoPP object
thOut = ReactionLab.ThermoData.ThermoPP.empty(length(thList),0);
for i4 = 1:length(thList)
   if strcmp(thList{i4},th0.Id)
      thOut(i4) = th0;
   else
      y = z;
      y(1:3,:) = cphs(th7out{i4},Tarray);  % [Cp; H; S]
      y(4,:) = y(4,:) + y(2,:);   % calculate delta-H (Hf)
%       th1   = ReactionLab.ThermoData.ThermoPP();
      th1 = th0;
      th1.setThermo(Tarray,y,{'Cp' 'K/K'; 'H' 'K'; 'S' 'K/K'; 'Hf' 'K'});
      th1.Id = th7out{i4}.Id;
      th1.Comment  = th7out{i4}.Comment;
      th1.RefState = th7out{i4}.RefState;
      th1.DataRef  = th7out{i4}.DataRef;
      th1.SpeciesData(indRHS).thermoPrimeId = th7out{i4}.Id;
      thOut(i4) = th1;
   end
end