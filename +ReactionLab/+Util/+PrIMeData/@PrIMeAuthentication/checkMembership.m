function [y,roles] = checkMembership(obj,userName,userPassword)
% [true/false,roles] = checkMembership(PrIMeAuthenticationObj,username,password)

% Copyright 2009-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: March 14, 2012

if nargin == 1
   userName     = obj.Username;
   userPassword = obj.Password;
end


http = obj.HTTP;
http.Url = PrimeKinetics.PrimeHandle.Config.GetDrupalUsersUrl();
http.Type = PrimeKinetics.PrimeHandle.Utils.HTTPRequestType.Post;
http.AddValue('username',userName);
utilsObj = obj.Utils;
md5 = utilsObj.GetMd5Sum(System.String(userPassword)).ToLower();
http.AddValue('password_md5', md5);
http.AddValue('form_id', 'user_login');
http.AddValue('op', 'Log in');
rsp = http.SendRequest;
parseResponse(char(http.ResponseText));


   function parseResponse(s)
      [a,r] = strtok(s);
      [~,b] = strtok(a,':');    %  login:...
      b(1) = [];  % remove ':'
      y = logical(str2num(b));
      roles = {};
      if y
         cc = textscan(strtrim(r),'%s','delimiter',';');
         c1 = cc{1};
         ii = strfind(c1,':');
         for i1 = 1:length(ii)
            ci = c1{i1};
            roles{i1,1} = ci(ii{i1}+1:end);
         end
      end
   end


end