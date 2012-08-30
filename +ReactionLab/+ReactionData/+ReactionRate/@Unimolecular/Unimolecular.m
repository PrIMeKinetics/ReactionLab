classdef Unimolecular < ReactionLab.ReactionData.ReactionRate.RateCoefficient

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: January 1, 2011


   properties
      Low
      High
      Falloff
   end


   methods
      function obj = Unimolecular(varargin)
         if nargin > 0
            if isa(varargin{1},'System.Xml.XmlDocument')
               rk = ReactionLab.ReactionData.ReactionRate.Unimolecular();
               obj = rk.dom2rk(varargin{1});
            elseif ischar(varargin{1})  % primeID
               rk = ReactionLab.ReactionData.ReactionRate.Unimolecular();
               rkDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',varargin{1:2}});
               obj = rk.dom2rk(rkDoc);
            else
               error(['incorrect class: ' class(varargin{1})]);
            end % if
         end
      end
      
      function y = isempty(obj)
         y = ( isempty(obj.Low) || isempty(obj.High) || isempty(obj.Falloff) );
      end
   end

end