function authenticate(wLink)
% authenticate(WarehouseLinkObj)
% check the PrIMe user database for the username and password

% Copyright 1999-2013 Michael Frenklach
% Last modified: March 14, 2013

userName     = wLink.Username;
userPassword = wLink.Password;

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
wLink.Authorized = logical(str2num(b));