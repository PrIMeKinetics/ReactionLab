classdef ChemkinThermo < ReactionLab.ThermoData.Nasa7
% ThermoChemkin-type Nasa7 coefficient polynomials
%
%  ChemkinThermoObj = ChemkinThermo.load()
%  ChemkinThermoObj = ChemkinThermo.load(filePath)
   
% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: November 20, 2011
   

   methods
      function obj = ChemkinThermo(arg)
         if nargin > 0
            if isa(arg,'char')
               obj = ReactionLab.ThermoData.ChemkinThermo.load(arg);
            else
               error(['incorrect class: ' class(arg)]);
            end % if
         end % if
      end % constructor
   end  % constructor methods section


   methods (Static)
      thArray = readChemkinThermo(text,fileName)
      function thArray = loadTxt(fileTxt,fileName)
         thArray = ReactionLab.ThermoData.ChemkinThermo.readChemkinThermo(fileTxt,fileName);
         for i1 = 1:length(thArray)
            thArray(i1).Trange = findTrange(thArray(i1));
         end
      end
      function y = load(filePath)
         if nargin == 0
            [str,fileName] = ReactionLab.Util.getTextFile('Chemkin Thermo');
         else
            [str,fileName] = ReactionLab.Util.getTextFile('',filePath);
         end
         if isempty(str)
            y = [];
         else
            y = ReactionLab.ThermoData.ChemkinThermo.loadTxt(str,fileName);
         end
      end
   end

end