function loginWindow(wLink)
% loginWindow(WarehouseLinkObj)
% opens window for entry of username and password

% Copyright 1999-2013 Michael Frenklach
% Last modified: March 17, 2013

wLink.PrimeEditor_pub;
logdlg = PrimeEditor.LoginGUI();
logdlg.Topmost = true;
logdlg.ShowDialog();
wLink.Username = char(logdlg.Username);
wLink.Password = char(logdlg.Password);

wLink.authenticate();