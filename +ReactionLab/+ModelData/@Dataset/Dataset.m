classdef Dataset < dynamicprops
   
% Copyright 1999-2013 Michael Frenklach
%      modified: January  1, 2011, myf
%      modified:   April 12, 2013, myf: added static method hdf2dataset
%      modified:   April 15, 2013, myf: added property WithLinks
% Last modified:   April 28, 2013, myf: switch to h5read
   
   properties
      PrimeId   = '';
      Title     = '';
      Comment   = '';
      BiblioKey = '';
      BiblioId  = '';
      ModelId    = '';
      ModelTitle = '';
      
      OptimizationVariables
      SurrogateModels
      Targets
      
      TargetToPredict = [];
      
      WithLinks = true;
      
      AdditionalData = struct('itemType',{},'description',{},'content',{});
   end
   

   methods
      function obj = Dataset(arg)
         if nargin > 0
            if isa(arg,'System.Xml.XmlDocument')
               ds = ReactionLab.ModelData.Dataset();
               obj = ds.dom2dataset(arg);
            elseif ischar(arg)  % primeId
               ds = ReactionLab.ModelData.Dataset();
               dsDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',arg});
               obj = ds.dom2dataset(dsDoc);
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
      y = hdf5read(filePath)
      y =   h5read(filePath)
   end
   
end