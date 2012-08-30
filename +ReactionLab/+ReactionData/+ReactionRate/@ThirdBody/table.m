function t = table(rk)
%t = table(ThirdBodyListObj)

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.1 $
% Last modified: April 15, 2010

Hfig = figure('Position',[100 100 400 150]);

columnname =   {'A' 'n' 'E (cal/mol)' 'Collider'};
columnformat = {'numeric' 'numeric' 'numeric' 'char'};
columneditable =  [false false false false];

col = [rk.Collider];
dat = { rk.A; rk.n; rk.E; col.key}';

t = uitable('Parent',Hfig,...
            'Units','normalized',...
            'Position',[0.1 0.1 0.9 0.9],...
            'Data', dat,... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...
            'ColumnEditable', columneditable,...
            'RowName',[]);