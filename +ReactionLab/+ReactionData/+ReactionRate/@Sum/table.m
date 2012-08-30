function t = table(rk)
%t = table(SumObj)

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.1 $
% Last modified: May 7, 2010

rkCellArray = rk.Values;
if isSameClass(rk)
   t = table([rkCellArray{:}]);
   return
end

Hfig = figure('Position',[100 100 400 150]);

columnname =   {'A' 'n' 'E (cal/mol)' 'Collider' 'Class'};
columnformat = {'numeric' 'numeric' 'numeric' 'char'};
columneditable =  [false false false false];

numRKs = length(rkCellArray);
A = cell(1,numRKs);
n = cell(1,numRKs);
E = cell(1,numRKs);
col = cell(1,numRKs);
rkClass = cell(1,numRKs);
for i1 = 1:numRKs
   k = rkCellArray{i1};
   A{i1} = k.A;
   n{i1} = k.n;
   E{i1} = k.E;
   if     isa(k,'ReactionLab.ReactionData.ReactionRate.ThirdBody')
      rkClass{i1} = 'third body';
      col{i1} = k.Collider.key;
   elseif isa(k,'ReactionLab.ReactionData.ReactionRate.MassAction')
      rkClass{i1} = 'mass action';
   else
      error(['undefined yet class: ' class(k)]);
   end
end

dat = [ A; n; E; col; rkClass]';

t = uitable('Parent',Hfig,...
            'Units','normalized',...
            'Position',[0.1 0.1 0.9 0.9],...
            'Data', dat,... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...
            'ColumnEditable', columneditable,...
            'RowName',[]);