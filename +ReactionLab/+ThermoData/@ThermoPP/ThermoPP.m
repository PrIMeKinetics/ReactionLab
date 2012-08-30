classdef ThermoPP < ReactionLab.ThermoData.Thermo
% uses Matlab piecewise polynomials
   
% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: February 26, 2011

   properties (SetAccess = 'protected')
      ThermoProp = {};
      Data = [];
   end
   
   properties
      SpeciesData = struct('speKey','','spePrimeId','','thermoPrimeId','','coef',[]);  % all species
   end
   
   properties (Dependent = true)
      Breaks
   end
   
   
   methods
      function obj = ThermoPP(varargin)
         if nargin > 0
            obj = obj.setThermo(varargin{:});
         end % if
      end % constructor
   end
   
   
   methods
      function y = get.Breaks(obj)
         y = obj.Data.breaks;
      end
      function y = findTrange(obj)
        allT = obj.Breaks;
        y = [ min(allT) max(allT) ];
      end
   end
   
end