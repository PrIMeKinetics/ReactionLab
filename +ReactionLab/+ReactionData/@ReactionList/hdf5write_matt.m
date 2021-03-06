function hdf5write(rxnList,hdf5path)
% hdf5write(ReactionListObj,HDF5path)
%                                                               
% create reaction part of the HDF5 file



% TO BE REMOVED LATER --- used older syntax
% April 4, 2013, myf




% Copyright 1999-2010 Michael Frenklach
% $Revision: 1 $
% Last modified: November 20, 2010
% Last modified: 4/16/13 updated parseThirdBody(2,[rk.Low.Values{i}]) line 232 wms

rxn = rxnList.Values;

% indentifying species in reactions
speNames = hdf5read(hdf5path,'/speciesData/speciesNames');
spePrimeIds = hdf5read(hdf5path,'/speciesData/speciesPrimeID');
nSpe = length(speNames);
allSpeNames = cell(1,nSpe);
allSpeIds   = cell(1,nSpe);
for i1 = 1:nSpe
   allSpeNames{i1} = speNames(i1).Data;
   allSpeIds{i1}   = spePrimeIds(i1).Data;
end

rxnSpeIds = setdiff(unique([rxn.SpeciesIds]),'s00000001');
nRxnSpe = length(rxnSpeIds);
rxnSpeInd = zeros(nRxnSpe,1,'uint8');
for i1 = 1:nRxnSpe
   rxnSpeInd(i1) = uint8(find(strcmpi(rxnSpeIds{i1},allSpeIds)));
end
hdf5write(hdf5path,'/reactionData/reactionSpeciesIndex',sort(rxnSpeInd),...            
                   '/reactionData/reactionPrimeID',     {rxn.PrimeId}  ,...
                   '/reactionData/reactionEquations',   {rxn.Eq     }  ,...
                   'WriteMode', 'append'                                 );

% collecting reaction data: stoichiometry, reversibility
nRxn = length(rxn);
mex_sForw = zeros(4,nRxn);
mex_sRev  = zeros(4,nRxn);
isReversible = zeros(nRxn,1,'uint8');
rxnType = cell(1,nRxn);
falloff = cell(1,nRxn);
arrPrimeId = {};
mex_kArr   = zeros(3,nRxn);
mex_indArr = zeros(3,nRxn);
iArr = 0;     % counter of array of arrhenius expressions, mex_kArr
Hwait = waitbar(0,'Building HDF5 object');
for iRxn = 1:nRxn
%    reactant = get(rxn(iRxn),'species');
   reactant = rxn(iRxn).Species;
   j_forw = []; j_rev = [];
   for s = reactant
      sFormula = s.key;
      sId   = s.primeId;
      sCoef = s.coef;
      j = find(strcmpi(sId,allSpeIds));
      if length(j) ~= 1
         error(['incorrect match of ' sId ' , ' s.key])
      end
      if sCoef < 0   % reactant
         j_forw = [j_forw repmat(j,1,-sCoef)];
      else           % product
         j_rev  = [j_rev  repmat(j,1, sCoef)];
      end
   end
   mex_sForw(1:length(j_forw)+1,iRxn) = [length(j_forw); j_forw'];
    mex_sRev(1:length(j_rev) +1,iRxn) = [length(j_rev) ; j_rev' ];
   
   kF = rxn(iRxn).RateCoef;
   parseRK(kF);
   
   rkLink = kF.PrimeId;
   if isempty(rkLink)
      rks = kF.Values;
      rkLink = {};
      for i2 = 1:length(rks)
         rkLink = [rkLink {rks{i2}.PrimeId}];
      end
   end
   try
       hdf5write(hdf5path,['/reactionData/rateCoefLinks/' rxn(iRxn).PrimeId],rkLink,...
                           'WriteMode', 'append'                                      );
   end
   waitbar(iRxn/nRxn);
end
close(Hwait);

% reaction stoichiometry
nStoich = max(size(mex_sForw,1),size(mex_sRev,1));
forwStoich = zeros(nRxn,nStoich,'uint16');
 revStoich = zeros(nRxn,nStoich,'uint16');
for i1 = 1:nRxn
   for j1 = 1:nStoich
      forwStoich(i1,j1) = uint16(mex_sForw(j1,i1));
       revStoich(i1,j1) = uint16(mex_sRev(j1,i1) );
   end
end
hdf5write(hdf5path,'/reactionData/reactantSpeciesIndex',forwStoich',...
                   '/reactionData/productSpeciesIndex', revStoich', ...
                   '/reactionData/isReversible',     uint8([rxn.Reversible]'),...
                   '/reactionData/arrheniusData/arrheniusParam',   mex_kArr,  ...
                   '/reactionData/arrheniusData/arrheniusPrimeID', arrPrimeId,...
                   'WriteMode', 'append'                                      );

% arrhenius data
nArr = size(mex_kArr,2);

% reaction rate data
reactionFalloff   = zeros(1,nRxn,'uint16');
arrheniusIndex    = zeros(1,nArr,'uint16');
arrheniusCollider = zeros(1,nArr, 'int16');
iFalloff = 0;
for iRxn = 1:nRxn
      indArr = find(mex_indArr(3,:) == iRxn);
      nArr = length(indArr);
      arrIndex = zeros(nArr,2,'int16');
      for i1 = 1:nArr
         iArr = indArr(i1);
         arrheniusIndex(iArr) = uint16(iRxn);        % ind of reaction
         arrIndex(i1,1) = int16(iArr);               % ind of arrheniusParam
         arrIndex(i1,2) = int16(mex_indArr(2,iArr)); % ind of collider species
         arrheniusCollider(iArr) = int16(mex_indArr(2,iArr)); % ind of collider species
      end
   if ~isempty(falloff{iRxn})
      iFalloff = iFalloff + 1;
      reactionFalloff(iRxn) = uint16(iFalloff);
      falloffType{iFalloff} = falloff{iRxn}.Type;
      foData = falloff{iRxn}.Data;
      if isempty(foData)
         par{iFalloff,1} = '';
         val{iFalloff,1} = [];
      else
         par{iFalloff,:} = {foData.param};
         val{iFalloff,:} = [foData.value];
      end
   end
end

len = cellfun(@length,val);
paramNames   = cell(max(len),iFalloff);
[paramNames{:}] = deal('');
paramValues = zeros(max(len),iFalloff);
for i1 = 1:iFalloff
   j1 = len(i1);
   if j1 > 0
      paramNames(1:j1,i1)  = par{i1};
      paramValues(1:j1,i1) = val{i1};
   end
end

hdf5write(hdf5path,'/reactionData/reactionRateType',  rxnType,           ...
                   '/reactionData/reactionFalloff',   reactionFalloff,   ...
                   '/reactionData/arrheniusData/arrheniusRxnIndex',arrheniusIndex,    ...
                   '/reactionData/arrheniusData/arrheniusCollider',arrheniusCollider, ...
                   '/reactionData/falloffData/falloffType',  falloffType, ...
                   '/reactionData/falloffData/paramNames',  paramNames, ...
                   '/reactionData/falloffData/paramValues', paramValues, ...
                   'WriteMode', 'append'                                 );
                                              
       
   function parseRK(rk)
   % rk: a single RateCoef object
      switch class(rk)
         case 'ReactionLab.ReactionData.ReactionRate.MassAction'
            if isempty(rxnType{iRxn})
               rxnType{iRxn} = 'mass action';
            end
            mex_kArr(1:3,iArr+1)   = [rk.A  rk.n  rk.E]';
            mex_indArr(1:3,iArr+1) = [0 0 iRxn]';
            arrPrimeId{iArr+1} = rk.PrimeId;
            iArr = iArr + 1;
         case 'ReactionLab.ReactionData.ReactionRate.ThirdBody'
            if isempty(rxnType{iRxn})
               rxnType{iRxn} = 'third body';
            end
            parseThirdBody(1,rk);
         case 'ReactionLab.ReactionData.ReactionRate.Sum'
            values = rk.Values;
            [y,className] = isSameClass(rk);
            if y
               if     strcmpi(className,'ReactionLab.ReactionData.ReactionRate.ThirdBody')
                  if isempty(rxnType{iRxn})
                     rxnType{iRxn} = 'third body';
                  end
                  parseRK([values{:}]);
               elseif strcmpi(className,'ReactionLab.ReactionData.ReactionRate.MassAction')
                  if isempty(rxnType{iRxn})
                     rxnType{iRxn} = 'sum';
                  end
                  for i2 = 1:length(values)
                     parseRK(values{i2});
                  end
               else
                  error(['incorrect class: ' className]);
               end
            else
               rxnType{iRxn} = 'sum';
               ind3b = 0;
               rk3bi =0;
               objClasses = getClasses(rk);
               for i2 = 1:length(objClasses)
                  switch objClasses{i2}
                     case 'ReactionLab.ReactionData.ReactionRate.MassAction'
                        parseRK(values{i2});
                     case 'ReactionLab.ReactionData.ReactionRate.ThirdBody'
                        ind3b = 1;
                        rk3bi=rk3bi+1;
                        rk3b(rk3bi) = values{i2};
                     case 'ReactionLab.ReactionData.ReactionRate.Sum'
                        parseRK(values{i2});
                     otherwise
                        error(['incorrect class: ' objClasses{i2}])
                  end
               end
               if ind3b
                  parseThirdBody(1,rk3b);
               end
            end
         case 'ReactionLab.ReactionData.ReactionRate.Unimolecular'
            rxnType{iRxn} = 'unimolecular';
            parseRK(rk.High);
            switch class(rk.Low)
                case 'ReactionLab.ReactionData.ReactionRate.ThirdBody'
                    parseThirdBody(2,rk.Low)
                otherwise
                    % wms changed
                    % parseThirdBody(2,[rk.Low.Values{i}])
                    valLow=[];
                    for i=1:length(rk.Low.Values)
                        switch class(rk.Low.Values{i})
                            case 'ReactionLab.ReactionData.ReactionRate.ThirdBody'
                                valLow = [valLow rk.Low.Values{i}];
                            otherwise
                                valLow = [valLow rk.Low.Values{i}.Low];
                        end
                    end
                    parseThirdBody(2,valLow);
            end
            falloff{iRxn} = rk.Falloff;
         case 'ReactionLab.ReactionData.ReactionRate.ChemActivation'
            rxnType{iRxn} = 'chemical activation';
            parseRK(rk.Low);
            parseThirdBody(3,[rk.High.Values{:}]);
            falloff{iRxn} = rk.Falloff;
         otherwise
            error(['undefined class: ' class(rk)]);
      end
   end

   function parseThirdBody(ind3,rk)
   % parse a set of third-body reactions
   %   and setting the one with M, if present, last
   % ind3 = 1 if third-body
   %      = 2 if unimolecular
   %      = 3 if chemical activation
      col = [rk.Collider];  % struct with fields 'key' and 'primeId'
      iM = strcmpi('s00000001',{col.primeId});     % find 'M'
      if isempty(iM)
         error('there is no M as collider')
      end
      n = length(rk);
      if n == 1                % only 'M'
         mex_kArr(1:3,iArr+1) = [rk.A  rk.n  rk.E];
         mex_indArr(1:3,iArr+1) = [ind3 -1 iRxn]';
         arrPrimeId{iArr+1} = rk.PrimeId;
         iArr = iArr + 1;
      else
         if iM ~= n             % M is not the last one
            rkM = rk(iM);       % k with collider M
            rk(iM) = [];        % remove k with M
%             col(iM) = [];       % remove M from collider array
%             [~,indSorted] = sort({col.key});
%             rkSorted = rk(indSorted);    % sorted by collider key
%             rk = [rkSorted rkM];         % append 'M' at the end
            rk = [rk rkM];         % append 'M' at the end
         end
         mex_kArr(1:3,iArr+1:iArr+n) = [[rk.A];  [rk.n];  [rk.E]];
         arrPrimeId(iArr+1:iArr+n) = {rk.PrimeId};
         col = [rk.Collider];
         for i2 = 1:n-1
            colSpeInd = find(strcmpi(col(i2).primeId,allSpeIds));
            if isempty(colSpeInd)
               error(['collider ' col(i2).key '(' col(i2).primeId ') not found'])
            end
            mex_indArr(1:3,iArr+1) = [ind3 colSpeInd iRxn]';
            iArr = iArr + 1;
         end
         mex_indArr(1:3,iArr+1) = [ind3 -1 iRxn]';   %  the last is M
         iArr = iArr + 1;
      end
   end

end