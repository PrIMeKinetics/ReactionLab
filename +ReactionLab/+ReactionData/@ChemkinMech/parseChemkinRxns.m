function parseChemkinRxns(obj)
% parseChemkinRxns(ChemkinMechObj)
%
% read Chemkin-formatted reaction set mechanism
%
% Conforms to Chemkin 3.5, except:
% '+' cannot be used in species names
% '&' cannot be used to continue line
% Option 'UNITS' is not implemented
% Options 'LT', "TDEP' and 'XSMI' are not implemented

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.1 $
% Last modified: November 23, 2011

rxnCell  = {};

kUnits = ReactionLab.Units;

rxnTxt = obj.ReactionTxt;
nLines = length(rxnTxt);

iRec = 0;  j1 = 0;
strName = strrep(obj.MechFileName,'_','\_');
Hwait = waitbar(0,['Parsing reactions of  ' strName ext]);
while j1 < nLines
   j1 = j1 + 1;  nextLine = rxnTxt{j1};
   if isempty(nextLine) || nextLine(1)=='!'  % skip
   elseif strncmpi(nextLine,'REAC',4)
      readFirstLine(nextLine);
   elseif strncmpi(nextLine,'END',3)
      break
   else
      j1 = readReaction(nextLine,j1);
   end
   waitbar(j1/nLines,Hwait,['Parsing reactions of  ' strName]);
end
close(Hwait);

chemkinFile.title = name;
chemkinFile.elemCellArray = elemCell;
chemkinFile.speCellArray  = speCell;
chemkinFile.rxnCellArray  = rxnCell;


   function readFirstLine(line)
      line = strtok(line,'!'); % remove comments if any
      [~,line] = strtok(line);  % remove REAC keyword
      % check if units are specified
      eUnits = 'cal/mol';     %  energy units
      cUnits = 'cm3/mol';     %  conc   units
      while ~isempty(line)
         [s,line] = strtok(line);
         switch upper(s)
            case {'CAL/MOLE','CAL/MOL'}
               eUnits = 'cal/mol';
            case {'KCAL/MOLE','KCAL/MOL'}
               eUnits = 'kcal/mol';
            case {'JOULES/MOLE','JOULES/MOL'}
               eUnits = 'J/mol';
            case {'KJOULES/MOLE','KJOULES/MOL'}
               eUnits = 'kJ/mol';
            case {'KELVINS','K'}
               eUnits = 'K';
            case {'EVOLTS','E'}
               eUnits = 'eV';
            case {'MOLES'}
               cUnits = 'cm3/mol';
            case {'MOLECULES'}
               cUnits = 'cm3';
            otherwise
               error(['undefined units ' s])
         end
      end
      kUnits.Conc   = cUnits;
      kUnits.Time   = 's';
      kUnits.Energy = eUnits;
   end


   function jj = readReaction(line,jj)
   % loop through reaction lines
      
   
   
   
      lines = {};
      while ~feof(fid)
         line = fgetl(fid);
         line = strtrim(line);
         if isempty(line) || strcmp(line,'!')
         elseif strncmpi(line,'END',3)
            rxnCell = [rxnCell; {lines}];
            break;
         else
            if any(strfind(line,'!')) || ...
                   any(strfind(line,'/')) || ...
                   any(strfind(upper(line),'DUPLICATE'))  % additional data
                if isempty(lines)
                   error('adding an additional line to an empty line');
                else
                  lines = [lines; {line}];
                end
            else
               if isempty(lines)
                  lines = {line};    % start new reaction-equation line
               else
                  rxnCell = [rxnCell; {lines}];
                  lines = {line};
               end
            end
         end
%          iRec = iRec + 1;
%          waitbar(iRec*70/numBytes,Hwait,...
%                   ['Loading   ' strName ': ' num2str(iRec) ' records']);
      end
   end

end