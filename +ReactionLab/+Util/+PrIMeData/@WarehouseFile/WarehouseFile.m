classdef WarehouseFile < ReactionLab.Util.PrIMeData.WarehouseLink
% WarehouseFile()
% WarehouseFile(username,password)
% WarehouseFile(username,password,'s00000049')
% WarehouseFile(username,password,'s00000049','thp00000001')
% WarehouseFile(username,password,'m00000003','.mat|.h5')
% WarehouseFile(''      ,''      ,'d00000003','.mat|.h5')

% Copyright (c) 1999-2013 Michael Frenklach
%      modified: March 21, 2013
% Last modified: April  5, 2013, myf

   properties
      PrimeId    = '';
      PrIMeObjId = '';  % e.g., 's00000049' if PrIMeId = 'thp00000001'
      FilePath   = '';
   end
   
   
   methods
      function obj = WarehouseFile(un,pw,varargin)
         if nargin == 0
            un = '';
            pw = '';
         end
         obj = obj@ReactionLab.Util.PrIMeData.WarehouseLink(un,pw);
         if nargin > 2
            setFile(obj,varargin{:});
         end
      end
      
      function setFile(obj,primeId,primeObjId)
         obj.PrimeId = primeId;
         if nargin == 2
            filePath = char(obj.Common.PrimeID2path(primeId));
         elseif primeObjId(1) == '.'   % for .mat  of  .h5
            filePath = 'depository/';
            if primeId(1) == 'm'
               filePath = [filePath 'models'];
            elseif primeId(1) == 'd'
               filePath = [filePath 'datasets'];
            else
               error(['undefined request: ' primeId])
            end
            obj.FilePath = [filePath '/data/' primeId '/' primeId primeObjId];
            return
         else
            obj.PrIMeObjId = primeObjId;
            if strcmp(primeId,'th00000000')
               filePath = ['depository/species/data/' primeObjId '/th00000000.xml'];
            else
               filePath = char(obj.Common.PrimeID2path(primeObjId,primeId));
            end
         end
         if strncmp(filePath,'Invalid',7)
            error(['invalid address for ' obj.PrIMeObjId '/' obj.PrimeId]);
         else
            obj.FilePath = filePath;
         end
      end
      
      function y = exist(obj)
         y = exist@ReactionLab.Util.PrIMeData.WarehouseLink(obj,obj.FilePath);
      end
 
      function y = getPropertyNames(obj)
         y = getPropertyNames@ReactionLab.Util.PrIMeData.WarehouseLink(obj,obj.FilePath);
      end
      function y = getDetails(obj)
         y = getDetails@ReactionLab.Util.PrIMeData.WarehouseLink(obj,obj.FilePath);
      end
      function y = getProperty(obj,propName)
%          z = obj.ws.PropFind(obj.FilePath,propName,obj.Username,obj.Password);
         y = getProperty@ReactionLab.Util.PrIMeData.WarehouseLink(obj,obj.FilePath,propName);
      end
      function setProperty(obj,propName,propValue)
%          res = obj.ws.PropPatch(obj.FilePath,propName,propValue,obj.Username,obj.Password);
         setProperty@ReactionLab.Util.PrIMeData.WarehouseLink(obj,obj.FilePath,propName,propValue);
      end
      function y = isequalProperty(thisObj,anotherFileObj,prop)
         prop1 = thisObj.getProperty(prop);
         prop2 = anotherFileObj.getProperty(prop);
         y = strcmp(prop1,prop2);
      end
   end
   
end