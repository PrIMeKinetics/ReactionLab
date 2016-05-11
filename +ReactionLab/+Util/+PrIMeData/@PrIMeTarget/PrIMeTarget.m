classdef PrIMeTarget < ReactionLab.Util.PrIMeData.PrIMeModel
   
% Copyright (c) 1999-2015 Michael Frenklach
%       Created:   April 15, 2013, myf
% Last modified: January  4, 2015, myf, added constructor

   properties (Dependent = true)
      ExperimentPrimeId
   end

   
   methods
      function obj = PrIMeTarget(arg)
         if nargin == 0
            error('incorrect call: needs arg=comp');
         end
         obj@ReactionLab.Util.PrIMeData.PrIMeModel(arg);
      end
      
      function y = get.ExperimentPrimeId(obj)
         y = obj.MatObj.Links;
      end
      
      function xml2mat(obj)
         obj.MatObj = ReactionLab.ModelData.Target(obj.Doc);
      end
      
      function h5fromMat(obj,doesFileExist)
         obj.hdf5write(obj.H5pathLocal);
         updateWHfile(obj,'h5',doesFileExist);
      end
   end
   
end