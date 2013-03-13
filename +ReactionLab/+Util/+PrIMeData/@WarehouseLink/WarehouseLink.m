classdef WarehouseLink < handle
   
% Copyright 1999-2013 Michael Frenklach
% Last modified: March 12, 2013

   properties
      PrimeWebDAVclient = NET.addAssembly(which('+ReactionLab\+Util\PrimeWebDavClient.dll'));
      Common = PrimeKinetics.PrimeHandle.Data.Common;
      conn = PrimeKinetics.PrimeHandle.PrimeConnection('','');
      WebServiceClient  = NET.addAssembly(which('+ReactionLab\+Util\PrimeWSClient.dll'));
      ws = PrimeWSClient.PrimeHandleService.PrimeHandle();
      PrimeEditor_pub = NET.addAssembly(which('+ReactionLab\+Util\PrimeEditor_pub.dll'));
      GenericEditor = @PrimeEditor.GenericEditor;
      PrimeHandle_local = NET.addAssembly(which('+ReactionLab\+Util\PrimeHandle.dll'));
      Username = '';
      Password = '';
   end
   
   methods
      function obj = WarehouseLink(un,pw)
         if nargin > 0
            if isempty(un)
               obj.loginWindow;
               obj.conn.Username = obj.Username;
               obj.conn.Password = obj.Password;
            else
               obj.Username = un;
               obj.Password = pw;
               obj.conn.Username = un;
               obj.conn.Password = pw;
            end
         end
      end
      
      function y = getPropertyNames(obj,filePath)
         z = obj.ws.GetPropertyNames(filePath,obj.Username,obj.Password);
         res = z.result;
         y = cell(res.Length,1);
         for i1 = 1:res.Length
            y{i1,1} = char(res(i1));
         end
      end
      function y = getDetails(obj,filePath)
         y = obj.ws.GetDetails(filePath,obj.Username,obj.Password);
      end
      function y = getProperty(obj,propName,filePath)
         z = obj.ws.PropFind(filePath,propName,obj.Username,obj.Password);
         y = char(z.result);
      end
      function setProperty(obj,propName,propValue,filePath)
         res = obj.ws.PropPatch(filePath,propName,propValue,obj.Username,obj.Password);
         if ~res.result
            error([webDirPath ': could not record ' propName]);
         end
      end
   end

   
   methods (Static = true)
      
      [s,z] = search(col,ss,level)
      fileList = getFileList(dirName)
      
      function [y,rec] = validateXml(doc)
         rec = PrimeKinetics.PrimeHandle.Data.Common.ValidateXml(doc.OuterXml);
         y = rec.result;
      end
      
      function y = xmlViewer(doc)
         y = PrimeKinetics.PrimeHandle.XmlViewer(doc);
      end
      
      function filePath = getFilePath(varargin)
      % varargin = { mainPrimeId dataPrimeId }
         if length(varargin) == 1       %  objPrimeId
            filePath = char(PrimeKinetics.PrimeHandle.Data.Common.PrimeID2path(varargin{1}));
         else                           %  objPrimeId, dataPrimeId
            filePath = char(PrimeKinetics.PrimeHandle.Data.Common.PrimeID2path(varargin{1:2}));
         end
      end
      
   end
    
end