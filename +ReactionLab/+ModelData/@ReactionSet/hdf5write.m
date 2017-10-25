function hdf5write(rs,hdf5path)
% hdf5write(ReactionSetObj,hdf5path)
%
% covert ReactionSet object into HDF5

% TO BE REMOVED LATER --- used older syntax
% April 4, 2013, myf


% Copyright 1999-2010 Michael Frenklach
% $Revision: 1 $
% Last modified: May 21, 2010
% Last modified: October 25, 2017, jim: added warning if reaction direction & rate mismatch. 
%


if ~rs.Reactions.isDirectionMatch
    warning(['ReactionSet contains a reaction rate which does not match ', ...
        'the reaction direction.'])
end

hdf5write(hdf5path,'/title',  rs.Title,...
                   '/primeID',rs.PrimeId );

% phase data
hdf5write(hdf5path,'/phaseData/phase',  {'gas'},...
                   '/phaseData/eqState',{'ideal gas'},...
                   'WriteMode', 'append'              );

% species
hdf5write(rs.Species,hdf5path,rs.Elements);

% reactions        
hdf5write(rs.Reactions,hdf5path);