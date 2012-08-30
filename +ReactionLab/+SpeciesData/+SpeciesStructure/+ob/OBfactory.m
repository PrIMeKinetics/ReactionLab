classdef OBfactory < ReactionLab.SpeciesData.SpeciesStructure.MolGeomFactory
   
% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: July 5, 2012
   
   properties
      OBDotNet = NET.addAssembly(which('+ReactionLab\+SpeciesData\+SpeciesStructure\+ob\OBDotNet.dll'));
      Obconv   = OpenBabel.OBConversion();
      Mol      = OpenBabel.OBMol();
      Geom2d   = OpenBabel.OBOp.FindType('Gen2D');
      Geom3d   = OpenBabel.OBOp.FindType('Gen3D');
   end
   
   
   methods
      function obj = OBfactory(molModelObj)
         if nargin > 0
            obj.setGeometry(obj,molModelObj);
         end
      end
      
      function display(obj)
         disp(obj)
%          window(obj)
      end
      
      function setGeometry(obj,molModelObj)
         obj.Obconv.SetInFormat(molModelObj.InputFormat);
         obj.Obconv.ReadString(obj.Mol,molModelObj.InputString);
         obj.Mol.AddHydrogens();
        % 3d
         obj.Obconv.SetOutFormat('crk3d');
         obj.Geom3d.Do(obj.Mol);
         molModelObj.OutputString = obj.Obconv.WriteString(obj.Mol);
         obj.crk3d_geom(molModelObj);
        % 2d
         obj.Obconv.SetOutFormat('crk2d');
         obj.Geom2d.Do(obj.Mol);
         molModelObj.OutputString = obj.Obconv.WriteString(obj.Mol);
         obj.crk2d_geom(molModelObj);
      end
      
   end
   
end