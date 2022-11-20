function y = gate2primeData(varargin)
% function y = gate2primeData(strAction, cellArrArguments)
%
%   for local use
%
% This is the application gateway to PrIMe data. It is an interface
% through which applications can access the data stored in the PrIMe Warehouse
% without having explicit information on the Warehouse structure, file formats,
% or communication protocols.
%
% Input:
% strAction        - char. The operation requested from primeHandle
% cellArrArguments - cell array. The arguments for the requested operation
%
% Output:
% y - requested data. Format dependents on the strAction
%
% examples:
% gate2primeData('getPreferredKey',{'primeID','s00000049'})
% gate2primeData('getPreferredKey',{'primeID','r00001370','rk00000007'})
% gate2primeData('show',{'primeID','r00001370'});
% gate2primeData('show',{'primeID','r00001370','rk00000007'})
% gate2primeData('getDOM',{'primeID','r00001370'});
% gate2primeData('getDOM',{'primeID','r00001370','rk00000007'})
% gate2primeData('getDOM',{'element','Ar'})
% gate2primeData('getBestCurrentId',{'primeID','s00000049','th'}) bc thermo
% gate2primeData('getBestCurrentId',{'primeID','r00001370','rk'}) bc rateCoef
% gate2primeData('getDataFileList', {'primeID','r00001370'})       all files
% gate2primeData('getDataFileList', {'primeID','r00001370','rk'}) only rk
% gate2primeData('getAtticFileList',{'primeID','r00001370','rk'})


% Copyright 2007-2011 primekinetics.org
% Created X. You from Zoran M. Djurisic's code
% Modified: April 30, 2010, myf (added getBestCurrentId)
% Modified:   May 13, 2010, myf (added getDataFileList and getAtticFileList)
% Modified:  July 30, 2011, myf (changed 'thp' to 'th')
% Modified:   Oct  1, 2022, myf ('aguments' to 'args' in function getPath)

NET.addAssembly('System.Xml');
import System.Xml.*;

w = what('Matlab');
localDepository = what(fullfile(fileparts(w(1).path),...
                       'primewarehouse','depository')).path;

if nargin == 0
   y = { 'Current methods are:'
         ' show'
         ' getPreferredKey'
         ' getBestCurrentId'
         ' getDOM'
         ' getDataFileList'
         ' getAtticFileList' };
   return
end
    
action = varargin{1};
if ischar(action)
   switch action
      case 'show'
         filePath = getPath(varargin{2});
         DOMObj = getDOM(filePath);
         xv = PrimeKinetics.PrimeHandle.XmlViewer(DOMObj);
         xv.Show();
         y = '';
      case 'getPreferredKey'
         filePath = getPath(varargin{2});
         DOMObj = getDOM(filePath);
         y = char(PrimeKinetics.PrimeHandle.Data.Common.GetPreferredKey(DOMObj));
      case 'getDOM'
         if strcmpi(varargin{2}{1},'element')
            filePath = fullfile(localDepository,...
               'elements','catalog',[lower(varargin{2}{2}) '.xml']);
         else
            filePath = getPath(varargin{2});
         end
         y = getDOM(filePath);
      case 'getDataFileList'
         var2 = varargin{2};
         [a,b] = fileparts(getPath(var2(1:2)));
         dataDirPath = [fileparts(a) '/data/' b '/'];
%          y = setdiff(list2cell(conn.ListFiles(dataDirPath).result),'_attic/');
         if ~isempty(y) && length(var2) > 2
            y = y(strncmpi(y,var2{3},length(var2{3})));
         end
      case 'getAtticFileList'
         var2 = varargin{2};
         [a,b] = fileparts(getPath(var2(1:2)));
         dataDirPath = [fileparts(a) '/data/' b '/_attic/'];
%          y = list2cell(conn.ListFiles(dataDirPath).result);
         if ~isempty(y) && length(var2) > 2
            y = y(strncmpi(y,var2{3},length(var2{3})));
         end
      case 'getBestCurrentId'
         y = getBestCurrentId(varargin{2}{:});
      otherwise
         error(['undefined action: ' action])
   end
else
   error(['undefined action type: ' class(action)])
end


   function filePath = getPath(varargin)
      args = varargin{1};
      nArgs = length(args);
      if nArgs < 2  ||  ~strcmpi(args{1},'primeID')
         error('undefined input')
      end
      catalog = args{2};   %  catalogName
      s1 = lower(catalog(1));   %  firstLetter
      switch s1
         case 'b'
            cat = 'bibliography';
         case 'e'
            cat = 'elements';
         case 's'
            cat = 'species';
         case 'r'
            cat = 'reactions';
         case 'm'
            cat = 'models';
         case 'd'
            cat = 'datasets';
         case 'x'
            cat = 'experiments';
         case 'a'
            cat = 'dataAttributes';
         otherwise
            error(['undefined catalog ' s1]);
      end
            
      if nArgs == 2
         filePath = fullfile(localDepository,...
                              cat,'catalog',[args{2} '.xml']);
      elseif nArgs == 3
         filePath = fullfile(localDepository,...
                              cat,'data',args{2},[args{3} '.xml']);
      else
         error(['undefined number of args ' int2str(nArgs)])
      end
   end

   function doc = getDOM(filePath)
%       docStr = webread(filePath,weboptions('ContentType','text'));
%       if docStr(1) ~= '<'
%          [~,docStr] = strtok(docStr,'<');
%       end
      doc = System.Xml.XmlDocument;
      doc.LoadXml(filePath);
%       doc.LoadXml(docStr);
%       doc = webread(filePath,weboptions('ContentType','xmldom'));
   end

   function primeId = getBestCurrentId(varargin)
      dataPrimeId = [varargin{3} '00000000'];
      switch varargin{3}
         case 'th'
            filePath = ['depository/species/data/' varargin{2} '/th00000000.xml'];
            doc0 = getDOM(filePath);
            pointerNode = doc0.GetElementsByTagName('thermodynamicDataLink').Item(0);
            primeId = char(pointerNode.GetAttribute('primeID'));
         case 'rk'
            doc0 = ReactionLab.Util.gate2primeData('getDOM',{'primeID',varargin{2},dataPrimeId});
            pointerNode = doc0.GetElementsByTagName('reactionRateLink').Item(0);
            primeId = char(pointerNode.GetAttribute('primeID'));
         otherwise
            error(['undefined file name: ' char(doc0.DocumentElement.Name)]);
      end
   end

   function cellArray = list2cell(list)
   %  convert .NET String list items into cell array
      if isempty(list)
         cellArray = cell(0,1);
      else
         cellArray = cell(list.Length,1);
         for i1 = 1:list.Length
            cellArray{i1} = char(list(i1));
         end
      end
   end

end