classdef MolecularModel < handle
   
% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: July 5, 2012
   
   properties
      SpeciesPrimeId = '';

      GeomFactory = '';  %  'ob|nci_nih'
      
      InputFormat  = 'inchi';
      InputString  = '';
      OutputFormat = '';
      OutputString = '';
      
      Geom2d = struct('atoms',{},'bonds',{});
      Geom3d = struct('atoms',{},'bonds',{});
      
      Hpanel
      Hgeom
   end
   
   
   methods
      function obj = MolecularModel(gf)
         if nargin > 0
            obj.GeomFactory = gf;
         end
      end
      
      function display(obj)
         disp(obj)
%          window(obj)
      end
      
      function set.InputString(obj,inputStr)
         obj.InputString  = inputStr;
         obj.convertToGeom();
      end
      
      function convertToGeom(obj)
         geomFactory = ReactionLab.SpeciesData.SpeciesStructure.MolGeomFactory.create(obj.GeomFactory);
         geomFactory.setGeometry(obj);
      end
      
      function plot(obj,geomDim)
         geomFactory = ReactionLab.SpeciesData.SpeciesStructure.MolGeomFactory.create(obj.GeomFactory);
         if strcmpi(geomDim,'2d')
            geomFactory.plot2d(obj);
         else
            geomFactory.plot3d(obj);
         end
      end
      
   end
   
end