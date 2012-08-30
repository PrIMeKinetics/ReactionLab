function arr = num2arr(arr,par,rxnOrder)
% ArrheniusObj = num2arr(arrheniusParametersCell,rxnOrder)
%
%  arrPar = { 'a' aValue aUnits ;...
%             'n' nValue  ''    ;...
%             'e' eValue eUnits   };

% Copyright 2005-2010 Michael Frenklach
% $ Revision 1 $
% Last modified May 12, 2010


for i1 = 1:size(par,1)
   localSetParameter(par(i1,:));
end


   function localSetParameter(parRec)
   % parse single parameter of arrhenius expression of DOM node
      name  = parRec{1};
      value = parRec{2};
      units = parRec{3};
      switch lower(name)
         case 'a'
            c = textscan(units,'%s','delimiter',',');
            s = c{1};
            if    strncmpi(s{1},'cm',2) && ...
               any(strcmpi(s{2},{'mol' 'mole'})) && ...
                   strcmpi(s{3},'s')
                arr.A = value;
            else
               units = {[s{1} '/' s{2}],s{3}};
               arr.A = ReactionLab.Units.conv_rate(value,units,{'cm3/mol','s'},rxnOrder);
            end
         case 'n'
            arr.n = value;
         case 'e'
            arr.E = value./ReactionLab.PhysConst.UnivR(units);
         otherwise
            error(['undefined parameter: ' name])
      end
   end

end