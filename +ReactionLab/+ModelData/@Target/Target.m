classdef Target

% Copyright 2008-2011 primekinetics.org
% Created by: Xiaoqing You, UC Berkeley, November 19, 2008
% Modified by: Xiaoqing You, UC Berkeley, January 23, 2009
% Last Modified: Michael Frenklach, April 24, 2010 - new Matlab OOP

   properties
      Key         = '';
      PrimeId     = '';
      Type        = '';
      Transformation = '';
      Value       = [];
      Units       = '';
      Label       = '';
      BoundsKind  = '';
      Bounds      = [];   % [LB UB]
      Links       = {};   % 'x....,x.....'
      Description = '';
      AdditionalData = struct('itemType',{},'description',{},'content',{});
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
      
      function display(obj)
         disp(obj)
%          window(obj)
      end
   end


   methods (Static)
      obj = dom2trg(docObj)
      
      function y = loadDoc(docObj)
         if ~isempty(docObj)
            y = ReactionLab.ModelData.Target.dom2trg(docObj);
         else
            y = [];
         end
      end

   end
   
end