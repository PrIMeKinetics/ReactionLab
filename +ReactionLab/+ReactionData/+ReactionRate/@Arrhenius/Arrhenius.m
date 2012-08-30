classdef Arrhenius
   
% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.1 $
% Last modified: January 1, 2011

   properties
      A = 0;   % units: mol,cm3,s
      n = 0;
      E = 0;   % units: K
   end
   
   
   methods % constructor
      function arr = Arrhenius(varargin)
         if nargin > 0
            if isa(varargin{1},'System.Xml.XmlElement')
               arr = arr.dom2arr(varargin{1});
            elseif iscell(varargin{1})
               arr = arr.num2arr(varargin{1:2});  % par,rxnOrder
            else
               error(['incorrect class: ' class(varargin{1})]);
            end % if
         end
      end
   end
   
   methods
      function y = isempty(obj)
         y = (obj.A == 0);
      end
      
      function display(arr)
         if length(arr) == 1
            disp(arr)
         else
            table(arr)
         end
      end
   end
   
end