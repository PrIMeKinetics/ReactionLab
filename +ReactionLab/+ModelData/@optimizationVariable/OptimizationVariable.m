classdef OptimizationVariable < handle

% Copyright 2008-2014 primekinetics.org
% Created by: Xiaoqing You, UC Berkeley, November 19, 2008
% Modified by: Xiaoqing You, UC Berkeley, January 23, 2009
% Modified: Michael Frenklach, April 27, 2010 - new Matlab OOP
% Modified: Michael Frenklach, May 21, 2010 - added variableBounds
% Modified: April 12, 2013, myf: added stitic method hdf2optvar
% Modified: April 15, 2013, myf: modified Bounds
% Modified: April 28, 2013, myf: switch to h5read

   properties
      Key        = ''
      PrimeId    = '';
      Type       = '';
      Transformation = '';
      Name       = '';
      Value      = [];
      Units      = '';
      Links      = {};    % {primary; secondary}
      LowerBound  = [];
      UpperBound  = [];
      BoundsKind = '';
      BoundsPrimeId = '';
      BoundsRef  = '';
      BoundsRefPrimeId = '';
      Description = '';
      Center = [];
      Span   = [];
      AdditionalData = struct('itemType',{},'description',{},'content',{});
   end
   
   properties (Dependent)
      Bounds               % [LB UB]
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
      obj = dom2optvar(ovDoc,ovBndDoc)
      y = hdf5read(filePath,indLinks)
      y =   h5read(filePath,indLinks)
      
      function y = loadDoc(ovDoc,ovBndDoc)
         if ~isempty(ovDoc)
            y = ReactionLab.ModelData.OptimizationVariable.dom2optvar(ovDoc,ovBndDoc);
         else
            y = [];
         end
      end

   end
   
end