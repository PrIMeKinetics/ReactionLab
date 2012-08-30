classdef PrIMeThermo < handle
   
% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.1 $
% Last modified: July 30, 2011

   properties (SetAccess = private)
      SpeciesId         = '';  % species primeId
      BestCurrentIndex  = [];  % index of PolynomialFileList
      PolynomialFileIds = {};
      AtticFileIds      = {};
      isDataDir                % does data directory exist  (0|1)
      isTh0                    % does th00000000 file exist (0|1)
   end
   
   properties (Dependent = true)
      BestCurrentId
   end
   
   methods
      function obj = PrIMeThermo(spePrimeId)
         if nargin > 0
            obj.SpeciesId = spePrimeId;
            setFileIds(obj);
         end
      end
      
      function y = get.BestCurrentId(obj)
         y = obj.PolynomialFileIds{obj.BestCurrentIndex};
      end
      function setAtticFileList(obj)
         obj.AtticFileIds = strtok(ReactionLab.Util.gate2primeData(...
                   'getAtticFileList',{'primeID',obj.SpeciesId,'thp'}),'.xml');
      end
      function y = getThermo(obj,thId)
         doc = ReactionLab.Util.gate2primeData('getDOM',{'primeID',obj.SpeciesId,thId});
         y = ReactionLab.ThermoData.Nasa7(doc);
      end
   end
   
   methods (Static)
      thOut = nasa7toPP(spe,thList,refElemThermo)
%       thOut = readBurcat_thr(fileName)
   end
    
end