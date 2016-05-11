classdef Reaction < dynamicprops
   
% Copyright 1999-2016 Michael Frenklach
% Modified:  January  1, 2011
% Modified: December 31, 2015, myf: added Direction property
%                                   added flipDirection and
%                                         isDirectionMatch methods
%                                   changed display method
   
   properties
      PrimeId = '';
      Species = struct('key','','primeId','','coef',[]);
      RateCoef = [];
      Reversible = 1;  %  = 0 irreverssible
      Direction = 'forward';  % 'reverse' otherwise
   end
   
   properties (SetAccess = 'private')
      Thermo
   end
   
   properties (Dependent = true)
      Eq
      dN
      Order
      SpeciesNames
      SpeciesIds
   end
   
   
   methods
      function obj = Reaction(arg)
         if nargin > 0
            if isa(arg,'System.Xml.XmlDocument')
               obj = ReactionLab.ReactionData.Reaction.loadDoc(arg);
            elseif ischar(arg)  % primeID
               rxnDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',arg});
               obj = ReactionLab.ReactionData.Reaction.loadDoc(rxnDoc);
            else
               error(['incorrect class: ' class(arg)]);
            end % if
         end
      end
      
      function y = get.Eq(rxn)
         y = getRxnEq(rxn);
      end
      function y = get.dN(rxn)
         y = sum([rxn.Species.coef]);
      end
      function y = get.Order(rxn)
         coef = [rxn.Species.coef];
         y = sum(-coef(coef < 0));
      end
      function y = get.SpeciesNames(obj)
         [s,col] = getRxnSpecies(obj);
         y = unique({s.key col.key});
      end
      function y = get.SpeciesIds(obj)
         [s,col] = getRxnSpecies(obj);
         y = unique({s.primeId col.primeId});
      end
      
      function y = isempty(rxn)
         y = isempty(rxn.Species(1).key);
      end
      
      function display(obj)
         len = length(obj);
         if len > 1
            for i1 = 1:length(obj)
               disp(obj(i1).Eq)
            end
         else
            disp(obj)
         end
      end
   end

   
   methods (Static)
      obj = dom2rxn(docObj,isRev)
      
      function y = loadDoc(docObj)
         if ~isempty(docObj)
            y = ReactionLab.ReactionData.Reaction.dom2rxn(docObj);
         else
            y = [];
         end
      end
      
      ReactionObj = readChemkinRxn(lines,rkUnits,speListObj)
      [leftSide,rightSide,isrevesible] = parseRxnEq(rxnEq)
      [leftSide,rightSide] = parseRxnCatalog(rxnDoc)

   end
   
end