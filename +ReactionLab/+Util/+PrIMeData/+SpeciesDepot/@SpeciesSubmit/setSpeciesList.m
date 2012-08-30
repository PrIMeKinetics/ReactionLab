function setSpeciesList(obj)
% setSpeciesList(SpeciesSubmitObj)
%
%  create a new species based on
%    dictionary analyses

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: April 21, 2012


speIdObj = obj.SpeIdentity;
dictComp = speIdObj.getDictByType('comp');

d = obj.Dict;

speList = ReactionLab.SpeciesData.SpeciesList();
for i1 = 1:size(d,1)
   spe = ReactionLab.SpeciesData.Species();
   spe.Key          = d{i1,1};
   spe.Formulas     = d{i1,1};
   spe.Ids('InChI') = d{i1,4};
   obj.Dict{i1,5} = parseComp(d{i1,1});
   speList = speList.add(spe);
end
obj.SpeList     = speList;
obj.PrevSpeList = speList;

   
   function y = parseComp(speName)
      ind = find(strcmpi(speName,dictComp(:,1)));
      if length(ind) ~= 1
         error('problem with comp dict')
      end
      y = dictComp{ind,2};
      cc = textscan(y,'%s');
      c = sort(cc{1});
      for i2 = 1:length(c)
         c2 = c{i2};
         ii = isletter(c2);
         spe.Elements(i2).symbol = c2(ii);
         spe.Elements(i2).number = str2double(c2(~ii));
      end
   end

end