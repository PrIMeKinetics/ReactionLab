function [y,varargout] = mmap(c,action,varargin)
%newStructure = MMAP(structure, action, element or index)
%     Performs operations on structures
%
% c  is a structure
%
%    (c, 'clear')       reinitializes the structure c
%    (c, 'isempty')     return 1 if true, 0 otherwise
%    (c, 'display')     displays c as a table
%    (c, 'sort')        sort c according to the first field
%    (c, 'sort',field)  sort c according the field speciefied
%[el, index] =
%MMAP(c, 'get', key)    get el of c with key, [] if not present
%    (c, 'getField', index)    get c.field(index)
%    (c, 'add', el)     replace if key present, insert otherwise
%    (c, 'append', el)  append el to c
%    (c, 'insert', el)  append and sort
%    (c, 'replace', el) replace el if key present
%    (c, 'remove', el/key) remove el/c(el) and clear if last
%    (c, 'ismember', el/key) true if key is present in c

% Copyright 1999-2007 Michael Frenklach
% $Revision: 1.1 Modified April 18, 2006 myf$

if nargin==0
   error('incorrect number of arguments')   
end
if ~isstruct(c)
   error('the first argument is not a structure')
end
if nargin==1, action = 'display'; end

switch lower(action)
   case {'clear' 'erase' 'empty' 'init'}
      y = LOCAL_init(c);
   case 'isempty'
      y = LOCAL_isEmpty(c);
   case {'display' 'show' 'type'}
      LOCAL_display(c)
   case 'sort'
      if nargin==2, y = LOCAL_sort(c,1);
      else          y = LOCAL_sort(c,varargin{1}); end
   case 'get'
      [y,i] = LOCAL_get(c,varargin{1});
      varargout{1} = i;
   case 'getfield'
      y = LOCAL_getField(c,varargin{:});
   case 'add'
      y = LOCAL_add(c,varargin{1});
   case 'append'
      y = LOCAL_append(c,varargin{1});
   case 'insert'
      y = LOCAL_insert(c,varargin{1});
   case 'replace'
      y = LOCAL_replace(c,varargin{1});
   case {'remove' 'rem' 'delete' 'del',}
      y = LOCAL_remove(c,varargin{1}); 
   case {'ismember' 'isthere'}
      y = LOCAL_ismember(c,varargin{1});
otherwise
   error(['unknown option',option])
end
return


function y = LOCAL_init(c)
   fields = fieldnames(c);
   for i=1:length(fields)
      f = LOCAL_getField(c(1),i);
      switch class(f{1})
         case 'char',   el = '';
         case 'double', el = [];
         case 'cell',   el = {};
         otherwise
            el = [];
      end
      y.(fields{i}) = el;
   end
return


function y = LOCAL_isEmpty(c)
   f1 = LOCAL_getField(c,1);
   y = ( length(c)==1 & isempty(f1{1}) );
return


function LOCAL_display(c)
   fields = fieldnames(c)';
   n = length(fields);
   symbol = '-';
   line = symbol(ones(1,n*10));
   fprintf('%s\n',line)
   disp(fields)
   fprintf('%s\n',line)
   for i=1:length(c)
      s = {};
      for j=1:n
         s1 = LOCAL_getField(c(i),j);
         s = [s s1];
      end
      disp(s)
   end
   fprintf('%s\n',line)
return


function [y,index] = LOCAL_get(c,key)
   index = LOCAL_getIndex(c,key);
   if isempty(index), y = [];
   else               y = c(index); end
return


function y = LOCAL_getField(c,index,mode)
   if nargin < 3, mode = 'cell'; end
   fields = fieldnames(c);
   switch lower(mode)
      case 'cell'
         y = {c.(fields{index})};
      case {'num' 'numeric' 'number'}
         y = [c.(fields{index})];
      otherwise
         error(['undefined mode ', mode])
   end
return


function [index,key] = LOCAL_getIndex(c,el)
   key = LOCAL_getKey(el);
   if isnumeric(key)
      keyList = LOCAL_getField(c,1,'num');
      index = find(keyList==key);
   else
      keyList = LOCAL_getField(c,1,'cell');
      index = find(strcmpi(keyList,key));
   end
return


function key = LOCAL_getKey(el)
   if isstruct(el), key = LOCAL_getField(el,1);
   else             key = el;               end
return


function y = LOCAL_add(c,el)
   if LOCAL_ismember(c,el), y = LOCAL_replace(c,el);
   else                     y = LOCAL_insert(c,el); end
return


function y = LOCAL_append(c,c1)
   if     LOCAL_isEmpty(c),   y = c1;
   elseif LOCAL_isEmpty(c1),  y = c;
   else                       y = [c c1];
   end
return


function y = LOCAL_insert(c,el)
   y = LOCAL_sort(LOCAL_append(c,el));
return


function y = LOCAL_replace(c,el)
   y = c;
   index = LOCAL_getIndex(c,el);
   if ~isempty(index), y(index) = el; end
return


function y = LOCAL_remove(c,el)
   if isnumeric(el), index = el;
   else              index = LOCAL_getIndex(c,el); end
   if isempty(index)
      y = c;
   else
      y = LOCAL_removeByIndex(c,index);
   end
return


function y = LOCAL_removeByIndex(c,index)
   if length(c)==1
      y = LOCAL_init(c);   % clear if last
   else
      j = 1:length(c);
      j(index) = [];
      y = c(j);
   end
return


function y = LOCAL_ismember(c,el)
   x = LOCAL_get(c,el);
   if isempty(x), y = 0;
   else           y = 1; end
return


function y = LOCAL_sort(c,givenField)
   y = c;
   n = length(c);
   if n==1, return, end   % only one element in c
   fields = fieldnames(c);  % list of c fields
   if nargin==1
      index = 1;
   elseif isa(givenField,'char')
      index = find(strcmp(fields,givenField));
   elseif isa(givenField,'double')
      index = givenField;
   else
      error(['the argument is neither char or number: ',givenField])
   end
   firstKey = LOCAL_getField(c(1),index);
   if isa(firstKey{1},'char')
      s = LOCAL_getField(c,index,'cell');
      [z,j] = sortrows(char(s));
   elseif isa(firstKey{1},'double')
      x = LOCAL_getField(c,index,'num');
      [z,j] = sort(x);
   else
      error('not a char or a number')
   end
   y = c(j);
return