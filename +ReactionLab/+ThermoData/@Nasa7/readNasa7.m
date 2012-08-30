function thArray = readNasa7(strArray,fileName)
% Nasa7ObjArray = readNasa7(text,fileName)
%
% read NASA-type (7-coefficient) polynomials
%   create and return Nasa7 object

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: February 11, 2012

nLines = length(strArray);

th0 = ReactionLab.ThermoData.Nasa7();
strName = strrep(fileName,'_','\_');
th0.DataRef.key = 'fileName';
th0.DataRef.id  = strName;

iRec = 0;  j1 = 0;
Hwait = waitbar(0,['Loading   ' strName]);
thArray = ReactionLab.ThermoData.Nasa7.empty(1,0);
while j1 < nLines
   j1 = j1 + 1;  line = strArray{j1};
   if isempty(line) || line(1)=='!'
   elseif strncmpi(line,'THERMO',6)
      j1 = j1 + 1; line = strArray{j1};
      c = textscan(line,'%f',3);  limitTemp = c{:}';
   elseif strncmpi(line,'END',3)
      break
   else
      j1 = readThermoRecord(line,j1);
      waitbar(j1/nLines,Hwait,['Loading   ' strName]);
   end
end
close(Hwait);


   function jj = readThermoRecord(line,jj)
   % read a species record
      th = th0;
%       th.SpeciesKey = strtrim(line(1:18));
      th.SpeciesKey = strtok(strtrim(line(1:18)));
      th.Comment = strtrim(line(19:24));
      el = struct('symbol',{},'number',{});
      for i1 = 1:4
         ii = 20 + 5*i1;
         parseElem(line(ii:ii+4));
      end
      th.SpeciesElements = el;
      c = textscan(line(46:73),'%f');  limits = c{:}';
      n = length(limits);
      if n==3
         minT    = limits(1);
         maxT    = limits(2);
         middleT = limits(3);
      elseif n==2
         minT    = limits(1);
         maxT    = limits(2);
         middleT = limitTemp(2);
      else
         minT    = limitTemp(1);
         maxT    = limitTemp(3);
         middleT = limitTemp(2);
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
      iRec = iRec + 1;
      thArray(iRec) = th;
      

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