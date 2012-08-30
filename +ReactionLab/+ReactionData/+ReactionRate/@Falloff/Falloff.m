classdef Falloff

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: January 1, 2011


   properties
      Type = '';
      Data = []
   end


   methods
      function obj = Falloff(arg)
         if nargin > 0
            if isa(arg,'System.Xml.XmlElement')
               obj = ReactionLab.ReactionData.ReactionRate.Falloff.dom2falloff(arg);
            else
               error(['incorrect class: ' class(arg)]);
            end % if
         end
      end
   end
   
   methods (Static)
      foObj = dom2falloff(pDepndNode)
   end

end