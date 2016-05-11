classdef Target < handle

% Copyright 2008-2013 primekinetics.org
% Created by: Xiaoqing You, UC Berkeley, November 19, 2008
% Modified by: Xiaoqing You, UC Berkeley, January 23, 2009
% Modified: Michael Frenklach, April 24, 2010 - new Matlab OOP
% Modified: myf, April 12, 2013: added static method hdf2trg
% Modified: myf, April 15, 2013: modified Bounds
% Modified: myf, April 28, 2013: switch to h5read

   properties
      Key         = '';
      PrimeId     = '';
      Type        = '';
      Transformation = '';
      Value       = [];
      Units       = '';
      Label       = '';
      BoundsKind  = '';
      LowerBound  = [];
      UpperBound  = [];
      Links       = {};   % 'x....,x.....'  experiment primeIDs
      Description = '';
      AdditionalData = struct('itemType',{},'description',{},'content',{});
   end
   
   properties (Dependent)
      Bounds               % [LB UB]
   end


   methods
      function obj = Target(arg)
         if nargin > 0
            if isa(arg,'System.Xml.XmlDocument')
               obj = ReactionLab.ModelData.Target.loadDoc(arg);
            elseif ischar(arg)  % primeId
               daDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',arg});
               obj = ReactionLab.ModelData.Target.loadDoc(daDoc);
            else
               error(['incorrect class: ' class(arg)]);
            end % if
         end
      end
      
      function y = get.Bounds(obj)
         y = [obj.LowerBound obj.UpperBound];
      end
      
      function set.Bounds(obj,bnds)
         obj.LowerBound = min(bnds);
         obj.UpperBound = max(bnds);
      end
      
      function display(obj)
         disp(obj)
%          window(obj)
      end
   end


   methods (Static)
      obj = dom2trg(docObj)
      y = hdf5read(filePath,indLinks)
      y =   h5read(filePath,indLinks)
      
      function y = loadDoc(docObj)
         if ~isempty(docObj)
            y = ReactionLab.ModelData.Target.dom2trg(docObj);
         else
            y = [];
         end
      end

   end
   
end