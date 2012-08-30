function view(biblio,dispName)
% function view(PrIMeBiblioObj,dispName)

% Copyright 2005-20011 primekinetics.org
% Created by: Zoran M. Djurisic, University of California at Berkeley, 10 July 2006.
% Last edited by Zoran M. Djurisic at UC Berkeley on 1 November 2007.
% Modified to new format by M. Frenklach, January 6, 2011


if isempty(biblio), return, end

numRefs = length(biblio);

name = ['PrIMe Bibliography for ' dispName];
h = numRefs * 90;
Hfig = figure('Name', name, ...
              'Position', [700 500 500 h], ...
              'NumberTitle', 'off', ...
              'MenuBar',     'none', ...
              'Toolbar',     'none', ...
              'WindowStyle', 'normal', ...
              'Visible',     'on');   % 400
           
figColor = get(Hfig,'Color');

pos = [10 h 400 70];   % 400
for i1 = 1:numRefs
   str = biblio(i1).toString;
   pos(2) = pos(2) - 80;
   uicontrol('Parent', Hfig, ...
      'Style', 'text', ...
      'Units', 'pixels', ...
      'Position', pos, ...
      'HorizontalAlignment', 'left',...
      'Max', 10, ...
      'BackgroundColor', figColor, ...
      'ForegroundColor', 'blue', ...
      'String', str       );
   uicontrol('Parent', Hfig, ...
      'Style', 'popupmenu', ...
      'Units', 'pixels', ...
      'Position', pos + [410 30 -340 -30] , ...
      'HorizontalAlignment', 'center',...
      'ForegroundColor', 'blue',...
      'String', listOfOptions,...
      'Callback', @show );
end
set(Hfig, 'Visible', 'on');


   function show(h,d)
      choices = get(h,'String');
      ind = get(h,'Value');  % 2-'XML' 3-'Article' 4-'Web site'
      switch choices{ind}
         case 'View'
            return
         case 'XML'
            ReactionLab.Util.gate2primeData('show',{'primeId',biblio(i1).PrimeId});
         case 'Article'
            doi = char(biblio(i1).get('DOI'));
            web(['http://dx.doi.org/' doi], '-browser');
         case 'Web site'
            url = char(biblio(i1).get('URL'));
            web(url, '-browser');
         otherwise
            
      end
      set(h,'value',1);   % get back to diplaying 'View')
   end

   function y = listOfOptions(h,d)
      y = {'View' 'XML'};
      if ~isempty(char(biblio(i1).get('DOI')))
         y = [y {'Article'}];
      end
      if ~isempty(char(biblio(i1).get('URL')))
         y = [y {'Web site'}];
      end
   end

end