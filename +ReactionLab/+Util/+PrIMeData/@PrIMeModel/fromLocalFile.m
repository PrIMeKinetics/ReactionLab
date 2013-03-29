function fromLocalFile(obj,fileName,fileDirPath)
% fromLocalFile(obj,fileName,fileDirPath)
% 
% determine the file type by its extension
%   and create approporiate objects and
%   store corresponding files in component directory

% Copyright (c) 1999-2013 Michael Frenklach
% Created: March 28, 2013, myf 
% Last modified: March 28, 2013

% NET.addAssembly('System.Xml');

% determine the file type
[~,~,ext] = fileparts(fileName);
filePath   = fullfile(fileDirPath,fileName);                  % path to local file
h5FilePath = fullfile(obj.LocalDirPath,[obj.PrimeId '.h5']);  % to be copied as

switch lower(ext)
   case '.xml'  %  xml catalog file
      loadXml();
   case '.h5'   %  HDF5 file
      idFromHDF5(filePath);
      copyFileToComponentDir([obj.PrimeId '.h5']);
   case '.mat'  %  ReactionSet object
      loadRS();
   otherwise
      error(['file type ' ext ' is not supported']);
end


   function loadXml()
      docXml = System.Xml.XmlDocument;
      docXml.Load(strIn);
      setIdFromXml(obj,docXml)
      obj.CatalogFile = '';
      obj.RSobj = ReactionLab.ModelData.ReactionSet(obj.RSdoc);
      outputFilePath = fullfile(obj.LocalDirPath,[obj.PrimeId '.mat']);
      rs = obj.RSobj;
      save(outputFilePath,'rs');
      h5FromRS();
   end

   function idFromHDF5(path)
      titleStruc = hdf5read(path,'/title');
      obj.Title = titleStruc.data;
      idStruc = hdf5read(path,'/primeID');
      obj.PrimeId = idStruc.data;
   end

   function loadRS()
      s = load(filePath);
      f = filenames(s);
      obj.RSobj = s.(f{1});
      obj.PrimeId = obj.RSobj.PrimeId;
      obj.Title = obj.RSobj.Title;
      copyFileToComponentDir([obj.PrimeId '.mat']);
      h5FromRS();
   end

   function h5FromRS()
      h5FilePath = fullfile(obj.LocalDirPath,[obj.PrimeId '.h5']);
      obj.RSobj.hdf5write(h5FilePath);
      idFromHDF5(h5FilePath);
   end

   function copyFileToComponentDir(fileNameWext)
      outputFilePath = fullfile(obj.LocalDirPath,fileNameWext);
      copyfile(filePath,outputFilePath,'f');
      fileattrib(outputFilePath,'+w');
   end
         
end