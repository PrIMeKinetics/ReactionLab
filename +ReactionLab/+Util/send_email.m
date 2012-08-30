function send_email(addr,subj,body)
% send_email(address,subject,body)

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: April 21, 2012

NET.addAssembly('System');

System.Diagnostics.Process.Start(['mailto:' addr '?subject=' subj '&body=' body]);