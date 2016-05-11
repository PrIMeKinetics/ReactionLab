function ds = h5read(modelPath)
% DatasetObj = h5read(hdfFilePath)
%
% read HDF5 PrIMe dataset file and convert it into Dataset object

% Copyright 1999-2013 Michael Frenklach
%      Modified:   July  8, 2010, myf
%      Modified: April 15, 2013, myf
% Last modified: April 28, 2013, myf: switch to h5read

obj = PWAinterface(modelPath);

ds = ReactionLab.ModelData.Dataset();

ds.Title   = obj.h5read('title');

% determine whether with links or not by checking the primeID
ds.WithLinks = checkWlinks();

if ds.WithLinks
   ds.PrimeId    = obj.h5read('primeID');
   ds.ModelId    = obj.h5read('modelLinkId');
   ds.ModelTitle = obj.h5read('modelLinkTitle');
end

ds.OptimizationVariables = ReactionLab.ModelData.OptimizationVariable.h5read(modelPath,ds.WithLinks);
sm = ReactionLab.ModelData.SurrogateModel.h5read(modelPath,ds.WithLinks);
ds.Targets = ReactionLab.ModelData.Target.h5read(modelPath,ds.WithLinks);
if ds.WithLinks
   trg = ds.Targets;
   for i1 = 1:length(sm)
      sm(i1).Target.primeId        = trg(i1).PrimeId;
      sm(i1).Target.transformation = trg(i1).Transformation;
   end
end
ds.SurrogateModels = sm;


   function y = checkWlinks()
      dsInfo = h5info(modelPath);
      if any(strcmpi('primeID',{dsInfo.Datasets.Name}))
         if ~isempty(obj.h5read('primeID'))
            y = true;
            return
         end
      end
      y = false;
   end

end