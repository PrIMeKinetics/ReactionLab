function arr = dom2arr(arr,arrNode,rxnOrder)
% ArrheniusObj = dom2arr(ArrheniusObj,DOMdocument,rxnOrder)

% Copyright 2005-2015 Michael Frenklach
% Modified  May 12, 2010
% Modified June 16, 2015, myf: added units = 's' option

NET.addAssembly('System.Xml');
import System.Xml.*;

parNodes = arrNode.GetElementsByTagName('parameter');
for i1 = 1:double(parNodes.Count)
   localSetParameter(parNodes.Item(i1-1));
end


   function localSetParameter(parNode)
   % parse single parameter of arrhenius expression of DOM node
      name  = char(parNode.GetAttribute('name'));
      units = char(parNode.GetAttribute('units'));
      value =  str2double(char(parNode.GetElementsByTagName('value').Item(0).InnerText));
      switch lower(name)
         case 'a'
            c = textscan(units,'%s','delimiter',',');
            s = c{1};
            if length(s) == 1 && strcmpi(s{1},'s')
               arr.A = value;
            elseif    strncmpi(s{1},'cm',2) && ...
               any(strcmpi(s{2},{'mol' 'mole'})) && ...
                   strcmpi(s{3},'s')
                arr.A = value;
            else
               units = {[s{1} '/' s{2}],s{3}};
               arr.A = ReactionLab.Units.conv_rate(value,units,{'cm3/mol','s'},rxnOrder);
            end
         case 'n'
            arr.n = value;
         case 'e'
            arr.E = value./ReactionLab.PhysConst.univR(units);
         otherwise
            error(['undefined parameter: ' name])
      end
   end

end