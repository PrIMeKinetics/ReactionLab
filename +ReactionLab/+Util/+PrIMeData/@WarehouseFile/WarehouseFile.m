classdef WarehouseFile < ReactionLab.Util.PrIMeData.WarehouseLink
   
% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.1 $
% Last modified: July 30, 2011

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
      
   end
   
    
end