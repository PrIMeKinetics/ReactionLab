function y = readBurcat_thr(fileName)
%y = readBurcat_thr(fileName)
%
% read NASA-type (7-coefficient) polynomials
%   from THERMO.THR file;
%   create and return Nasa7 object

% Copyright 1999-2011 Michael Frenklach
% $Revision: 1.0 $
% Last modified: June 18, 2011


spe2skip = {'AIR' 'JET-A' 'KNO3'};  %  KNO3 record has a typo 
                                    %   in one of the numbers

y.time = '';
spe = struct('casNo', '', ...
             'key',   '', ...
             'names', {}, ...
             'thermo',[]   );
y.spe = spe;
                                    
fid = fopen(fileName,'rt');
if fid < 0
   error(['file ' fileName ' couldn''t be open'])
end
% fseek(fid, 0, 'eof');
% numBytes = ftell(fid);
% frewind(fid);
c = textscan(fid,'%s','delimiter', sprintf('\n'));
fclose(fid);
strArray = strtrim(c{1});
nLines = length(strArray);

[~,name,ext] = fileparts(which(fileName));
Hwait = waitbar(0,['Loading   ' name ext ]);

for j1 = 1:nLines
   line = strArray{j1};
   if strncmpi(line,'The Database was last updated on',32)
      % check the difference in the date line
      y.time = strtrim(line(33:end));
%       disp(y.time)
      break
   end
   waitbar(j1/nLines,Hwait,['Loading   ' name ext]);
end

for j2 = j1:nLines
   line = strArray{j2};
   if strncmpi(line,'THE NUMBER PRECEDING',20)
      % get to the beginning of the data records
      j3 = j2;
      break
   end
   waitbar(j2/nLines,Hwait,['Loading   ' name ext]);
end

th0 = ReactionLab.ThermoData.Nasa7();
th0.DataRef = name;
% thArray = ReactionLab.ThermoData.Nasa7.empty(1,0);
iRec = 0;
while j3 < nLines
   j3 = j3 + 1; line = strArray{j3};
   if isempty(line)        % next record boundary
      while isempty(line)  % now look for the first nonempty line
         j3 = j3 + 1;  line = strArray{j3};
      end
      j3 = readInfoLines(line,j3);
   end
   waitbar(j3/nLines,Hwait,['Loading   ' name ext]);
end
close(Hwait);


   function jj = readInfoLines(line,jIn)
   % the the lines preceding the data lines
      jj = jIn;
      casNo = strtok(line,' ');
      if strncmpi(casNo,'Troughout',9)
         jj = nLines;
         return
      end
      jj = jj + 1;  line = strArray{jj};
      speKey = strtok(line,' ');
      if any(strcmpi(speKey,spe2skip))
         return;
      end
      while jj < nLines
         jj = jj + 1;  line = strArray{jj};
         fl = fliplr(line);
         if isempty(line)
%             disp([speKey ' no record'])
            jj = jIn;
            return
         elseif strcmp(fl(1:2),'1 ') % the first line of the coefs
            len = length(line);
            if len ~= 80
               line0 = line;
               if len < 50 || len > 90  % probably is not the first line
                  jj = jIn;
                  return
               elseif len == 81    % just 1 space over: remove 1 space
                  line(69) = [];
               elseif len < 80     % probably uses tabs: replace them with 3 ' '
                  line = regexprep(line,'\t','   ');
                  if length(line) < 80  % replacing tabs is still not enough
                     je = strfind(line,' ');  je1 = je(1);
                     line = [line(1:je1) repmat(' ',1,80-length(line)) line(je+1:end)];
                     if length(line) > 80
                        line = extraTrim(line0);
                     end
                  elseif length(line) > 80
                     line = extraTrim(line0);
                  else
%                      disp(line0), disp(length(line0))
%                      error('the line is not 80-column wide')
                  end
               else
                  disp(line0), disp(length(line0))
                  error('the line is not 80-column wide')
               end
            end
            iRec = iRec + 1;
            spe(iRec).casNo = casNo;
            spe(iRec).key   = speKey;
            spe(iRec).names = {};
            spe(iRec).thermo = readRecord(line);
            if isempty(strArray{jj+1}) || strcmp(strArray{jj+1},'`')
               strArray{jj+1} = '';
               return
            end
         end
         y.spe = spe;
      end
      
      
         function str = extraTrim(str)
         % if replacing tabs makes line longer than 80
            indTab = regexp(str,'\t');
            indTab1 = indTab + 1;    % check if there is a space after tab
            str(indTab1(str(indTab1) == ' ')) = []; % and remove them
            str = regexprep(str,'\t','   ');
            if length(str) ~= 80
               disp(line0), disp(length(line0))
               error('the line is not 80-column wide')
            end
         end
      
         function th = readRecord(line)
         % read a species record
            th = th0;
            th.SpeciesKey = strtok(strjust(line(1:18),'left'),' ');
            th.Comment = strtrim(line(19:24));
            el = struct('symbol',{},'number',{});
            for i1 = 1:4
               ii = 20 + 5*i1;
               el = parseElem(line(ii:ii+4));
            end
            th.SpeciesElements = el;
            c = textscan(line(46:73),'%f');  limits = c{:}';
            n = length(limits);
            if n == 3
               minT    = limits(1);
               maxT    = limits(2);
               middleT = limits(3);
            elseif n == 2
               minT    = limits(1);
               maxT    = limits(2);
               middleT = 1000;
            else
               error('incorrect number of T limits')
            end
            poly(1).Trange = [minT middleT];
            poly(2).Trange = [middleT maxT];
            jj = jj + 1;  line = strArray{jj};
            c = textscan(line,'%f',5);  coefs = c{1}';
            jj = jj + 1;  line = strArray{jj};
            c = textscan(line,'%f',5);  coefs = [coefs c{1}'];
            jj = jj + 1;  line = strArray{jj};
            c = textscan(line,'%f',5);  lastLine = c{1}';
            coefs = [coefs lastLine(1:4)];
            try
               if lastLine(5) ~= 4
                  th.DeltaHf = lastLine(5);
               end
            end
            poly(1).coef = coefs(8:14);   %  minT    to middleT
            poly(2).coef = coefs(1:7);    %  middleT to highT
            th.Data = poly;


               function parseElem(str)
               % check and read-in elements (2a1,i3)
                  elem.symbol = strtrim(str(1:2));
                  if ~isempty(elem.symbol) && all(isletter(elem.symbol))
                     elem.number = str2double(str(3:5));
                     el = [el elem];
                  end
               end

         end
         
   end

end