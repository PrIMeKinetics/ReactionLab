function hdf5write(speListObj,hdf5path,elListObj)
% hdf5write(SpeciesListObj,hdf5path,elListObj)
%
% covert SpeciesList object into HDF5

% TO BE REMOVED LATER --- used older syntax
% April 4, 2013, myf

% Copyright 1999-2015 Michael Frenklach
% Modified: January 1, 2011
% Modified:    June 8, 2015, myf: added transportData

% species
speObj = speListObj.Values;
numSpe = length(speObj);

speciesAtoms = zeros(numSpe,elListObj.Length,'int8');
elObj = elListObj.Values;

coef = [];    % thermo
trCoef = [];
trPrimeId = {};
Hwait = waitbar(0,'Building HDF5 object');
for i1 = 1:numSpe
   spePrimeId = speObj(i1).PrimeId;
   
   comp = speObj(i1).Elements;
   for i2 = 1:length(comp)
      [~,indElem] = elListObj.find('Symbol',comp(i2).symbol);
      if isempty(indElem)
         error(['element ' char(comp(i2).symbol) ' is not in the list']);
      end
      speciesAtoms(i1,indElem) = int8(comp(i2).number);
   end
   
   thPrimeId  = speObj(i1).Thermo.Id;
   thDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',spePrimeId,thPrimeId});
   thObj(i1) = ReactionLab.ThermoData.Nasa7(thDoc);
   poly = thObj(i1).Data;
   for i2 = 1:length(poly)
      Trange = poly(i2).Trange;
      coef = [coef; [i1 Trange(1) Trange(2) poly(i2).coef]];
   end
   
   trData = speObj(i1).AdditionalData;  % now only transport is in AdditionalData
   trPrimeId = [trPrimeId; {trData.description}];
   trCoef    = [trCoef;     trData.content     ];
   
   waitbar(i1/numSpe,Hwait,['species  ' speObj(i1).Key '  (' spePrimeId ')']);
end
close(Hwait);

% reference state
refStateStruct = [thObj.RefState];
refT = unique([refStateStruct.T]);
if length(refT) > 1
   disp(refT);
   error('different reference T');
end
refP = unique([refStateStruct.P]);
if length(refP) > 1
   refP=refP(1);
   %disp(refP);
   %error('different reference P');
end

speciesThermoGroup    = '/speciesData/thermoPolynomials/';
speciesTransportGroup = '/speciesData/transportData/';
hdf5write(hdf5path,'/elementData/elementNames',    {elObj.Symbol}  ,...
                   '/elementData/elementPrimeID',  {elObj.Id}      ,...
                   '/speciesData/speciesNames',    {speObj.Key}    ,...
                   '/speciesData/speciesPrimeID',  {speObj.PrimeId},...
                   '/speciesData/speciesMolWeight',[speObj.Mass]   ,...
                   '/speciesData/speciesAtoms',     speciesAtoms'  ,...
                   [speciesThermoGroup 'thermoType'   ], 'NASA7'  ,...
                   [speciesThermoGroup 'thermoPrimeID'], {thObj.Id},...
                   [speciesThermoGroup 'thermoCoef'   ], coef'    ,...
                   [speciesThermoGroup 'referenceTemperature'],refT,...  % in K
                   [speciesThermoGroup 'referencePressure'],   refP,...  % in Pa
                   'WriteMode', 'append'                             );
if ~isempty(trData)
   hdf5write(hdf5path,...
                   [speciesTransportGroup 'transportType'], 'Chemkin',...
                   [speciesTransportGroup 'transportPrimeId'], trPrimeId, ...
                   [speciesTransportGroup 'transportCoef'], trCoef', ...
                   'WriteMode', 'append'                             );
end