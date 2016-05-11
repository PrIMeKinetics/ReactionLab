classdef WarehouseLink < handle
   
% Copyright 1999-2015 Michael Frenklach
%  Created:     March 20, 2013
% Modified:     April  4, 2013, myf
% Modified: September 10, 2014, myf: removed getappdata in get.Authorized
% Modified:  February 22, 2015, myf: changed get.Authorized and isAuthorized

   properties
      PrimeWebDAVclient = NET.addAssembly(which('+ReactionLab\+Util\PrimeWebDavClient.dll'));
      Common = PrimeKinetics.PrimeHandle.Data.Common;
      conn = PrimeKinetics.PrimeHandle.PrimeConnection('','');
      WebServiceClient  = NET.addAssembly(which('+ReactionLab\+Util\PrimeWSClient.dll'));
      ws = PrimeWSClient.PrimeHandleService.PrimeHandle();
      PrimeEditor_pub = NET.addAssembly(which('+ReactionLab\+Util\PrimeEditor.dll'));
      GenericEditor = @PrimeEditor.GenericEditor;
      PrimeHandle_local = NET.addAssembly(which('+ReactionLab\+Util\PrimeHandle.dll'));
   end
   
   properties (SetAccess = private)
      Authenticated
   end
   
   properties (Dependent = true)
      Username
      Password
      Authorized
   end
   
   methods
      function obj = WarehouseLink(un,pw)
         if nargin > 0
            obj.Username = un;
            obj.Password = pw;
            obj.authenticate();
         end
      end
      
      function y = get.Username(obj)
         y = char(obj.conn.Username);
      end
      function y = get.Password(obj)
         y = char(obj.conn.Password);
      end
      function set.Username(obj,un)
         obj.conn.Username = un;
      end
      function set.Password(obj,pw)
         obj.conn.Password = pw;
      end
      function y = get.Authorized(obj)
         y = obj.Authenticated;
         if isempty(y) || ~y
            obj.loginWindow();
%             obj.authenticate();
            y = obj.Authenticated;
         end
      end
      
      function y = exist(obj,path)
         if isempty(path)
            y = false;
         else
%          z = obj.ws.Exist(path,obj.Username,obj.Password);
            z = obj.conn.Exist(path);
            y = z.result;
         end
      end
      
      function y = getPropertyNames(obj,filePath)
%          z = obj.ws.GetPropertyNames(filePath,obj.Username,obj.Password);
         z = obj.conn.GetPropertyNames(filePath);
         res = z.result;
         y = cell(res.Length,1);
         for i1 = 1:res.Length
            y{i1,1} = char(res(i1));
         end
      end
      function y = getDetails(obj,filePath)
%          y = obj.ws.GetDetails(filePath,obj.Username,obj.Password);
         z = obj.conn.GetDetails(filePath);
         y = char(z.result);
      end
      function y = getProperty(obj,filePath,propName)
%          z = obj.ws.PropFind(filePath,propName,obj.Username,obj.Password);
         z = obj.conn.PropFind(filePath,propName);
         y = char(z.result);
      end
      function setProperty(obj,filePath,propName,propValue)
%          res = obj.ws.PropPatch(filePath,propName,propValue,obj.Username,obj.Password);
         res = obj.conn.PropPatch(filePath,propName,propValue);
         if ~res.status
            error([filePath ': could not record ' propName]);
         end
      end
      function y = isAuthorized(obj)
         y = obj.Authorized;
%          if ~obj.Authorized
%             obj.loginWindow();
%          end
%          y = obj.Authorized;
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
      
      function rsDoc = searchGUI(d)
         sGui = PrimeKinetics.PrimeHandle.SearchGUI(d);
         sGui.Topmost = true;
         sGui.ShowDialog();
         rsDoc = sGui.ReturnObject;
%          sGui.ReturnObject;
      end
      
   end
    
end