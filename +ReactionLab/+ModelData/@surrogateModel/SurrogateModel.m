classdef SurrogateModel

% Copyright 2008-2014 primekinetics.org
% Created by: Xiaoqing You, UC Berkeley, November 19, 2008
% Modified by: Xiaoqing You, UC Berkeley, November 25, 2008
% Modified: Michael Frenklach, April 23, 2010 - new Matlab OOP
% Modified: Michael Frenklach, May 21, 2010 - added variableBounds
% Modified: myf, April 12, 2013: added static method hdf2sm
% Modified: myf, April 15, 2013: added index wLinks
% Modified: myf, April 28, 2013: switch to h5read

   properties
      Key     = '';
      PrimeId = '';
      Coef    = [];
      Weight  = [];
      Target = struct('primeId','','transformation','');
      OptimizationVariables = struct('varId',{},'varPrimeId',{},'bndPrimeId',{});
      AdditionalData = struct('itemType',{},'description',{},'content',{});
   end

   
   methods
      function obj = SurrogateModel(varargin)
         if nargin > 0
            if isa(varargin{1},'System.Xml.XmlDocument')
               obj = ReactionLab.ModelData.SurrogateModel.loadDoc(varargin{1});
            elseif ischar(varargin{1})  % primeId
               smDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',varargin{1:2}});
               obj = ReactionLab.ModelData.SurrogateModel.loadDoc(smDoc);
            else
               error(['incorrect class: ' class(varargin{1})]);
            end % if
         end
      end
      
      function display(obj)
         disp(obj)
%          window(obj)
      end
   end


   methods (Static)
      obj = dom2sm(docObj)
      y = hdf5read(filePath,indLinks)
      y =   h5read(filePath,indLinks)
      
      function y = loadDoc(docObj)
         if ~isempty(docObj)
            y = ReactionLab.ModelData.SurrogateModel.dom2sm(docObj);
         else
            y = [];
         end
      end
      
   end
      
end