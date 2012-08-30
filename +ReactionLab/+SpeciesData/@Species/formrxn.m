function r = formrxn(s,speList,elemList)
% ReactionObj = formrxn(SpeciesObj,SpeciesList,ElementsList)

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.0 $
% Last modified: May 3, 2010

r = ReactionLab.ReactionData.Reaction();

reactants = r.Species;
speElems  = s.Elements;

if nargin > 1
   for i1 = 1:length(speElems)
      el = speElems(i1);
      elObj = elemList.find('Symbol',el.symbol);
      refSpe = speList.find('PrimeId',elObj.RefElemId);
      setReactant(i1,el,elObj,refSpe);
   end
else   %  get from the PrIMe Warehouse
   for i1 = 1:length(speElems)
      el = speElems(i1);
      elObj = ReactionLab.SpeciesData.Element(el.symbol);
      refSpe = ReactionLab.SpeciesData.Species(elObj.RefElemId);
      setReactant(i1,el,elObj,refSpe);
   end
end
ii = length(reactants) + 1;
reactants(ii).key  = s.Key;
reactants(ii).coef = 1;
reactants(ii).primeId = s.PrimeId;

r.Species = reactants;


   function setReactant(ind,el,elObj,refSpe)
      reactants(ind).key  = elObj.RefElemSymbol;
      reactants(ind).coef = -el.number/refSpe.Elements.number;
      reactants(ind).primeId = elObj.RefElemId;
   end


end