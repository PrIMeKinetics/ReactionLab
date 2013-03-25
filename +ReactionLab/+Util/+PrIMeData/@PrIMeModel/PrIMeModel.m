classdef PrIMeModel < handle
   
% Copyright 1999-2013 Michael Frenklach
% Last modified: March 25, 2013

   properties (SetAccess = private)
      PWAcomponent = [];
      LocalDirPath = '';
      DocIn        = [];
      
      PrimeId      = '';
      Title        = '';
      CatalogFile  = [];
      
      DocRS        = [];
      RSfile       = [];
      RSobj        = [];   % ReactionSet object
   end
   
   methods
      function obj = PrIMeModel(arg)
         if nargin > 0
            if isa(arg,'Component')
               obj.PWAcomponent = arg;
               obj.DocIn = arg.DocIn;
               obj.LocalDirPath = arg.OutputDirectory;
            elseif isa(arg,'System.Xml.XmlDocument')
               obj.DocIn = arg;
            elseif ischar(arg)   % model primeId
               obj.PrimeId = arg;
            else
               error(['incorrect object class ' class(arg)])
            end
         end
      end
      
      function indSource = getOption(obj,option)
         modelSourceNode   = obj.getnode(obj.docIn,'list','description',option);
         modelSourceOption = obj.getnode(modelSourceNode,'option','selected','true');
         indSource = char(modelSourceOption.GetAttribute('value'));
      end
      
      function getFromXml(obj,docRS)
         obj.DocRS = docRS;
         docRoot = docRS.DocumentElement;
         obj.PrimeId = strtrim(char(docRoot.GetAttribute('primeID')));
         preferredKey = docRoot.GetElementsByTagName('preferredKey').Item(0);
         key = strtrim(char(preferredKey.InnerText));
         obj.Title = lower(key(isstrprop(key,'alphanum')));
         obj.CatalogFile = ReactionLab.Util.PrIMeData.WarehouseFile('','',obj.PrimeId);
      end
      
      function getRS(obj)
         % load and create ReactionSet object of DocRS
         % first check if rs exist in Warehouse
         rsFile = ReactionLab.Util.PrIMeData.WarehouseFile('','',obj.PrimeId,'.mat');
         if rsFile.Exist
            if obj.areDatesMatch(rsFile)
               obj.RSfile = rsFile;
               if ~obj.copyFromWH()
                  error(['file ' rsFile.FilePath ' could not be copied']);
               end
            else
               rs = ReactionLab.ModelData.ReactionSet(obj.DocRS);
               obj.RSobj = rs;
%                res = obj.conn.Upload(fileLocalPath,obj.FilePath);
               if ~obj.uploadToWH()
                  helpdlg(['uploaded ' fileLocalPath ' as ' obj.FilePath],'File Upload');
               end
            end
            
            keyboard
            
         else
            
         end
      end
      
      function y = areDatesMatch(obj,wFile)
         NET.addAssembly('System');
         DT = System.DateTime();
         df1 = obj.CatalogFile.getProperty('getlastmodified');
         b1 = DT.Parse(df1);
         df2 = wFile.getProperty('cataloglastmodified');
         if isempty(df2)
            y = 0;
         else
            b2 = DT.Parse(df2);
            y = b1.Equals(b2);
         end
      end
      
      function loadDOM(obj)
         docRS = ReactionLab.Util.gate2primeData('getDOM',{'primeId',obj.PrimeId});
         obj.getFromXml(docRS);
      end
      function setXMLfile(obj,un,pw)
         obj.XMLfile = ReactionLab.Util.PrIMeData.WarehouseFile(un,pw,obj.PrimeId);
      end
      function y = copyFromWH(obj)
         res = obj.conn(obj.RSfile.FilePath,obj.LocalDirPath);
         y = res.status;
      end
      function uploadToWH(obj)
         if obj.RSfile.isAuthorized
            res = obj.conn.Upload(obj.LocalDirPath,obj.FilePath);
            if res.result
               setProperty(obj,'submittedBy',obj.Username);
               setProperty(obj,'updateReason','updated with the latest XML version');
               helpdlg(['uploaded ' fileLocalPath ' as ' obj.FilePath],'File Upload');
            else
               errordlg(['File ' obj.FilePath ' could not be uploaded to PrIMe Warehouse'],...
                         'failure to upload','modal');
            end
            obj.upload(obj.LocalDirPath,'update');
         end
      end
   end
    
end