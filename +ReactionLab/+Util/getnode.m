function [node,ind] = getnode(rootNode,nodeName,attrName,value)
% [node,ind] = getnode(rootNode, nodeName, attrname, value2find)
% return a single node by given value of attribute

%      new Matlab

% Copyright (c) 2008-2010 Michael Frenklach
% $Revision: 1.1 $
% Last modified: April 5, 2010 myf

NET.addAssembly('System.Xml');
import System.Xml.*;

nodesDoc = rootNode.GetElementsByTagName(nodeName);
for i1 = 1:double(nodesDoc.Count)
   ind = i1-1;
   if strcmpi(value,char(nodesDoc.Item(ind).GetAttribute(attrName)))
      node = nodesDoc.Item(ind);
      return
   end
end