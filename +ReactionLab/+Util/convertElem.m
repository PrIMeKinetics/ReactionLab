% convert element struct to new Element

clear, clc
load elemStruct;

newElement = ReactionLab.SpeciesData.Element.empty(1,0);
for el = elem
   e = ReactionLab.SpeciesData.Element;
   e.Id     = el.data(1).rec;
   e.Name   = el.name;
   e.Symbol = el.symbol;
   e.Mass   = el.mass;
   e.RefElemSymbol = el.refEl;
   e.RefElemId= el.data(2).rec;
   
   newElement = [newElement e];
end