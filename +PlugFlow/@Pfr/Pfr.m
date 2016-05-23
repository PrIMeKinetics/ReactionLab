classdef Pfr < handle
%    for PWA

% Copyright 1999-2015 Michael Frenklach
% Modified: February 14, 2010
% Modified:    March 19, 2015, myf
   
   properties
      Title   = '';
      Comment = '';
      Const   = '';   % 'pa' (for P=const, adiabatic) or 'va', 'pt', 'vt'
      Qdot    =  0;   % =0 adiabatic or kJ/s or
      RxnModel
      ResidenceTime = [];    % in sec
      Results = {};    % {t,y,runTime}
   end
   
end