function loginWindow(wLink)
% loginWindow(WarehouseLinkObj)
% opens window for entry of username and password

% Copyright 1999-2013 Michael Frenklach
% Created: March 17, 2013, myf
% Last modified: April 1, 2013, myf

wLink.PrimeEditor_pub;
logdlg = PrimeEditor.LoginGUI();
logdlg.Topmost = true;
logdlg.ShowDialog();
un = char(logdlg.Username);
pw = char(logdlg.Password);
wLink.Username = un;
wLink.Password = pw;

wLink.authenticate();