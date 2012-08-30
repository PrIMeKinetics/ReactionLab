classdef Bond < handle
   
% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: February 5, 2012
   
   properties (SetAccess = private)
      From
      To
      Order = [];
      Style = [];
   end
   
   
   methods
      function obj = Bond(f,t,o,s)
         if nargin > 0
            obj.From  = f;
            obj.To    = t;
            obj.Order = o;
            obj.Style = s;
         end
      end
      
      
      function display(obj)
         for i1 = 1:length(obj)
            b = obj(i1);
            disp([b.From.Element '(' int2str(b.From.Id) ')-' ...
                  b.To.Element   '(' int2str(b.To.Id)   ') ' ...
                  ' order=' num2str(b.Order)]);
         end
      end
      
   end
   
end