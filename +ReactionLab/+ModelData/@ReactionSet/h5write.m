function h5write(rs,h5path)
% h5write(ReactionSetObj,h5path)
%
% covert ReactionSet object into HDF5

% Copyright 1999-2013 Michael Frenklach
% Created:        May 21, 2010, myf
% Last modified: April 4, 2013, myf: changed hdf5 to h5
% Last modified: October 25, 2017, jim: added warning if reaction direction & rate mismatch. 
%

if ~rs.Reactions.isDirectionMatch
    warning(['ReactionSet contains a reaction rate which does not match ', ...
        'the reaction direction.'])
send

h5write(h5path,'/title',  rs.Title,...
               '/primeID',rs.PrimeId );

% phase data
h5write(h5path,'/phaseData/phase',  {'gas'},...
               '/phaseData/eqState',{'ideal gas'},...
               'WriteMode', 'append'               );

% species
h5write(rs.Species,h5path,rs.Elements);

% reactions        
h5write(rs.Reactions,h5path);