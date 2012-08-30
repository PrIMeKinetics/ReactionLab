classdef Atom < handle
   
% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.0 $
% Last modified: July 6, 2012
   
   properties (SetAccess = private)
      Id      = '';
      Element = '';
      X       = [];
      Y       = [];
      Z       = [];
   end
   
   properties
      Bonds
      Color = [];
      R     = [];
   end
   
   properties (Dependent = true)
      Coordinates
   end
   
   
   methods
      function obj = Atom(id,elem,x,y,z)
         if nargin > 0
            obj.Id = id;
            obj.Element = elem;
            obj.X = x;
            obj.Y = y;
            obj.Z = z;
         end
      end
      
      
      function y = get.Coordinates(obj)
         y = [obj.X obj.Y obj.Z];
      end
      
      function setCoordinates(obj,x,y,z)
         obj.X = x;
         obj.Y = y;
         obj.Z = z;
      end
      
      function display(obj)
         for i1 = 1:length(obj)
            a = obj(i1);
            disp([a.Element '(' num2str(a.Id) ')   ' num2str(a.Coordinates)]);
         end
      end
      
   end
   
   methods (Static)
      function y = loadElementsData
         elData = load('+ReactionLab\+SpeciesData\+SpeciesStructure\elementsData.mat');
         y = elData.y;
%             [~,~,c] = xlsread('+ReactionLab\+SpeciesData\+SpeciesStructure\elementsData.xlsx');
%             y = [c(:,[1 2]) cellfun(@str2num,c(:,3),'UniformOutput',0)];
      end
   end
   
end