function ds = hdf5read(modelPath)
% DatasetObj = hdf5read(hdfFilePath)
%   a static method of Dataset class
%
% read HDF5 PrIMe dataset file and convert it into Dataset object

% Copyright 1999-2014 Michael Frenklach
%      Modified:   July  8, 2010, myf
%      Modified:  April 15, 2013, myf
%      Modified:  March 29, 2014, myf
%      Modified:   June 27, 2014, myf
% Last modified: August 22, 2014, myf: rep length(sm) with length(trg) in line 33


ds = ReactionLab.ModelData.Dataset();

ds.Title = get('title');

% determine whether with links or not by checking the primeID
ds.WithLinks = checkWlinks();

if ds.WithLinks
   ds.PrimeId    = get('primeID');
   ds.ModelId    = get('modelLinkId');
   ds.ModelTitle = get('modelLinkTitle');
end

ds.OptimizationVariables = ReactionLab.ModelData.OptimizationVariable.hdf5read(modelPath,ds.WithLinks);
sm = ReactionLab.ModelData.SurrogateModel.hdf5read(modelPath,ds.WithLinks);
ds.Targets = ReactionLab.ModelData.Target.hdf5read(modelPath,ds.WithLinks);
if ds.WithLinks
   trg = ds.Targets;
   for i1 = 1:length(trg)
      sm(i1).Target.primeId        = trg(i1).PrimeId;
      sm(i1).Target.transformation = trg(i1).Transformation;
   end
end
ds.SurrogateModels = sm;


   function y = checkWlinks()
      dsInfo = h5info(modelPath);
      if any(strcmpi('primeID',{dsInfo.Datasets.Name}))
         if ~isempty(get('primeID'))
            y = true;
            return
         end
      end
      y = false;
   end


   function y = get(field)
      st = hdf5read(modelPath,field);
      %       if isa(st,'double')
      if isnumeric(st)
         y = st;
      else
         len = length(st);
         y = cell(1,len);
         if len == 1
            y = st.('Data');
         else
            y = cell(1,len);
            for i5 = 1:len
                y{i5} = st(i5).('Data');
            end
         end
      end
   end

end