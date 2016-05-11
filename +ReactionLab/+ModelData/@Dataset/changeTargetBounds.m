function changeTargetBounds(ds,bndList,prop)
% changeTargetBounds(DatasetObj)
%      display as a table and modify bounds
% changeTargetBounds(DatasetObj,boundsList,prop)
%      change bounds according to the bndList
%      bndList = {trgId lb   up }
%        e.g., {'F2'  log10(0.7)   log10(1.5)
%               'F5'     ''        log10(1.25) }
%      prop is the property of trgId; e.g., 'PrimeId' or 'Key'

% Copyright 2009-2014 primekinetics.org
%       Created:   May 25, 2014, myf
%      Modified:  June 30, 2014, myf, added option bndList
%      Modified:  July  1, 2014, myf, modified followBoundList
% Last modified:  July 24, 2014, myf, clarifying followBoundList

bnds = {'LowerBound' 'UpperBound'};  % used in changeBounds
trg = ds.Targets;
nTrg = length(trg);
lb0 = [trg.LowerBound];
ub0 = [trg.UpperBound];

if nargin > 1
   followBoundList();
end

key = {trg.Key}';
val = [trg.Value]';
data = cell(nTrg,6);
for i1 = 1:nTrg
   data{i1,1} = key{i1};
   data{i1,3} = 10.^val(i1);
   data{i1,5} = data{i1,2}/data{i1,3};  % lb/val
   data{i1,6} = data{i1,4}/data{i1,3};  % ub/val
end

Hfig = figure('Position', [100 200 700 500],...
   'NumberTitle', 'off',...
   'Name', 'Target Bounds',...
   'MenuBar', 'none',...
   'Resize','off',...
   'CloseRequestFcn', @closeWindow );
uicontrol('Parent',Hfig,...
   'Style', 'pushbutton',...
   'Position', [600 400 70 20],...
   'ForegroundColor', 'blue',...
   'BackgroundColor', [0.9 0.9 0.9],...
   'String','Done',...
   'Callback', @done );
uicontrol('Parent',Hfig,...
   'Style', 'pushbutton',...
   'Position', [600 300 70 20],...
   'ForegroundColor', 'blue',...
   'BackgroundColor', [0.9 0.9 0.9],...
   'String','Restore',...
   'Callback', @restore );
    
initialize(trg);

cnames = {'target' 'LB' 'Val' 'UB' 'Lower f' 'Upper f'};
t = uitable('Parent', Hfig, 'Position', [25 25 550 450],...
            'ColumnWidth',{100 'auto' 'auto' 'auto' 'auto' 'auto'},...
            'ColumnName',cnames,'data',data,...
            'ColumnEditable',[false false false false true true],...
            'CellEditCallback', @changeBounds);
waitfor(t)


   function initialize(trg)
      lb  = [trg.LowerBound]';
      ub  = [trg.UpperBound]';
      for i1 = 1:nTrg
         data{i1,2} = 10.^lb(i1);
         data{i1,4} = 10.^ub(i1);
         data{i1,5} = data{i1,2}/data{i1,3};  % lb/val
         data{i1,6} = data{i1,4}/data{i1,3};  % ub/val
      end
   end

   function changeBounds(h,d)
      ind = d.Indices;
      iTrg = ind(1);  jDat = ind(2);
      trg(iTrg).(bnds{jDat-4}) = log10(data{iTrg,3} * d.NewData);
      data{iTrg,jDat} = d.NewData;
      data{iTrg,(jDat - 4)*2} = data{iTrg,3} * d.NewData;
      set(h,'Data',data);
   end

   function done(h,d)
      ds.Targets = trg;
      closereq();
   end

   function restore(h,d)
      trg = ds.Targets;
      for i2 = 1:nTrg
         trg(i2).LowerBound = lb0(i2);
         trg(i2).UpperBound = ub0(i2);
      end
      initialize(trg);
      set(t,'Data',data);
   end

   function closeWindow(h,d)
      restore();
      done();
   end

   function followBoundList()
      trgPropList = {trg.(prop)};
      for i9 = 1:size(bndList,1)
         ind = find(strcmpi(bndList{i9,1},trgPropList));
         if isempty(ind)
            error([bndList{i9,1} ' is not among the targets']);
         end
         lb = bndList{i9,2};   % multiplier to actual value
         ub = bndList{i9,3};   % multiplier to actual value
         if ~isnan(lb)
%             trg(ind).LowerBound = trg(ind).Value + log10(1-lb);
            trg(ind).LowerBound = trg(ind).Value + lb;
         end
         if ~isnan(ub)
%             trg(ind).UpperBound = trg(ind).Value + log10(1+ub);
            trg(ind).UpperBound = trg(ind).Value + ub;
         end
      end
   end

end