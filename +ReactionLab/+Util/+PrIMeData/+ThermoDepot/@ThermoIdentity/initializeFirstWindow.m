function initializeFirstWindow(obj)
% initializeFirstWindow(ThermoIdentityObj)
% set the initial panel: 
%  loading and identifying species thermo data

% Copyright 1999-2012 Michael Frenklach
% Last modified: December 2, 2012

Hpanel = obj.Hpanel;

panelColor = get(Hpanel,'BackgroundColor');

uicontrol('Parent',Hpanel,...
   'Style', 'text',...
   'BackgroundColor', panelColor,...
   'ForegroundColor', 'blue',...
   'HorizontalAlignment', 'left',...
   'Position', [10 400 325 20],...
   'FontSize', 10, ...
   'String','IDENTIFYING THERMO DATA');

% obj.SpeDictBtn = uicontrol('Parent',Hpanel,...
%    'Style', 'pushbutton',...
%    'Position', [10 350 200 20],...
%    'FontSize', 10, ...
%    'String','Upload Species Dictionary',...
%    'Callback', @selectSpeDictFile );
% 
% obj.Table = uitable('Parent',Hpanel,...
%    'Position',[10 230 310 100],...
%    'ColumnWidth', { 184 60 60 },...
%    'ColumnName',{'Name' 'ID Type' ' '},...
%    'ColumnFormat',{'char','char','logical'},...
%    'ColumnEditable', [ false false true ], ...
%    'RowName', [] ,...
%    'Data', [] );
% 
% uicontrol('Parent',Hpanel,...
%    'Style', 'popupmenu',...
%    'HorizontalAlignment', 'left',...
%    'Position', [260 340 60 20],...
%    'FontSize', 10, ...
%    'String',{'Action' 'Remove' 'Merge' 'Restore' 'Edit' 'Convert'},...
%    'Callback', @localAction );
% 
% obj.HrxnSpeBtn = uicontrol('Parent',Hpanel,...
%    'Style', 'pushbutton',...
%    'Position', [10 10 200 20],...
%    'FontSize', 10, ...
%    'String','Match Reaction Species',...
%    'Visible', 'off',...
%    'Callback', @matchRxnSpe );
% 
% % results of conversion
% initializeResultsPanel(obj);
% obj.setCurrentData();
% if isempty(obj.Spe2id)
%    set(obj.HrxnSpeBtn,'Visible','off');
% else
%    set(obj.HrxnSpeBtn,'Visible','on');
% end
% 
% 
%    function localAction(hh,dd)
%    end



%    function done(hh,dd)
%       obj.setSpeciesList2id();
%       obj.identifySpecies;
%    end

end