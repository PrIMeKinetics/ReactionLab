classdef WarehouseFile < ReactionLab.Util.PrIMeData.WarehouseLink
% WarehouseFile()
% WarehouseFile(username,password)
% WarehouseFile(username,password,'s00000049')
% WarehouseFile(username,password,'s00000049','thp00000001')
% WarehouseFile(username,password,'m00000003','.mat|.h5')
% WarehouseFile(''      ,''      ,'d00000003','.mat|.h5')

% Copyright 1999-2013 Michael Frenklach
% Last modified: March 17, 2013

   properties (SetAccess = private)
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
 
      function y = getPropertyNames(obj)
%          z = obj.ws.GetPropertyNames(obj.FilePath,obj.Username,obj.Password);
         z = obj.conn.GetPropertyNames(obj.FilePath);
         res = z.result;
         y = cell(res.Length,1);
         for i1 = 1:res.Length
            y{i1,1} = char(res(i1));
         end
      end
      function y = getDetails(obj)
%          y = obj.ws.GetDetails(obj.FilePath,obj.Username,obj.Password);
         y = obj.conn.GetDetails(obj.FilePath);
      end
      function y = getProperty(obj,propName)
%          z = obj.ws.PropFind(obj.FilePath,propName,obj.Username,obj.Password);
         z = obj.conn.PropFind(obj.FilePath,propName);
         y = char(z.result);
      end
      function setProperty(obj,propName,propValue)
         res = obj.ws.PropPatch(obj.FilePath,propName,propValue,obj.Username,obj.Password);
         if ~res.result
            error([obj.FilePath ': could not record ' propName]);
         end
      end
      function y = isequal(thisObj,anotherFileObj,prop)
         NET.addAssembly('System');
         DT = System.DateTime();
         if nargin < 3
            prop = 'getlastmodified';
         end
         df1 = thisObj.getProperty(prop);
         b1 = DT.Parse(df1);
         df2 = anotherFileObj.getProperty(prop);
         b2 = DT.Parse(df2);
         y = b1.Equals(b2);
      end
   end
   
end