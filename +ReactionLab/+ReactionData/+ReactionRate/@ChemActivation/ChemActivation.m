classdef ChemActivation < ReactionLab.ReactionData.ReactionRate.Unimolecular

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: January 1, 2011


   methods
      function obj = ChemActivation(varargin)
         obj = obj@ReactionLab.ReactionData.ReactionRate.Unimolecular(varargin{:});
      end
   end

end