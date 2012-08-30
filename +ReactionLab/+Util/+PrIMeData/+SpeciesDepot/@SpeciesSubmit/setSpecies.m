function setSpecies(obj)
% setSpecies(SpeciesSubmitObj)
%
%  update species based on
%    the table entries

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: August 10, 2012


spe = obj.CurrentSpecies;

% spe = ReactionLab.SpeciesData.Species();
% spe.Key          = curSpe.Key;
% spe.Formulas     = curSpe.Formulas;
% spe.Ids('InChI') = curSpe.Ids('InChI');

dat = get(obj.Table,'Data');

for i1 = 1:size(dat,1)
   if isempty(dat{i1,2})
      dat{i1,2} = 'name';
   end
   switch lower(dat{i1,2})
      case 'formula'
         spe.Formulas = dat{i1,1};
      case 'name'
         spe.Names    = dat{i1,1};
      case 'inchi'
      otherwise
         spe.Ids(dat(i1,2)) = dat{i1,1};
   end
end

% obj.CurrentSpecies = spe;
% obj.PrevSpeList = obj.SpeList;
% obj.SpeList = replace(obj.SpeList,'key',spe.Key,spe);