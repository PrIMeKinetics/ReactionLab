function rxn = readChemkinRxn(lines,kUnits,speList)
% ReactionObj = readChemkinRxn(lines,rkUnits,speListObj)
%
% parse Chemkin-formatted reaction record, i.e.,
%      one or two lines of a Chemikin file

% Copyright 1999-2010 Michael Frenklach
% $Revision: 1.1 $
% Last modified: May 13, 2010

NET.addAssembly('System.Xml');
import System.Xml.*;

NET.addAssembly(which('\+ReactionLab\+Util\PrimeWSClient.dll'));
ws = PrimeWSClient.PrimeHandleService.PrimeHandle;

rxn0 = ReactionLab.ReactionData.Reaction();

if length(lines) == 1
   singleLine
else
   readLines
end


   function singleLine
   % either mass action or 'simple' third order
      parseEqLine(lines{1});
      
   end


   function readLines
   % DUP or p-dependent
      singleLine
   
%      y = secondLine(line2);
%       
%      strncmpi(line,'DUP',3)
     
     
   end


   function [y,refString] = parseEqLine(line)
   % parse the 'first line: equation parameters ! reference
    % look for reference
      [line,ref] = strtok(line,'!');
      if ~isempty(ref), ref(1) = []; end
      refString = strtrim(ref);
    % unpack prm -- k's parameters
      lineParts = textscan(line,'%s');
      eq = [lineParts{1}{1:end-3}];
      prm = str2num(char(lineParts{1}(end-2:end)))';
    % look for 'hv'
      indHV = findstr(eq,'HV');
      if ~isempty(indHV)
         eq([indHV indHV+1]) = [];
      end
    % parse reaction equation
      rxnSpe = rxnSpeFromEq(eq);
      rxnFound = searchWarehouse(rxnSpe);
      if isempty(rxnFound)     % no match found
         error('need to create a new reaction');
      else
         [rxnIds,rxnDocs] = narrowSearch(rxnFound,rxnSpe);
         if isempty(rxnIds)  % no match found
            error('need to create a new reaction');
         elseif length(rxnIds) > 1
            error(['multiple rxn records found: ' char(rxnIds)]);
         else  % single match for rxn; now check for rk
            rxn = ReactionLab.ReactionData.Reaction(rxnDocs{1});
            y = checkRKparam(rxn,prm);
            
            keyabord
            
         end
      end
      
      
   end


   function rxnSpe = rxnSpeFromEq(eq)
      [lhs,rhs,isRev] = ReactionLab.ReactionData.Reaction.parseRxnEq(eq);
      rxn.Reversible = isRev;
      lhsSpe = {lhs.name};
      rhsSpe = {rhs.name};
      uniqueSpe = unique([lhsSpe rhsSpe]);
      rxnSpe = rxn0.Species;
      for i2 = 1:length(uniqueSpe)
         spe = uniqueSpe{i2};
         speObj = speList.find('Key',spe);
         if isempty(speObj)
            error(['species ' spe ' not found'])
         else
            rxnSpe(i2).key     = spe;
            rxnSpe(i2).primeId = speObj.PrimeId;
            coef = 0;
            rhsInd = find(strcmp(spe,rhsSpe));
            if ~isempty(rhsInd)
               coef = coef + [rhs(rhsInd).coef];
            end
            lhsInd = find(strcmp(spe,lhsSpe));
            if ~isempty(lhsInd)
               coef = coef - [lhs(lhsInd).coef];
            end
            rxnSpe(i2).coef = coef;
         end
      end
   end


   function y = searchWarehouse(rxnSpe)
      s = '';
      for i3 = 1:length(rxnSpe)
         if rxnSpe(i3).coef ~= 0
            s = [s 'CONTAINS(reaction_reactant_primeID, ''' rxnSpe(i3).primeId ''' ) AND '];
         end
      end
      indAND = strfind(s,'AND');
      ind1 = indAND(end);         % index of the last AND
      s([ind1:ind1+2]) = [];      %  remove last AND
      z = Search(ws,'depository/reactions/catalog/',s,'shallow','','');
      y = localGetId(z);
   end


   function w = localGetId(x)
      if x.status == 1
         r = x.result;
         if ~isempty(r)
            w = cell(1,r.Length);
            for i2 = 1:r.Length
               [~,id,~] = fileparts(char(r.GetValue(i2-1)));
               w{i2} = id;
            end
            return
         end
      end
      w = {};
   end


   function [y,docs] = narrowSearch(y,eqRxnSpe0)
   % remove those that have extra species
      ind2rem = [];   % to remove from list of possible matches, y
      eqRxnSpe = eqRxnSpe0([eqRxnSpe0.coef] ~= 0);
      eqPrimeIds = {eqRxnSpe.primeId};
      docs = cell(1,length(y));
      for i3 = 1:length(y)
         rxnDoc = ReactionLab.Util.gate2primeData('getDOM',{'primeId',y{i3}});
         docs{i3} = rxnDoc;
         catRxnSpe0 = ReactionLab.ReactionData.Reaction.parseRxnCatalog(rxnDoc);
         catRxnSpe = catRxnSpe0([catRxnSpe0.coef] ~= 0);
         if length(catRxnSpe) ~= length(eqRxnSpe)
            ind2rem = [ind2rem i3];
            continue
         end
         for i4 = 1:length(catRxnSpe)
            if catRxnSpe(i4).coef ~= 0
               ind = find(strcmpi(catRxnSpe(i4).primeId,eqPrimeIds));
               if isempty(ind)  % catalog reaction does not match
                  ind2rem = [ind2rem i3];
                  break
               elseif length(ind) > 1
                  error('multiple matches should not happen here')
               else  % species primeIds match; now check if coefs match
                  if catRxnSpe(i4).coef ~= eqRxnSpe(ind).coef
                     ind2rem = [ind2rem i3];
                     break
                  end
               end
            end
         end
      end
      if ~isempty(ind2rem)
         y(ind2rem) = [];
         docs(ind2rem) = [];
      end
   end

   function y = checkRKparam(rxn,prm)
   % find rk's with matching parameters
      rkList = ReactionLab.Util.gate2primeData('getDataFileList',{'primeID',rxn.PrimeId,'rk'});
      y = zeros(1,length(rkList));
      for i3 = 1:length(rkList)
         if ismember('rk00000000',rkList), continue, end
         rkFilePath = char(Common.PrimeID2path(rxn.PrimeId,rkList{i1}));
         a1 = conn.Load(rkFilePath);
         if ~a1.status
            error(['could not download ' rxn.PrimeId '/' rkList{i1}])
         end
         rkDoc = a1.result;
         
         
         
         
%          rk = loadRK(rxn,rkList{i3});
%          y(i3) = isSame(rk,prm);
      end
   end



%    function refStr = parseEq2Line(line)
%    % parse line with rxn equation
% 
%       [line,ref] = strtok(line,'!');
%       if ~isempty(ref), ref(1) = []; end
%       refStr = strtrim(ref);
%      % unpack prm -- k's parameters
%       lineParts = textscan(line,'%s');
%       eq = [lineParts{1}{1:end-3}];
%       prm = str2num(char(lineParts{1}(end-2:end)))';
%     % look for 'hv'
%       indHV = findstr(eq,'HV');
%       if ~isempty(indHV)
%          eq([indHV indHV+1]) = [];
%       end
%     % look for 'M','(M)', or '(species)'
%       lp = findstr(eq,'(');
%       if isempty(lp)
%          m = findstr(eq,'M');
%          if ~isempty(m)
%             set(r,'m','M');  %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
%             eq(m) = [];
%          end
%       else
%          rp = findstr(eq,')');
%          i = [lp;rp];
%          irem = [];
%          for j = 1:size(i,2)
%             str = eq(i(1,j)+1:i(2,j)-1);
%             if ~isempty(findstr(str,'+')) % skip if no '+'
%                body3 = strtok(str,' +');
%                if strcmpi(body3,'M')
%                   set(r,'m','(M)');
%                elseif any(strcmpi(speList,body3))
%                   set(r,'m',['(' body3 ')']);
%                else
%                   error(['undefined third body ' body3])
%                end
%                irem = [ irem; i(1,j):i(2,j)];
%             end
%          end
%          if ~isempty(irem)
%             eq(irem) = [];  % remove third bodies
%          end
%       end
%     % '=', '=>' or '<=>'
%       j = findstr(eq,'=');
%       if isempty(j)
%          error('there is no ''='' sign')
%       else
%          left  = eq(  1:j-1);
%          right = eq(j+1:end);
%       end
%       jl = findstr(left, '<');
%       jr = findstr(right,'>');
%       if isempty(jl)
%          if isempty(jr)
%             set(r,  'reversible');
%          else
%             set(r,'irreversible');
%             right(jr) = [];
%          end
%       else
%          set(r,'reversible');
%          left(jl)  = [];
%          right(jr) = [];
%       end
%      % unpack sides
%       LOCAL_side(left,-1,r,speList)
%       LOCAL_side(right,1,r,speList)
%       % set ratecoef object
%       order = get(r,'order');
%       if strcmpi(get(r,'m'),'M'), order = order + 1; end
%       ar = LOCAL_arrhenius(r,prm,kUnits,ref,order);
%       k = ratecoef({'ref',strtok(strName,'.')});
%       if ~isempty(indHV)
%          set(k,'type','photolytic');
%       elseif strcmpi(get(r,'m'),'M')
%          collider.key = 'M';
%          set(ar,'collider',collider);
%          set(k,'type','third body');
%       else
%          set(k,'type','mass action');
%       end
%       set(k,'expression',ar);
%       set(r,'k_forward',k);
%       
% 
%    end
%    
% 
% 
%          [rDup,iDup,drct] = reaction('match',prevRxn,rxnList(1:end-1));
%          if ~isempty(rDup)
%             kprev_forw = get(prevRxn,'k_forward');
%             if drct ~= 1
%                message = {['DUPLICATE reactions must be set ' ...
%                           'in the same direction.']; ' ';...
%                           ['If setting opposite directions '...
%                           'of the same reaction,'];...
%                           'DUPLICATE declarion must not be used.'};
%                Hdlg = errordlg(message,get(prevRxn),'modal');
%                waitfor(Hdlg)
%                close(Hwait)
%                error('no forward rate coef')
%             end
%             kdup_forw = get(rDup,'k_forward');
%             expr    = get(kdup_forw, 'expression');
%             expr(2) = get(kprev_forw,'expression');
%             set(kdup_forw,'expression',expr);
%             set(rDup,'k_forward',kdup_forw);
%             kdup_rev  = get(rDup,'k_reverse');
%             if ~isempty(kdup_rev)
%                kprev_rev = get(prevRxn,'k_reverse');
%                expr    = get(kdup_rev, 'expression');
%                expr(2) = get(kprev_rev,'expression');
%                set(kdup_rev,'expression',expr);
%                set(rDup,'k_reverse',kdup_rev);
%             end
%             rxnList(iDup) = rDup;
%             rxnList(end) = [];
%          end
%       elseif any(findstr(strtok(line,'!'),'/')) % additional data
%          [line,ref] = strtok(line,'!');
%          if ~isempty(ref), ref(1) = []; end
%          [s,s2] = strtok(line,' /');
%          s2 = deblank(strtok(strjust(s2,'left'),'/'));
%          switch upper(s)
%             case {'LOW','HIGH'}
%                prm = strread(s2);
%                prevRxn = rxnList(end);
%                k = get(prevRxn,'k_forward');
%                falloff = get(k,'falloff');
%                if isempty(falloff) || isempty(falloff.type)
%                   falloff.type  = 'lindemann';
%                   falloff.data  = [];
%                   falloff.error = [];
%                end
%                set(k,'falloff',falloff);
%                arr = get(k,'expression');
%                clear(k,'expression');    % 'expression' is replaced  below by
%                order = get(arr,'order'); %    'k_highP' and 'k_lowP'
%       %         set(arr,'order',order-1);
%                if strcmpi(s,'LOW')
%                   k_lowP = LOCAL_arrhenius(prevRxn,prm,kUnits,...
%                                                     ref,order+1);
%                   collider.key = 'M';
%                   set(k_lowP,'collider',collider);
%                   if length(arr) > 1
%                      for i1 = 2:length(arr)
%                         k_lowP_i = ( arr(i1).a/arr(1).a ) * k_lowP(1);
%                         set(k_lowP_i,'collider',get(arr(i1),'collider'));
%                         k_lowP(i1) = k_lowP_i;
%                      end
%                   end
%                   set(k,{'type',   'unimolecular'},...
%                         {'k_highP', arr(1)    },...
%                         {'k_lowP',  k_lowP }  );
%                else
%                   k_highP = LOCAL_arrhenius(prevRxn,prm,kUnits,...
%                                                     ref,order+1);
%                   collider.key = 'M';
%                   set(k_highP,'collider',collider);
%                   if length(arr) > 1
%                      for i1 = 2:length(arr)
%                         k_highP_i = ( arr(i1).a/arr(1).a ) * k_highP(1);
%                         set(k_highP_i,'collider',get(arr(i1),'collider'));
%                         k_highP(i1) = k_highP_i;
%                      end
%                   end
%                   set(k,{'type',   'chemical activation'},...
%                         {'k_lowP',  arr(1)     },...
%                         {'k_highP', k_highP }  );
%                end
%                set(prevRxn,'k_forward',k);
%                rxnList(end) = prevRxn;
%             case {'TROE','SRI'}
%                prm = strread(s2);
%                prevRxn = rxnList(end);
%                k = get(prevRxn,'k_forward');
%                falloff.type = lower(s);
%                switch upper(s)
%                   case 'TROE'
%                      prmName = {'a' 'T***' 'T*' 'T**'};
%                   case 'SRI'
%                      prmName = {'a' 'b' 'c' 'd' 'e'};
%                   otherwise
%                      error(['undefined falloff: ' s])
%                end
%                data = paramRec;
%                for i1 = 1:length(prm)
%                   data(i1).param = prmName{i1};  % parameter name
%                   data(i1).value = prm(i1);
%                end
%                falloff.data = data;
%                falloff.error = [];
%                set(k,'falloff',falloff);
%                set(prevRxn,'k_forward',k);
%                rxnList(end) = prevRxn;
%             case 'REV'  % reverse rate coef
%                prm = strread(s2);
%                prevRxn = rxnList(end);
%                ar = LOCAL_arrhenius(prevRxn,prm,kUnits,...
%                              ref,get(prevRxn,'order',2) );
%                k_rev = get(prevRxn,'k_forward');
%                set(k_rev,'expression',ar);
%                set(prevRxn,'k_reverse',k_rev);
%                rxnList(end) = prevRxn;
%             case {'FORD','RORD'}
%                rr.spe   = '';
%                rr.order = [];
%                while ~isempty(s2)
%                   [formula,s2] = strtok(s2);
%                   [number, s2] = strtok(s2);
%                   ri.spe = formula;
%                   ri.order =  str2double(number);
%                   rr = [rr ri];
%                end
%                prevRxn = rxnList(end);
%                k = get(prevRxn,'k_forward');
%                set(k,{'type','global'},{'ratelaw',{s,rr}});
%                rxnList(end) = prevRxn;
%             otherwise     % collision efficiencies
%                prevRxn = rxnList(end);
%                k = get(prevRxn,'k_forward');
%                switch get(k,'type')
%                   case 'mass action'
%                      exprField = 'expression';
%                      set(k,'type','third body');
%                   case 'third body'
%                      exprField = 'expression';
%                   case 'unimolecular'
%                      exprField = 'k_lowP';
%                   case 'chemical activation'
%                      exprField = 'k_highP';
%                   otherwise
%                      error(['undefined type ' k.type]);
%                end
%                expr = get(k,exprField);
%                colData = textscan(line,'%s%f','delimiter','/');
%                colSpe = colData{1}; % the nominal expression
%                colEff = colData{2}; %    is with collider 'M'
%                i2 = length(expr);
%                for i1 = 1:length(colSpe)
%                   if colEff(i1)
%                      expri = colEff(i1) * expr(1);
%                      collider.key = colSpe{i1};
%                      set(expri,'collider',collider);
%                      i2 = i2 + 1;
%                      expr(i2) = expri;
%                   end
%                end
%                set(k,exprField,expr);
%                set(prevRxn,'k_forward',k);
%                rxnList(end) = prevRxn;
%          end
%       else % the first reaction line
%          r = reaction;
%          [line,ref] = strtok(line,'!');
%          if ~isempty(ref), ref(1) = []; end
%          ref = [fileName ': ' strtrim(ref)];
%         % unpack prm -- k's parameters
%          lineParts = textscan(line,'%s');
%          eq = [lineParts{1}{1:end-3}];
%          prm = str2num(char(lineParts{1}(end-2:end)))';
%        % look for 'hv'
%          indHV = findstr(eq,'HV');
%          if ~isempty(indHV)
%             eq([indHV indHV+1]) = [];
%          end
%        % look for 'M','(M)', or '(species)'
%          lp = findstr(eq,'(');
%          if isempty(lp)
%             m = findstr(eq,'M');
%             if ~isempty(m)
%                set(r,'m','M');
%                eq(m) = [];
%             end
%          else
%             rp = findstr(eq,')');
%             i = [lp;rp];
%             irem = [];
%             for j = 1:size(i,2)
%                str = eq(i(1,j)+1:i(2,j)-1);
%                if ~isempty(findstr(str,'+')) % skip if no '+'
%                   body3 = strtok(str,' +');
%                   if strcmpi(body3,'M')
%                      set(r,'m','(M)');
%                   elseif any(strcmpi(speList,body3))
%                      set(r,'m',['(' body3 ')']);
%                   else
%                      error(['undefined third body ' body3])
%                   end
%                   irem = [ irem; i(1,j):i(2,j)];
%                end
%             end
%             if ~isempty(irem)
%                eq(irem) = [];  % remove third bodies
%             end
%          end
%        % '=', '=>' or '<=>'
%          j = findstr(eq,'=');
%          if isempty(j)
%             error('there is no ''='' sign')
%          else
%             left  = eq(  1:j-1);
%             right = eq(j+1:end);
%          end
%          jl = findstr(left, '<');
%          jr = findstr(right,'>');
%          if isempty(jl)
%             if isempty(jr)
%                set(r,  'reversible');
%             else
%                set(r,'irreversible');
%                right(jr) = [];
%             end
%          else
%             set(r,'reversible');
%             left(jl)  = [];
%             right(jr) = [];
%          end
%         % unpack sides
%          LOCAL_side(left,-1,r,speList)
%          LOCAL_side(right,1,r,speList)
%          % set ratecoef object
%          order = get(r,'order');
%          if strcmpi(get(r,'m'),'M'), order = order + 1; end
%          ar = LOCAL_arrhenius(r,prm,kUnits,ref,order);
%          k = ratecoef({'ref',strtok(strName,'.')});
%          if ~isempty(indHV)
%             set(k,'type','photolytic');
%          elseif strcmpi(get(r,'m'),'M')
%             collider.key = 'M';
%             set(ar,'collider',collider);
%             set(k,'type','third body');
%          else
%             set(k,'type','mass action');
%          end
%          set(k,'expression',ar);
%          set(r,'k_forward',k);
%    end
% 
% 
%    function ar = LOCAL_arrhenius(r,prm,kUnits,ref,order)
%    % sets arrhenius object
%       ar = arrhenius;
%       set(ar,{'ref',ref         },...
%              {'order',order     },...
%              {'a',prm(1),kUnits} ,...
%              {'n',prm(2)        },...
%              {'e',prm(3),kUnits}   );
%    end

end