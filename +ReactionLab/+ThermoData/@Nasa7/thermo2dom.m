function thDoc = thermo2dom(th)
% function thDoc = thermo2dom(Nasa7Obj)
%
% Creates PrIMe Schema-compliant thermodynamic polynomials DOM object
% from Matlab thermoPoly structure

% Copyright 2006-2013 primekinetics.org
% Created by: Zoran M. Djurisic, University of California at Berkeley, 23 January 2006.
% edited by Zoran M. Djurisic, UC Berkeley, on 1 November 2007.
% Modified: December 15, 2010, myf
% Last Modified: December 12, 2012: changed directory of thpTemplate

NET.addAssembly('System.Xml');
import System.Xml.*;

thDoc = System.Xml.XmlDocument;
thDoc.Load(which('+ReactionLab\+Util\+PrIMeData\+ThermoDepot\thpTemplate.xml'));

rootElement = thDoc.DocumentElement;

% primeID
rootElement.SetAttribute('primeID',th.Id);

% polynomial type
rootElement.SetAttribute('type','Nasa7');

% copyright node
a = clock;
year = a(1);
copyrightNode = thDoc.GetElementsByTagName('copyright').Item(0);
copyrightNode.InnerText = ['primekinetics.org 2006-' num2str(year)];

% bibliography
dataRef = th.DataRef;
bibliographyElement = thDoc.GetElementsByTagName('bibliographyLink').Item(0);
bibliographyElement.SetAttribute('preferredKey',dataRef(1).key);
bibliographyElement.SetAttribute('primeID',     dataRef(1).id );
numRefs = length(dataRef);
if numRefs > 1
   for i1 = 2:numRefs
      newNode = thDoc.CreateElement('bibliographyLink');
      newNode.SetAttribute('preferredKey',dataRef(i1).key);
      newNode.SetAttribute('primeID',     dataRef(i1).id );
      thDoc.DocumentElement.InsertAfter(newNode,bibliographyElement);
   end
end

% preferred key
preferredKeyElement = thDoc.GetElementsByTagName('preferredKey').Item(0);
preferredKeyElement.SetAttribute('group', 'prime');
preferredKeyElement.InnerText = th.Comment;
% preferredKeyElement.AppendChild(thDoc.CreateTextNode(th.Comment));

% species
speciesElement = thDoc.GetElementsByTagName('speciesLink').Item(0);
speciesElement.SetAttribute('preferredKey',th.SpeciesKey);
speciesElement.SetAttribute('primeID',     th.SpeciesId );

% reference state
referenceStateElement = thDoc.GetElementsByTagName('referenceState').Item(0);
   % reference temperature
TrefElement = referenceStateElement.GetElementsByTagName('Tref').Item(0);
TrefElement.InnerText = num2str(th.RefState.T);
   % reference pressure
PrefElement = referenceStateElement.GetElementsByTagName('Pref').Item(0);
PrefElement.InnerText = num2str(th.RefState.P);

% enthalpy of formation
dfHElement = thDoc.GetElementsByTagName('dfH').Item(0);
if ~isempty(th.DeltaHf)
   dfHElement.InnerText = num2str(th.DeltaHf);
end

% polynomials
nPolynomials = length(th.Data);
for i1 = 1 : nPolynomials
   polynomialElement = thDoc.CreateElement('polynomial');
      validRangeElement = thDoc.CreateElement('validRange');
      
         TminElement = thDoc.CreateElement('bound');
         TminElement.SetAttribute('kind', 'lower');
         TminElement.SetAttribute('property', 'temperature');
         TminElement.SetAttribute('units', 'K');
         TminElement.AppendChild(thDoc.CreateTextNode(num2str(th.Data(i1).Trange(1))));
         validRangeElement.AppendChild(TminElement);

         TmaxElement = thDoc.CreateElement('bound');
         TmaxElement.SetAttribute('kind', 'upper');
         TmaxElement.SetAttribute('property', 'temperature');
         TmaxElement.SetAttribute('units', 'K');
         TmaxElement.AppendChild(thDoc.CreateTextNode(num2str(th.Data(i1).Trange(2))));
         validRangeElement.AppendChild(TmaxElement);
         
      polynomialElement.AppendChild(validRangeElement);
      
      coefs = th.Data(i1).coef;
      nCoefficients = length(coefs);
      for j1 = 1 : nCoefficients
         coefNo = int2str(j1);
         coefficientElement = thDoc.CreateElement('coefficient');
         coefficientElement.SetAttribute('id', coefNo);
         coefficientElement.SetAttribute('label', ['a' coefNo]);
         coefficientElement.AppendChild(thDoc.CreateTextNode(num2str(coefs(j1),'%.8e')));
         polynomialElement.AppendChild(coefficientElement);
      end
   rootElement.AppendChild(polynomialElement);
end

docStr = char(thDoc.OuterXml);
cleanStr = strrep(docStr,' xmlns=""','');
clear thDoc;
thDoc = System.Xml.XmlDocument;
thDoc.LoadXml(cleanStr);