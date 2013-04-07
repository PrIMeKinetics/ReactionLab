function fromLocalFile(obj,fileName,fileDirPath)
% fromLocalFile(PrIMeModelObj,fileName,fileDirPath)
% 
% determine the file type by its extension
%   and create approporiate objects and
%   store corresponding files in component directory

% Copyright (c) 1999-2013 Michael Frenklach
%       Created: March 28, 2013, myf 
% Last modified: April  6, 2013, myf

NET.addAssembly('System.Xml');

% determine the file type
[~,name,ext] = fileparts(fileName);
obj.Title = name;
filePath = fullfile(fileDirPath,fileName);  % path to uploaded file

switch lower(ext)
   case '.xml'  %  xml catalog file
      loadXml();
   case '.h5'   %  HDF5 file
      loadH5();
   case '.mat'  %  ReactionSet object
      loadMat();
   otherwise
      error(['file type ' ext ' is not supported']);
end


   function loadXml()
      docXml = System.Xml.XmlDocument;
      docXml.Load(filePath);
      obj.Doc = docXml;
      obj.xml2mat();
      saveFiles();
   end

   function loadH5()
      outputFilePath = fullfile(obj.LocalDirPath,[name '.h5']);
      copyfile(filePath,outputFilePath,'f');
      fileattrib(outputFilePath,'+w');
   end

   function loadMat()
      s = load(filePath);
      f = fieldnames(s);
      obj.MatObj = s.(f{1});
      saveFiles();
   end

   function saveFiles()
      matObj = obj.MatObj;
      outputFilePath = fullfile(obj.LocalDirPath,[name '.mat']);
      save(outputFilePath,'matObj');
      outputFilePath = fullfile(obj.LocalDirPath,[name '.h5']);
%       matObj.h5write(outputFilePath);
      matObj.hdf5write(outputFilePath);
   end
         
end