classdef PrIMeAuthentication < handle
   
% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: March 15, 2012

   properties (SetAccess = protected)
      PrimeHandleFulin = NET.addAssembly(which('+ReactionLab\+Util\PrimeHandle.dll'));
      HTTP     = PrimeKinetics.PrimeHandle.Utils.HTTPWorker();
      Utils    = PrimeKinetics.PrimeHandle.Utils.Utils;
      a = NET.addAssembly(which('NetRL.dll'));
%       LoginForm = NetRL.LoginForm();
      Username = '';
      Password = '';
      IsMember = false;
      Roles    = {};
   end
      
      
   methods
      function obj = PrIMeAuthentication(un,pw)
         if nargin > 0
            obj.authenticate(un,pw);
         end
      end
      
      function authenticate(obj,un,pw)
         [y,r] = checkMembership(obj,un,pw);
         if y
            obj.IsMember = true;
            obj.Roles    = r;
            obj.Username = un;
            obj.Password = pw;
         else
            f = NetRL.LoginForm;
            f.ShowDialog;
%             f.Show;  keyboard
            if f.EventStatus
               obj.authenticate(char(f.Username),char(f.Password));
            else
               obj.IsMember = false;
               obj.Roles    = {};
               obj.Username = '';
               obj.Password = '';
            end
         end
      end
   end
    
end