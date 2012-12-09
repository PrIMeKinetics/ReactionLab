function [y,ff] = checkThermo(obj,th)
% [yes|no,matchList] = checkThermo(PrIMeThermoObj,Nasa7obj)
%
% check if a thermo file matching th already exists
%    in the Warehouse species/data/ directory
%    for a given species (by primeID)
% return thermo filePrimeId if match is flound, 
%    empty otherwise

% Copyright 2009-2012 Michael Frenklach
% Last modified: December 2, 2012

y = 0;  ff = {};
if obj.isDataDir
   fileList = obj.PolynomialFileIds;
   if ~isempty(fileList)
      for i1 = 1:length(fileList)
         thi = obj.getThermo(fileList{i1});
         if th.isequal(thi)
            y = y + 1;
            ff = [ff {thi.Id}];
         end
      end
   end
end