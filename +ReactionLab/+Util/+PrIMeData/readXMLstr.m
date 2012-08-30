function y = readXMLstr(xmlString)
%  DOMobj = readXMLstr(xmlString)
%
% read an XML-document string and
% return Matlab DOM object

% Copyright (c) 2003-2009 Michael Frenklach
% $Revision: 1 $
% Last modified: May 8, 2009 myf

import java.io.StringReader;
import javax.xml.parsers.DocumentBuilderFactory;
import org.xml.sax.InputSource;

factory = DocumentBuilderFactory.newInstance;
db = factory.newDocumentBuilder;
inStream = InputSource;
inStream.setCharacterStream(StringReader(xmlString));
y = db.parse(inStream);