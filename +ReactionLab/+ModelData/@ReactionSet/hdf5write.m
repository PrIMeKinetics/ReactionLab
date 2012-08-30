function hdf5write(rs,hdf5path)
% hdf5write(ReactionSetObj,hdf5path)
%
% covert ReactionSet object into HDF5

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1 $
% Last modified: May 21, 2010

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