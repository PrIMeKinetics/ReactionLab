function authenticate(wLink)
% authenticate(WarehouseLinkObj)
% check the PrIMe user database for the username and password

% Copyright 1999-2015 Michael Frenklach
%  Created:     March 14, 2013, myf
% Modified:     April  1, 2013, myf
% Modified: September 10, 2014, myf: remove set|getappdata
% Modified:  February 22, 2015, myf: fixed typos

userName     = wLink.Username;
userPassword = wLink.Password;
if isempty(char(userName)) || isempty(char(userPassword))
   wLink.Authenticated = false;
%    setappdata(wLink.conn,'Authorized',false);
   return
end

http = PrimeKinetics.PrimeHandle.Utils.HTTPWorker();
http.Url = PrimeKinetics.PrimeHandle.Config.GetDrupalUsersUrl();
http.Type = PrimeKinetics.PrimeHandle.Utils.HTTPRequestType.Post;
http.AddValue('username',userName);
utilsObj = PrimeKinetics.PrimeHandle.Utils.Utils;
md5 = utilsObj.GetMd5Sum(System.String(userPassword)).ToLower();
http.AddValue('password_md5', md5);
http.AddValue('form_id', 'user_login');
http.AddValue('op', 'Log in');
rsp = http.SendRequest;
a = http.ResponseText;
[~,b] = strtok(strtok(char(a)),':');
b(1) = [];

wLink.Authenticated = logical(str2num(b));
% setappdata(wLink.conn,'Authorized',logical(str2num(b)));