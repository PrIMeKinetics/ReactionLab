function y = loadXml(obj)
% XmlDocument = dowXML(WarehouseFileObj,displayOption)
% load XML file from Warehouse as XmlDocument

% Copyright 1999-2013 Michael Frenklach
% Created: March 29, 2013, myf
% Last modified: March 29, 2013, myf

res = obj.conn.Load(obj.FilePath);
if res.status
   y = res.result;
else
   y = [];
   error([obj.FilePath ': could not be loaded']);
end