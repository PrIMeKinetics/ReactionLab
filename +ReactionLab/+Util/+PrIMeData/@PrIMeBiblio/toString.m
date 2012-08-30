function biblioStr = toString(biblio)
% biblioString = toString(PrIMeBiblioObj)

% Copyright 2005-2011 primekinetics.org
% Created by: Zoran M. Djurisic, University of California at Berkeley, 24 May 2005.
% Last edited by Zoran M. Djurisic, UC Berkeley, 1 November 2007.
% Changed by M. Frenklach to new format, January 6, 2011

if isempty(biblio), return, end

biblioStr = [getAuthors('author') char(biblio.get('Title')) ', '];

switch char(biblio.get('ReferenceType'))
   case 'journal article'
      addItem('journal');
      addItem('volume');
      addItem('pages');
   case {'monograph' 'monograph chapter'}
      bookTitle = char(biblio.get('bookTitle'));
      switch referenceType
         case 'monograph'
            biblioStr = [biblioStr bookTitle];
         case 'monograph chapter'
            biblioStr = [biblioStr ', in "' bookTitle '"'];
      end
      editors = getAuthors('editor');
      if ~isempty(editors)
         biblioStr = [biblioStr ' (Edited by ' editors ')'];
      end
      addItem('publisher');
      addItem('city');
   case 'data collection'

   case 'meeting presentation'
      
   case 'other'

   case 'patent'

   case 'personal communication'
      
   case 'technical report'
      addItem('reportNumber');
      addItem('institution');
   case 'thesis'
      addItem('institution');
   case 'WWW document'
      addItem('URL');
end
addItem('year');
biblioStr = [biblioStr '.'];
   

   function names = getAuthors(prop)
      s = biblio.get(prop);    %  author  or  editor
      names = '';
      if ~isempty(s)
         for i2 = 1:size(s,1)
            names = [names s{i2,1} ', ']; %#ok<AGROW>
         end
      end
   end
   
   function addItem(prop)
      prop = biblio.get(prop);
      if ~isempty(prop)
         biblioStr = [biblioStr ', ' prop{:}];
      end
   end
   

   % 'translator'
   % 'date'
   % 'originalPublication'
   % 'reprintEdition'
   % 'reviewedItem'
   % 'accessionNumber'
   % 'ISBN'
   % 'CODEN'
   % 'URL'
   % 'DOI'
   
end