function s = dispdoc(doc)
% display MS doc

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.1 $
% Last modified: December 10, 2010

s = xmlwrite(ReactionLab.Util.PrIMeData.readXMLstr(char(doc.OuterXml)));