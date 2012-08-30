function [y,z] = warehouseSearch(varargin)
% search for warehouse experiments (static method of class PrIMeExperiments)
%  [list,struct] = warehouseSearch({'type',value},{type,'value'},...,level)
%
%  type:
%       primeID
%       preferredKey
%       bibliography_primeID
%       bibliography_preferredKey
%       apparatus_kind
%       apparatus_mode
%       apparatus_property_name
%       apparatus_property_value
%       apparatus_property_description
%       commonProperties_property_name
%       initialComposition_component_primeID
%       initialComposition_component_preferredKey
%       dataGroup_label
%       dataGroup_property_name
%       dataGroup_property_description
%       additionalDataItem
%
% examples:
%      warehouseSearch({'dataGroup_property_name','soot'})
%      warehouseSearch({'dataGroup_property_description','soot'})
%      warehouseSearch({'apparatus_kind','shock'})
%      warehouseSearch({'bibliography_key','shock'})
%      warehouseSearch({'name','c3h8'},{'number of elements','2'})

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: April 19, 2012

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
else
   str = setInputString(varargin);
end

[y,z] = ReactionLab.Util.PrIMeData.WarehouseLink.search('experiments/catalog/',str,level);


   function s = setInputString(varargin)
      s = '';
      for j1 = 1:length(varargin)
         val = varargin{j1}{2};
         ss = ['CONTAINS(experiment_' varargin{j1}{1} ', ''"'  val '"'' )'];
         if j1 == length(varargin)
            s = [s ss];
         else
            s = [s ss ' AND '];
         end
      end
   end

end