function [y,z] = isequal(th1,th2,options)
%[y,z] = isequal(Nasa7obj,Nasa7obj2,options)
%
% y = 1|0 (true, false), if all(z) = 1
%
% compare the current thermo, th, with another one, th2:
%  z(1) -- the "comment" strings of the records
%  z(2) -- the 14 coefficient values
%  z(3) -- evaluated properties at T = linspace([Tmin Tmax],30)
%  z(4) -- reference state
%  z(5) -- bibliography primeId
%  z(6) -- temperature ranges
%
% options indicates which criteria to use for comparison,
%   i.e., options = [1 2] or =[1:6]

% Copyright 1999-2013 Michael Frenklach
% Last modified: December 9, 2011

ff = {@test1 @test2 @test3 @test4 @test5 @test6};

if nargin < 3
   options = [1 2];  %  1:6
end

n = length(options);
z = zeros(1,n);
for i1 = 1:n
   ui = feval(ff{options(i1)});
   if isempty(ui)
      ui = NaN;
   end
   z(i1) = ui;
end

y = all(z);


   function u = test1
   % comment strings
      u = strcmpi(strtrim(th1.Comment),strtrim(th2.Comment));
   end

   function u = test2
   % coeffients
      u = all( [th1.Data.coef] == [th2.Data.coef] );
   end

   function u = test3
   % evaluated properties
      allTs = [th1.Data.Trange th2.Data.Trange];
      T = linspace(min(allTs),max(allTs),30);
      val1 = th1.cphs(T);
      val2 = th2.cphs(T);
      u = all(all((val1 - val2)./((val1 + val2)/2) < 1e-6));
   end

   function u = test4
   % reference state
      u = (th1.RefState.P - th2.RefState.P) < 1;   % Pa
   end

   function u = test5
   % bibliography primeId
      u = strcmpi(th1.DataRef,th2.DataRef);
   end

   function u = test6
   % temperature ranges
      u = all( [th1.Data.Trange] == [th2.Data.Trange] );
   end

end