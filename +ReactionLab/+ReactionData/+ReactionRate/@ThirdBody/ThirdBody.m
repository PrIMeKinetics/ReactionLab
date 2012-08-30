classdef ThirdBody < ReactionLab.ReactionData.ReactionRate.MassAction

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: January 1, 2011

% Property 'Order' is inhereted from the MassAction class
%   but defined as ThirdBodyRK.Order = Reaction.Order + 1


   properties
      Collider = struct('key','','primeId','');
   end


   methods
      function obj = ThirdBody(varargin)
         if nargin > 0
            if isa(varargin{1},'System.Xml.XmlDocument')
               rk = ReactionLab.ReactionData.ReactionRate.ThirdBody();
               rk.Order = varargin{2} + 1;  %  rk.Order = rxn.Order + 1
               obj = rk.dom2rk(varargin{1});
            elseif ischar(varargin{1})  % primeID
               rk = ReactionLab.ReactionData.ReactionRate.ThirdBody();
               if length(varargin) > 2
                  rk.Order = varargin{2} + 1;  %  rk.Order = rxn.Order + 1
                  rkDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',varargin{1:2}});
                  obj = rk.dom2rk(rkDoc);
               else
                  rkDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',varargin{1:2}});
                  rxn = ReactionLab.ReactionData.Reaction(varargin{1});
                  rk.Order = rxn.Order + 1;
                  obj = rk.dom2rk(rkDoc);
               end
            else
               error(['incorrect class: ' class(varargin{1})]);
            end % if
         end
      end
   end

end