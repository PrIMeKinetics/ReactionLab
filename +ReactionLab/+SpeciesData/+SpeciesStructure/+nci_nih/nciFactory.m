classdef nciFactory < ReactionLab.SpeciesData.SpeciesStructure.MolGeomFactory
   
% Copyright 1999-2016 Michael Frenklach
% Modified: September 11, 2012
% Modified:       May 18, 2016, myf: updated Url

   
   properties
%       SysAssembly = NET.addAssembly('System');
%       WebClient = System.Net.WebClient;
      Url = 'https://cactus.nci.nih.gov/chemical/structure/';
   end
   
   
   methods
      function obj = nciFactory(molModelObj)
         if nargin > 0
            obj.setGeometry(obj,molModelObj);
         end
      end
      
      function display(obj)
         disp(obj)
%          window(obj)
      end
      
      function setGeometry(obj,molModelObj)
         molModelObj.OutputFormat = 'alc';
         if obj.download(molModelObj)
            obj.alc3d_geom(molModelObj);
         end
         molModelObj.OutputFormat = 'sdf';
         if obj.download(molModelObj)
            obj.sdf2d_geom(molModelObj);
         end
      end
      
      
      function y = download(obj,molModelObj)
         str = [obj.Url '/' molModelObj.InputString '/file?format=' molModelObj.OutputFormat];
         try
%             molModelObj.OutputString = char(obj.WebClient.DownloadString(str));
            molModelObj.OutputString = urlread(str);
            y = 1;
         catch
%             errordlg([molModelObj.InputString ' is not resolved'],'NCI-NIH Resolver','modal');
            y = 0;
         end
      end
      
   end
   
end