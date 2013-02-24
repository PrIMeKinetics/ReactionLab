function displayThermoFiles(speGUI)
% displayThermoFiles(speGUIobj)

% Copyright 1999-2011 Michael Frenklach
% $ Revision: 1.1 $
% Last modified: January 15, 2011

spe = speGUI.CurrentSpecies;
spePrimeId = spe.PrimeId;
set(speGUI.Hfiles.spePrimeId,'String',['for  ' spePrimeId]);

if isempty(findprop(spe,'PrIMeThermoObj'))
   obj = ReactionLab.Util.PrIMeData.ThermoDepot.PrIMeThermo(spePrimeId);
   addprop(spe,'PrIMeThermoObj');
   spe.PrIMeThermoObj = obj;
else
   obj = spe.PrIMeThermoObj;
end
set(speGUI.Hfiles.bestCurrent,'String',obj.BestCurrentId);
thIds = obj.PolynomialFileIds;

if isempty(findprop(spe,'PrIMeThermoPPs'))
   th = ReactionLab.Util.PrIMeData.ThermoDepot.PrIMeThermo.nasa7toPP(spe,...
                              thIds,speGUI.Hfiles.refElemThermo);
   addprop(spe,'PrIMeThermoPPs');
   spe.PrIMeThermoPPs = th;
else
   th = spe.PrIMeThermoPPs;
end
speGUI.Hfiles.thList = th;

numFiles = length(th);
data = cell(numFiles,3);
thObjMap  = containers.Map;
thFileMap = containers.Map;
for i1 = 1:numFiles
   data(i1,:) = {thIds{i1} th(i1).DataRef.key false};
   thObjMap(thIds{i1}) = th(i1);
   thFile = ReactionLab.Util.PrIMeData.WarehouseFile('','',...
                      thIds{i1},speGUI.CurrentSpecies.PrimeId);
   thFileMap(thIds{i1}) = thFile;
end
speGUI.Hfiles.thObjMap  = thObjMap;
speGUI.Hfiles.thFileMap = thFileMap;

ind = strcmpi(data(:,1),spe.Thermo.Id);
data{ind,3} = true;
set(speGUI.Hfiles.table,'Data',data);
speGUI.Hfiles.thObjSelected = spe.Thermo;