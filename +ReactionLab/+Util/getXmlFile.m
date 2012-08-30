function docObj = getXmlFile(fileType)
% DOMobject = getXmlFile('Element|Species|...')

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: November 21, 2011

NET.addAssembly('System.Xml');

filePath = ReactionLab.Util.getFilePath(fileType);
if isempty(filePath)
   docObj = [];
else
   doc = System.Xml.XmlDocument;
   docObj = doc.LoadXml(filePath);
end