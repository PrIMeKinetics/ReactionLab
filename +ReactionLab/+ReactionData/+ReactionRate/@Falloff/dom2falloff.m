function foObj = dom2falloff(pDepnNode)
% foObj = dom2rk(pDepnNode)
%   parse falloff node of reactionRate DOM

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.0 $
% Last modified: April 19, 2010

NET.addAssembly('System.Xml');
import System.Xml.*;

foObj = ReactionLab.ReactionData.ReactionRate.Falloff();

pDepnForm = char(pDepnNode.GetAttribute('form'));
switch lower(pDepnForm)
   case 'falloff'
      falloffExpr = pDepnNode.GetElementsByTagName('expression').Item(0);
      falloffType = char(falloffExpr.GetAttribute('form'));
      foObj.Type = falloffType;
      if ~strcmpi(falloffType,'lindemann')
         parNode = falloffExpr.GetElementsByTagName('parameter');
         for i1 = 1:double(parNode.Count)
            data(i1) = localParseParameter(parNode.Item(i1-1));
         end
         foObj.Data = data;
      end
   case 'table'
      error('table form is not implemented yet');
   otherwise
      error(['unsupported pressure dependence form: ' pDepnForm]);
end


   function p = localParseParameter(parNode)
   % parse singe parameter node
      p.param = char(parNode.GetAttribute('name'));
      p.value = str2double(char(parNode.GetElementsByTagName('value').Item(0).InnerText));
      p.units = char(parNode.GetAttribute('units'));
%       p.error = uncertainty(parNode);
   end
   
end




