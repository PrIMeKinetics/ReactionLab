function crk3d_geom(obj,molModelObj)
% crk3d_geom(MolGeomFactoryObj,MolecularModelObj)
%    convert crk3d file to Geom3d

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: July 5, 2012

NET.addAssembly('System.Xml');
import System.Xml.*;

doc = System.Xml.XmlDocument;
doc.LoadXml(molModelObj.OutputString);

structureNode = doc.GetElementsByTagName('Structure3D').Item(0);

atomNodes = structureNode.GetElementsByTagName('Atom');
atomArray = ReactionLab.SpeciesData.SpeciesStructure.Atom.empty(atomNodes.Count,0);
for i1 = 1:atomNodes.Count
   aNode = atomNodes.Item(i1-1);
   id = str2double(char(aNode.GetAttribute('ID')));
   elem = getString(aNode,'Element');
   x = getNumber(aNode,'X');
   y = getNumber(aNode,'Y');
   z = getNumber(aNode,'Z');
   atomArray(i1) = ReactionLab.SpeciesData.SpeciesStructure.Atom(id,elem,x,y,z);
end
molModelObj.Geom3d(1).atoms = atomArray;

atomIds = [atomArray.Id];

bondNodes = structureNode.GetElementsByTagName('Bond');
bondArray = ReactionLab.SpeciesData.SpeciesStructure.Bond.empty(bondNodes.Count,0);
for i1 = 1:bondNodes.Count
   bNode = bondNodes.Item(i1-1);
   fromId = getNumber(bNode,'From');
   f = atomArray(atomIds == fromId);
   toId = getNumber(bNode,'To');
   t = atomArray(atomIds == toId);
   o = getNumber(bNode,'Order');
   s = getNumber(bNode,'Style');
   bObj = ReactionLab.SpeciesData.SpeciesStructure.Bond(f,t,o,s);
   f.Bonds = [f.Bonds bObj];
   t.Bonds = [t.Bonds bObj];
   bondArray(i1) = bObj;
end
molModelObj.Geom3d(1).bonds = bondArray;


   function y = getNumber(parentNode,nodeName)
      y = str2double(char(parentNode.GetElementsByTagName(nodeName).Item(0).InnerText));
   end

   function y = getString(parentNode,nodeName)
      y = char(parentNode.GetElementsByTagName(nodeName).Item(0).InnerText);
   end

end