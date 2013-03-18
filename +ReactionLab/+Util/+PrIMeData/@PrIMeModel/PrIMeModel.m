classdef PrIMeModel < handle
   
% Copyright 1999-2013 Michael Frenklach
% Last modified: March 17, 2013

   properties (SetAccess = private)
      Doc     = [];
      PrimeId = '';
      XMLfile = [];
      RSfile  = [];
      ReactionSet = [];
   end
   
   methods
      function obj = PrIMeModel(arg)
         if nargin > 0
            if isa(arg,'System.Xml.XmlDocument')
               obj.Doc = arg;
            elseif ischar(arg)   % model primeId
               obj.PrimeId = arg;
            else
               error(['incorrect object class ' class(arg)])
            end
         end
      end
      
      function loadDOM(obj)
         obj.Doc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',obj.PrimeId});
      end
      function setXMLfile(obj,un,pw)
         obj.XMLfile = ReactionLab.Util.PrIMeData.WarehouseFile(un,pw,primeId);
      end
      function setRSfile(obj,un,pw)
         obj.RSfile = ReactionLab.Util.PrIMeData.WarehouseFile(un,pw,primeId,'.mat');
      end
      function y = copyRS(obj,localDirPath,un,pw)
         if isempty(obj.RSfile)
            if obj.RSfile.isAuthorized
               setRSfile(obj,un,pw)
            end
         end
         res = wFile.conn.GetFile(obj.RSfile.FilePath,localDirPath);
         y = res.status;
      end
   end
    
end