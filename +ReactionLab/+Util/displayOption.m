function displayOption(opt,type,txt)
% displayOption(option,'error|disp','message')
%
%    option = 1   dialog messages
%           = 0   command line

% Copyright 1999-2013 Michael Frenklach
% Created: March 26, 2013, myf
% Last modified: March, 26, 2013, myf

if opt   %  dialog messages
   switch lower(type)
      case 'error'
         errordlg(txt,'','modal');
      case 'disp'
         helpdlg(txt,'');
      otherwise
         error(['unsupported type ' type]);
   end
else    % command line
   switch lower(type)
      case 'error'
         error(txt);
      case 'disp'
         disp(txt);
      otherwise
         error(['unsupported type ' type]);
   end
end