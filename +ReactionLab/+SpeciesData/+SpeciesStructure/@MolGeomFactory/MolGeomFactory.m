classdef MolGeomFactory < handle
   
% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: July 3, 2012

% resolver  = 'ob' | 'nci_nih'
   
   methods (Static)
      function y = create(resolver)
         path = 'ReactionLab.SpeciesData.SpeciesStructure.';
         switch lower(resolver)
            case 'ob'
               path = [path 'ob.OBfactory'];
            case {'nci_nih' 'nci'}
               path = [path 'nci_nih.nciFactory'];
            otherwise
               error(['undefined resolver ' resolver])
         end
          y = feval(str2func(path));
      end
   end
   
end