function chemkinFile = readChemkinFile(fileName)
% chemkinData = readChemkinFile(fileNamee)
%
% read Chemkin-formatted reaction mechanism file
%    and return the data as a Matlab struc/cell arrays
%
% Conforms to Chemkin 3.5, except:
% '+' cannot be used in species names
% '&' cannot be used to continue line
% Option 'UNITS' is not implemented
% Options 'LT', "TDEP' and 'XSMI' are not implemented

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.1 $
% Last modified: November 29, 2010

elemCell = {};
speCell  = {};
rxnCell  = {};

% read Chemkin file
iRec = 0;
dirOfFile = dir(which(fileName));
numBytes = dirOfFile.bytes;
[~,name,ext] = fileparts(fileName);
strName = strrep(name,'_','\_');
Hwait = waitbar(0,['Loading   ' strName ext]);

fid = fopen(fileName,'rt');
part = '';     % 'elem' | 'species' | 'rxns';
while ~feof(fid)
   line = fgetl(fid);
   line = strtrim(line);
   if isempty(line) || line(1)=='!'
   elseif strncmpi(line,'ELEM',4) || strcmp(part,'elem')
      readElements(line);
   elseif strncmpi(line,'SPEC',4) || strcmp(part,'species')
      readSpecies(line);
   elseif strncmpi(line,'REAC',4) || strcmp(part,'rxns')
      readReactions(line);
      break;
   elseif strncmpi(line,'END',3)
      if     strcmp(part,'elem'),    part = 'species';
      elseif strcmp(part,'species'), part = 'rxns';
      else   break;
      end
   else
      error(['incorrect input line: ' line])
   end
end
fclose(fid);
close(Hwait);

chemkinFile.title = name;
chemkinFile.elemCellArray = elemCell;
chemkinFile.speCellArray  = speCell;
chemkinFile.rxnCellArray  = rxnCell;


   function readElements(line)
   % unpack element line
      part = 'elem';    % continue looking for elements
      line = strtok(line,'!'); % remove comments if any
      if strncmpi(line,'ELEM',4)
         [~,line] = strtok(line);  % remove keyword
         if isempty(line), return, end
      end
      ind = strfind(upper(line),'END');
      if ind
         line = line(1:ind-1); % cut off 'END'
         part = 'species';     % next is species input
         if isempty(line), return, end
      end
      ss = textscan(line,'%s');  % convert line into cell array
      elemCell = [elemCell ss{:}'];
   end


   function readSpecies(line)
   % unpack species line
      part = 'species';   % continue looking for species
      line = strtok(line,'!'); % remove comments if any
      if strncmpi(line,'SPEC',4)
         [~,line] = strtok(line);  % remove keyword
         if isempty(line), return, end
      end
      ind = strfind(upper(line),'END');
      if ind
         line = line(1:ind-1); % cut off 'END'
         part = 'rxns';     % next is reaction input
         if isempty(line), return, end
      end
      ss = textscan(line,'%s');   % covert line into cell array
      speCell = [speCell ss{:}'];
   end


   function readReactions(line)
   % unpack individual reaction line(s)
      line = strtok(line,'!'); % remove comments if any
      if strncmpi(line,'REAC',4)
         [~,line] = strtok(line);  % remove REAC keyword
      end
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
      kUnits = ReactionLab.Units;
      kUnits.Conc   = cUnits;
      kUnits.Time   = 's';
      kUnits.Energy = eUnits;
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
         iRec = iRec + 1;
         waitbar(iRec*70/numBytes,Hwait,...
                  ['Loading   ' strName ': ' num2str(iRec) ' records']);
      end
   end

end