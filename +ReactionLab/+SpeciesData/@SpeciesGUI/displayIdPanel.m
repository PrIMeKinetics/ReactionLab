function displayIdPanel(speGUI)
% displayIdPanel(speGUI)

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: January 31, 2012

s = speGUI.CurrentSpecies;

set(speGUI.Hid.speKey,    'String', s.Key      );
set(speGUI.Hid.speName,   'String', s.Names    );
set(speGUI.Hid.speFormula,'String', s.Formulas );

elem = s.Elements;
   eSym = {};
   eNum = {};
   for e = elem
      eSym = [eSym{:} {e.symbol}];
      eNum = [eNum{:} {num2str(e.number)}];
   end
set(speGUI.Hid.speElemSymbol,'String', eSym );
set(speGUI.Hid.speElemNumber,'String', eNum );

if ~isempty(s.Mass)
   set(speGUI.Hid.speMolWeight,  'String', ['Mass = ' num2str(s.Mass)] );
end
set(speGUI.Hid.speCASregistry,'String', ['CAS No. = ' s.CASNo]      );
set(speGUI.Hid.speInChI,      'String', s.InChI                     );
set(speGUI.Hid.spePrimeId,    'String', ['primeId = ' s.PrimeId]    );

speGUI.displayGeomPanel();
% set(speGUI.Hgeom.panel,'Visible','on');