function [y,z] = warehouseSearch(varargin)

% the following is a copy from PrIMeSpecies --- to be changed later

% search for warehouse species (static method of class PrIMeSpecies)
%  [list,struct] = warehouseSearch({'casNo','...'},{type,'value'},...,level)
%
% examples:
%      warehouseSearch('c3h8')
%      warehouseSearch({'name','c3h8'})
%      warehouseSearch({'name','c3h8'},{'number of elements',2})
%      warehouseSearch({'name','c3h8'},{'number of elements','2'})

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: January 10, 2012

lastArg = varargin{end};
if ischar(lastArg) && ...
      any(strcmpi(lastArg,{'shallow','deep'}))
   level = lastArg;
   varargin(end) = [];
else
   level = 'shallow';
end

if iscell(varargin{1})
   str = setInputString(varargin{:});
elseif ischar(varargin{1})
   str = setInputString({'name',varargin{1}});
else
   error(['incorrect input class ' class(varargin{1})])
end

[y,z] = ReactionLab.Util.PrIMeData.WarehouseLink.search('species/catalog/',str,level);


   function s = setInputString(varargin)
      s = '';
      for j1 = 1:length(varargin)
         val = varargin{j1}{2};
         switch lower(varargin{j1}{1})
            case {'casno' 'cas'}
               ss = ['CONTAINS(species_CASRegistryNumber, ''"'  val '"'' )'];
            case 'name'
               ss = ['CONTAINS(species_name, ''"'  val '"'' )'];
            case 'inchi'
               ss = ['CONTAINS(species_InChI, ''"'  val '"'' )'];
            case 'brutoformula'         %  c3 h8
               ss = ['CONTAINS(species_brutoFormula, ''"'  val '"'' )'];
            case 'composition'          % c_3 h_8
               ss = ['CONTAINS(species_composition, ''"'  val '"'' )'];
            case 'number of elements'
               if ~ischar(val)
                  val = int2str(val);
               end
               ss = ['species_composition_numberOfElements = ' val];
            case 'number of atoms'
               if ~ischar(val)
                  val = int2str(val);
               end
               ss = ['species_composition_numberOfAtoms = ' val];
            case 'element'
               ss = ['CONTAINS(species_composition_element_symbol, ''"'  val '"'' )'];
            otherwise
               error(['undefined property' lower(varargin{j1}{1})]);
         end
         if j1 == length(varargin)
            s = [s ss];
         else
            s = [s ss ' AND '];
         end
      end
   end

end