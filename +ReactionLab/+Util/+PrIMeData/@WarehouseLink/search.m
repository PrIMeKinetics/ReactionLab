function [s,z] = search(col,ss,level)
% [s,z] = search(col,ss,level)
% search the PrIMe warehouse

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.1 $
% Last modified: June 12, 2011

if nargin < 3 || isempty(level)
   level = 'shallow';
end

wLink = ReactionLab.Util.PrIMeData.WarehouseLink();

z = Search(wLink.ws,['depository/' col],ss,level,'','');

s = localGetId(z);

   function w = localGetId(x)
      w = {};
      if x.status == 1
         r = x.result;
         if ~isempty(r)
            for i2 = 1:r.Length
               [~,id,~] = fileparts(char(r.GetValue(i2-1)));
               w{i2} = id;
            end
            return
         end
      end
   end

end