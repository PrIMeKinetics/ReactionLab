classdef OptimizationVariable

% Copyright 2008-2011 primekinetics.org
% Created by: Xiaoqing You, UC Berkeley, November 19, 2008
% Modified by: Xiaoqing You, UC Berkeley, January 23, 2009
% Modified: Michael Frenklach, April 27, 2010 - new Matlab OOP
% Modified: Michael Frenklach, May 21, 2010 - added variableBounds

  properties
      Key        = ''
      PrimeId    = '';
      Type       = '';
      Transformation = '';
      Name       = '';
      Value      = [];
      Units      = '';
      Links      = {};    % {primary; secondary}
      Bounds     = [];
      BoundsKind = '';
      BoundsPrimeId = '';
      BoundsRef  = '';
      BoundsRefPrimeId = '';
      Description = '';
      AdditionalData = struct('itemType',{},'description',{},'content',{});
   end


   methods
      function obj = OptimizationVariable(arg1,arg2)
         if nargin > 0
            if isa(arg1,'System.Xml.XmlDocument')
               obj = ReactionLab.ModelData.OptimizationVariable.loadDoc(arg1,arg2);
            elseif ischar(arg1)  % primeId
               ovDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',arg1});
               ovBndDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',arg1,arg2});
               obj = ReactionLab.ModelData.OptimizationVariable.loadDoc(ovDoc,ovBndDoc);
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
      obj = dom2optvar(ovDoc,ovBndDoc)
      
      function y = loadDoc(ovDoc,ovBndDoc)
         if ~isempty(ovDoc)
            y = ReactionLab.ModelData.OptimizationVariable.dom2optvar(ovDoc,ovBndDoc);
         else
            y = [];
         end
      end

   end
   
end