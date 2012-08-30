classdef Nasa9 < ReactionLab.ThermoData.Nasa7
% NASA 9-coefficient polynomials
   
% Copyright 1999-2008 Michael Frenklach
% $Revision: 1.0 $
% Last modified: November 19, 2008

   properties
      Phase         = '';
      ReferenceCode = '';
   end

   
   methods
      function obj = Nasa9(arg)
         if nargin > 0
            if ischar(arg) && strcmpi(arg,'load')
               filePath = ReactionLab.Util.getFile('Nasa 9-coef thermo');
               obj = readNasa9(obj,filePath);
            elseif isa(arg,'org.apache.xerces.dom.DeferredDocumentImpl')
             % obj = dom2thermo(obj,arg);
            else
               error(['incorrect object class: ' class(arg)])
            end % if
         end % if
      end % constructor
   end  % constructor methods section

end