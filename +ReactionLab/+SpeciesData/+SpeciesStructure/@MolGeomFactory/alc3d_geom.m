function alc3d_geom(obj,molModelObj)
% alc3d_geom(MolGeomFactoryObj,MolecularModelObj)
%  convert alc file to 3d geometry

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: July 6, 2012


str = molModelObj.OutputString;

% [a,b] = strtok(str,char(10));  % first line

cc = textscan(str,'%s','delimiter','\n');
yy = cc{1};

% xx = textscan(res,'%s',1,'delimiter','\n');
% zz = textscan(line1,'%[^ A] %[^ B]')
% zz{1}{1} % number of atoms
% zz{1}{2} % number of reactions

line1 = yy{1};
zz = textscan(line1,'%d %s');
numAtoms = zz{1}(1);  % number of atoms
numBonds = zz{1}(2);  % number of bonds

% parse atoms
atomArray = ReactionLab.SpeciesData.SpeciesStructure.Atom.empty(numAtoms,0);
for i1 = 1:numAtoms
   line = yy{i1+1};
   aa = textscan(line,'%d %s %f %f %f %d %d');
   aa{2} = getElementSymbol(aa{2}{1}(1));  % just the first letter
   atomArray(i1) = ReactionLab.SpeciesData.SpeciesStructure.Atom(aa{1:5});
end
molModelObj.Geom3d(1).atoms = atomArray;

atomIds = [atomArray.Id];

bondArray = ReactionLab.SpeciesData.SpeciesStructure.Bond.empty(numBonds,0);
for i1 = 1:numBonds
   line = yy{i1+numAtoms + 1};
   bb = textscan(line,'%d %d %d %s');
   fromId = bb{2};
   f = atomArray(atomIds == fromId);
   toId = bb{3};
   t = atomArray(atomIds == toId);
   o = getBondOrder(char(bb{4}));
   s = 0;    % style
   bObj = ReactionLab.SpeciesData.SpeciesStructure.Bond(f,t,o,s);
   f.Bonds = [f.Bonds bObj];
   t.Bonds = [t.Bonds bObj];
   bondArray(i1) = bObj;
end
molModelObj.Geom3d(1).bonds = bondArray;


   function y = getBondOrder(str)
      switch lower(str)
         case 'single'
            y = 1;
         case 'double'
            y = 2;
         case 'triple'
            y = 3;
         case 'aromatic'
            y = 1.5;
         otherwise
            error(['undefined bond order ' str]);
      end
   end

   function y = getElementSymbol(str)
      if strcmpi(str,'Car')
         y = 'C';
      else
         y = upper(str);
      end
   end

end