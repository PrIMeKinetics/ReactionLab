function sdf2d_geom(obj,molModelObj)
% sdf2d_geom(MolGeomFactoryObj,MolecularModelObj)
%    convert sdf2d file to 2d Object

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: July 6, 2012


str = molModelObj.OutputString;

cc = textscan(str,'%s','delimiter','\n');
yy = cc{1};

atomArray = molModelObj.Geom3d.atoms;
for i1 = 1:length(atomArray)
   line = yy{4+i1};
   aa = textscan(line,'%f %f %f');
   atomArray(i1).setCoordinates(aa{1:3});
end
molModelObj.Geom2d(1).atoms = atomArray;
molModelObj.Geom2d(1).bonds = molModelObj.Geom3d(1).bonds;