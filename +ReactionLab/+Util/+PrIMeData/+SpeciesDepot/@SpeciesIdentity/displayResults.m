function displayResults(obj)
% displayResults(SpeciesIdentityObj)

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: March 20, 2012

Hresults = obj.Hresults;

% display the in the results window
if isempty(Hresults.matched)
   set(Hresults.HfoundVal,'String','');
   set(Hresults.HfoundBtn,'Visible','off');
else
%          c = cellfun(@isempty,d.dNew(:,2),'UniformOutput', true);
%          nFound = size(d.dNew,1) - length(find(c));
   numMatched = size(Hresults.matched(:,1),1);
   set(Hresults.HfoundVal,'String',int2str(numMatched));
   set(Hresults.HfoundBtn,'Visible','on');
end
if isempty(Hresults.multiple)
   set(Hresults.HmultipleVal,'String','');
   set(Hresults.HmultipleBtn,'Visible','off');
else
   numMultiple = size(Hresults.multiple(:,1),1);
   set(Hresults.HmultipleVal,'String',int2str(numMultiple));
   set(Hresults.HmultipleBtn,'Visible','on');
end
if isempty(Hresults.notFound)
   set(Hresults.HnotFoundVal,'String','');
   set(Hresults.HnotFoundBtn,'Visible','off');
else
   numNotFound = size(Hresults.notFound(:,1),1);
   set(Hresults.HnotFoundVal,'String',int2str(numNotFound));
   set(Hresults.HnotFoundBtn,'Visible','on');
end
if isempty(Hresults.notInPrIMe)
   set(Hresults.HsubmitVal,'String','');
   set(Hresults.HsubmitBtn,'Visible','off');
else
   numNotInPrime = size(Hresults.notInPrIMe(:,1),1);
   set(Hresults.HsubmitVal,'String',int2str(numNotInPrime));
   set(Hresults.HsubmitBtn,'Visible','on');
end

set(Hresults.Hpanel,'Visible','on');