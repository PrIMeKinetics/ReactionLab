function th = dom2thermo(thermoDoc)
% Nasa7Obj = dom2thermo(thermoDocObj)

% Copyright 2003-2011 Michael Frenklach
% $ Release 1.1 $
% Last Modified: January 1, 2011

NET.addAssembly('System.Xml');
import System.Xml.*;

th = ReactionLab.ThermoData.Nasa7();

primeID = char(thermoDoc.DocumentElement.GetAttribute('primeID'));
th.Id = primeID;

biblioNode = thermoDoc.GetElementsByTagName('bibliographyLink');
numRefs = biblioNode.Count;
dataRef = th.DataRef;
for i1 = numRefs
   dataRef(i1).key = char(biblioNode.Item(i1-1).GetAttribute('preferredKey'));
   dataRef(i1).id  = char(biblioNode.Item(i1-1).GetAttribute('primeID'));
end
th.DataRef = dataRef;

commentNode = thermoDoc.GetElementsByTagName('preferredKey').Item(0);
th.Comment = char(commentNode.InnerText);

speNode = thermoDoc.GetElementsByTagName('speciesLink').Item(0);
th.SpeciesKey = char(speNode.GetAttribute('preferredKey'));
th.SpeciesId  = char(speNode.GetAttribute('primeID'));

type = char(thermoDoc.DocumentElement.GetAttribute('type'));
if ~strcmpi(type,'Nasa7')
   error([th.Id '/' th.SpeciesId ' is not a NASA7 record']);
end

refStateNode = thermoDoc.GetElementsByTagName('referenceState').Item(0);
refTnode = refStateNode.GetElementsByTagName('Tref').Item(0);
th.RefState.T = str2double(char(refTnode.InnerText));   % in K
refPnode = refStateNode.GetElementsByTagName('Pref').Item(0);
th.RefState.P = str2double(char(refPnode.InnerText));   % in Pa

polyDoc = thermoDoc.GetElementsByTagName('polynomial');
% poly.Tmin = []; poly.Tmax = []; poly.coef = [];
for i1 = 1:double(polyDoc.Count)
   coefRecord = polyDoc.Item(i1-1);
   rangeNode = coefRecord.GetElementsByTagName('bound');
   for i2 = 1:double(rangeNode.Count)
      item = rangeNode.Item(i2-1);
      property = char(item.GetAttribute('property'));
      kind = char(item.GetAttribute('kind'));        % lower or upper
      units = char(item.GetAttribute('units'));
      value = str2double(char(item.InnerText));
      if ~strcmpi(units,'k')
         error(['units must be K ' units]);
      elseif strcmpi(property,'temperature')
         switch lower(kind)
            case 'lower'
               th.Data(i1).Trange(1) = value;  % Tmin
            case 'upper'
               th.Data(i1).Trange(2) = value;  % Tmax
            otherwise
               error(['incorrect specification of limits ' primeID ]);
         end
      end
   end
   
   coefNode = coefRecord.GetElementsByTagName('coefficient');
   coefLen = double(coefNode.Count);
   if coefLen ~= 7
      error(['incorrect number of coefficients ' primeID ]);
   end
   coef = zeros(1,coefLen);
   for i2 = 1:coefLen
      item = coefNode.Item(i2-1);
      index = str2double(char(item.GetAttribute('id')));
      field = char(item.InnerText);
      value = str2double(field(~isstrprop(field,'wspace')));
      coef(index) = value;
   end
   th.Data(i1).coef = coef;
end