classdef Nasa7 < ReactionLab.ThermoData.Thermo
% NASA 7-coefficient polynomials
%
%   Nasa7obj = Nasa7()
%   Nasa7obj = Nasa7.loadTxt(fileTxt)
%   Nasa7obj = Nasa7.load()
%   Nasa7obj = Nasa7.load(filePath)
%   Nasa7obj = Nasa7.loadXml(filePath)
%   Nasa7obj = Nasa7.loadDoc(XmlDocumentObj)
   
% Copyright 1999-2012 Michael Frenklach
% Last modified: December 2, 2012

   properties
      SpeciesKey = '';
      SpeciesId  = '';
      SpeciesElements = struct('symbol','','number',[]);
      DeltaHf    = [];
   end
   
   properties (SetAccess = 'protected')
      Data = struct('Trange',[],'coef',[]);
   end
   
   methods
      function obj = Nasa7(arg)
         if nargin > 0
            if isa(arg,'char')
               obj = ReactionLab.ThermoData.Nasa7.load(arg);
            elseif isa(arg,'System.Xml.XmlDocument')
               obj = ReactionLab.ThermoData.Nasa7.loadDoc(arg);
            else
               error(['incorrect class: ' class(arg)]);
            end % if
         end % if
      end % constructor
   end  % constructor methods section
   
   
   methods
      function y = findTrange(obj)
         dd = [obj.Data];
         allBounds = [dd.Trange];
         y = [min(allBounds) max(allBounds)];
      end
      [y,t,prop] = eval(obj,T,prop)
      function [y,t,u] = h(obj,T,units)
         [y,t,prop] = obj.eval(obj,T,{'h' units});
         u = prop{1,2};
      end
      function [y,t,u] = cp(obj,T,units)
         [y,t,prop] = obj.eval(obj,T,{'cp' units});
         u = prop{1,2};
      end
      function [y,t,u] = s(obj,T,units)
         [y,t,prop] = obj.eval(obj,T,{'s' units});
         u = prop{1,2};
      end
   end
   
   methods (Static)
      y = readBurcat_thr(filePath)
      y = dom2thermo(docObj)
      thArray = readNasa7(text,fileName)
      function thArray = parseTxt(fileTxt,fileName)
         thArray = ReactionLab.ThermoData.Nasa7.readNasa7(fileTxt,fileName);
         for i1 = 1:length(thArray)
            thArray(i1).Trange = findTrange(thArray(i1));
         end
      end
      function [y,fileName] = load(filePath)
         if nargin == 0 || isempty(filePath)
            [str,fileName] = ReactionLab.Util.getTextFile('Nasa7 Thermo');
         else
            [str,fileName] = ReactionLab.Util.getTextFile('',filePath);
         end
         if isempty(str)
            y = [];
         else
            y = ReactionLab.ThermoData.Nasa7.readNasa7(str,fileName);
         end
      end
      function y = loadXml(filePath)
         if nargin == 0
            filePath = ReactionLab.Util.getFile('Nasa7 Thermo XML');
            if isempty(filePath)
               y = []; return
            end
         end
         doc = System.Xml.XmlDocument;
         y = loadDoc(doc.LoadXml(filePath));
      end
      function y = loadDoc(docObj)
         if ~isempty(docObj) && isa(docObj,'System.Xml.XmlDocument')
            y = ReactionLab.ThermoData.Nasa7.dom2thermo(docObj);
            y.Trange = findTrange(y);
         else
            y = [];
         end
      end
   end
   
end