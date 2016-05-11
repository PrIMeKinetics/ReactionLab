function hdf5write(trg,hdf5path)
% hdf5write(PrIMeTargetObj,hdf5path)

% based on the part of get_attribute.m
   % Copyright (c) 2003-2015 Michael Frenklach
   % Modified: December  3, 2008, Xiaoqing You
   % Modified: February 12, 2010, myf
   % Modified: February 17, 2010 Xiaoqing You
   % Modified:   October 5, 2010 Xiaoqing You
   % Modified:    April  7, 2013, myf
   % Modified: Matt Speight, July 23, 2013 - lines 191-196
% Created: January 4, 2015, myf

NET.addAssembly('System.Xml');

whLink = ReactionLab.Util.PrIMeData.WarehouseLink();
conn = whLink.conn;

givenProperty = {};
trgFilePath  = '';

localUnpackXML(trg.Doc);


   function localUnpackXML(trgDoc)
   % unpack the dataAttribute DOM object
      trgPrimeId = char(trgDoc.DocumentElement.GetAttribute('primeID'));
      trgTitle = char(trgDoc.GetElementsByTagName('preferredKey').Item(0).InnerText);
      trgKey = lower(trgTitle(isstrprop(trgTitle,'alphanum')));
      trgDescription = char(trgDoc.GetElementsByTagName('additionalDataItem').Item(0).InnerText);
      if isempty(trgFilePath)
         trgFilePath = ['depository/dataAttributes/catalog/' trgPrimeId '.xml'];
      end
      
    % get and unpack the experiment DOM
      exptLinkNode = trgDoc.GetElementsByTagName('propertyLink').Item(0);
      exptPrimeId = char(exptLinkNode.GetAttribute('experimentPrimeID'));
      exptFilePath = char(PrimeKinetics.PrimeHandle.Data.Common.PrimeID2path(exptPrimeId));
      a1 = conn.Load(exptFilePath);
      if ~a1.status
         error(['could not download ' exptFilePath])
      end
      exptDoc = a1.result;
      apparatusKindNode = exptDoc.DocumentElement.GetElementsByTagName('apparatus').Item(0)...
                                                 .GetElementsByTagName('kind').Item(0);
      apparatusKind = char(apparatusKindNode.InnerText);
      propertyNodes = exptDoc.GetElementsByTagName('commonProperties').Item(0)...
                             .GetElementsByTagName('property');

    % start output data object
      hdf5write(hdf5path, ...
         '/title',             'target',    ...
         '/phaseData/phase',   'gas',       ...
         '/phaseData/eqState', 'Ideal Gas', ...
         '/targetData/key',         trgTitle,         ...
         '/targetData/description', trgDescription, ...
         '/targetData/primeID',     trgPrimeId,     ...
         '/targetData/filePath',    trgFilePath,    ...
         '/targetData/experiment/primeID',   exptPrimeId, ...
         '/targetData/experiment/filePath',  exptFilePath, ...
         '/targetData/experiment/apparatus', apparatusKind  );
      fileattrib(hdf5path,'+w');
      
      for i1 = 1:propertyNodes.Count
         node_i = propertyNodes.Item(i1-1);
         propName = lower(char(node_i.GetAttribute('name')));
         switch propName
            case 'temperature'
               [Tvalue,Tunits] = getProperty(node_i,propName);
               addProperty2hdf5(propName,Tvalue,Tunits);
            case 'pressure'
               [Pvalue,Punits] = getProperty(node_i,propName);
               addProperty2hdf5(propName,Pvalue,Punits);
            case 'concentration'
               [Cvalue,Cunits] = getProperty(node_i,propName);
               addProperty2hdf5(propName,Cvalue,Cunits);
            case 'flow rate'
               [Uvalue,Uunits] = getProperty(node_i,propName);
               addProperty2hdf5(propName,Uvalue,Uunits);
            case 'initial composition'
               addProperty2hdf5(propName,node_i,'');
            otherwise
               error(['undefined property: ' propName]);
         end
      end
                
    % get target data
      trgNode = trgDoc.GetElementsByTagName('dataAttributeValue').Item(0);
      trgType = char(trgNode.GetAttribute('type'));
      indicatorNode = trgNode.GetElementsByTagName('indicator');
      if indicatorNode.Count == 0
         error('there is no indicator data for this target')
      end
      observableNode = trgNode.GetElementsByTagName('observable').Item(0);
      observableProp = observableNode.GetElementsByTagName('property').Item(0);
      observable.type  = char(observableProp.GetAttribute('name'));
      %if ~strcmp(observable.type,'time')
         observable.units = replaceUnits(observableProp.GetAttribute('units'));
      %else
      %   observable.units=[char(181) 's'];
      %end
      if strcmpi(trgType,'derived')
          for i1 = 1:indicatorNode.Count
              indicatorProp = indicatorNode.Item(i1-1).GetElementsByTagName('property').Item(0);
              indicator(i1).type  = char(indicatorProp.GetAttribute('name'));
              indicator(i1).units = replaceUnits(indicatorProp.GetAttribute('units'));
              indicator(i1).value = str2double(char(...
                  indicatorProp.GetElementsByTagName('value').Item(0).InnerText));
              if strncmpi(indicator(i1).type, 'mole fraction', 13)
                  propId =  char(indicatorNode.Item(i1-1).GetAttribute('propertyID'));
                  linkNode = PrimeKinetics.PrimeHandle.Data.Common.SelectSingleNode(trgDoc.DocumentElement,['propertyLink[@id=''' propId ''']']);
                  dgId = char(linkNode.GetAttribute('dataGroupID'));
                  propertyId = char(linkNode.GetAttribute('propertyID'));
                  
                  dgNode = PrimeKinetics.PrimeHandle.Data.Common.SelectSingleNode(exptDoc.DocumentElement,['dataGroup[@id=''' dgId ''']']);
                  propertyNode =  PrimeKinetics.PrimeHandle.Data.Common.SelectSingleNode(dgNode,['property[@id=''' propertyId ''']']);
                  spePrimeId = PrimeKinetics.PrimeHandle.Data.Common.SelectSingleNode(propertyNode,'speciesLink/@primeID');
                  indicator(i1).spePrimeId = char(spePrimeId.Value);
              else
                  indicator(i1).spePrimeId = ' ';
              end
          end
          observable.value = str2double(char(...
              observableProp.GetElementsByTagName('value').Item(0).InnerText));
      elseif strcmpi(trgType,'actual')
          indicatorProp = indicatorNode.Item(0).GetElementsByTagName('property').Item(0);
          indicator.type  = char(indicatorProp.GetAttribute('name'));
          indicator.units = replaceUnits(indicatorProp.GetAttribute('units'));
          indicatorLink  =  indicatorProp.GetElementsByTagName('valueLink').Item(0);
          observableLink = observableProp.GetElementsByTagName('valueLink').Item(0);
          indicatorId  =  char(indicatorLink.GetAttribute('propertyID'));
          observableId = char(observableLink.GetAttribute('propertyID'));
          dataGroupId = char(indicatorLink.GetAttribute('dataGroupID'));
          dataPointId = char(indicatorLink.GetAttribute('dataPointID'));
          groupNode = getnode(exptDoc,'dataGroup','id',dataGroupId);
          dataPointNode = getnode(groupNode,'dataPoint','id',dataPointId);
          groupProperties = groupNode.GetElementsByTagName('property');
          for i2 = 1:groupProperties.Count
              id = char(groupProperties.Item(i2-1).GetAttribute('id'));
              if strcmpi(id,indicatorId)
                  indicator.value = str2double(char(...
                      dataPointNode.GetElementsByTagName(id).Item(0).InnerText));
              elseif strcmpi(id,observableId)
                  observable.value = str2double(char(...
                      dataPointNode.GetElementsByTagName(id).Item(0).InnerText));
              else
                  name = char(groupProperties.Item(i2-1).GetAttribute('name'));
                  value = str2double(char(...
                      dataPointNode.GetElementsByTagName(id).Item(0).InnerText));
                  units = replaceUnits(groupProperties.Item(i2-1).GetAttribute('units'));
                  addProperty2hdf5(name,value,units);
              end
          end
      else
          error(['undefined target type: ' trgType]);
      end
      % edited by wms 
      if strcmp(observable.type,'time')
         observable.value=ReactionLab.Units.units2units(observable.value,observableProp.GetAttribute('units'),'microsec');
         observable.units = [char(181) 's'];
      end
      % end edit
      % finish the output data object
      hdf5write(hdf5path, ...
          '/targetData/indicator/type', {indicator.type}, ...
          '/targetData/indicator/value',[indicator.value],...
          '/targetData/indicator/units',{indicator.units},...
          '/targetData/indicator/primeID',{indicator.spePrimeId},...
          '/targetData/observable/type', observable.type, ...
          '/targetData/observable/value',observable.value,...
          '/targetData/observable/units',observable.units,...
          '/targetData/givenProperty', givenProperty, ...
          'WriteMode', 'append'                         );
      
      % get and unpack the instrumentalModel DOM
      imLinkNodes = trgDoc.GetElementsByTagName('instrumentalModelLink');
      if imLinkNodes.Count > 0
          imPrimeId = char(imLinkNodes.Item(0).GetAttribute('instrumentalModelPrimeID'));
          %imDoc = System.Xml.XmlDocument;
          %imFilePath = [xmlFileDir imPrimeId '.xml'];
          %imDoc.Load(imFilePath);
          imFilePath = char(PrimeKinetics.PrimeHandle.Data.Common.PrimeID2path(imPrimeId));
          a3 = conn.Load(imFilePath);
          imDoc = a3.result;
          imPropNodes = imDoc.DocumentElement.GetElementsByTagName('property');
          for i4 = 1:imPropNodes.Count
              variableNode = imPropNodes.Item(i4-1);
              variable(i4).type  = char(variableNode.GetAttribute('name'));
              variable(i4).units = replaceUnits(variableNode.GetAttribute('units'));
              variable(i4).value = str2double(char(variableNode.GetElementsByTagName('value').Item(0).InnerText));
          end
          hdf5write(hdf5path, ...
              '/targetData/instrumentalModel/primeID',   imPrimeId, ...
              '/targetData/instrumentalModel/filePath',  imFilePath, ...
              '/targetData/instrumentalModel/variable/type', {variable.type}, ...
              '/targetData/instrumentalModel/variable/value',[variable.value],...
              '/targetData/instrumentalModel/variable/units',{variable.units},...
              'WriteMode', 'append'                         );
      end
      
   end


   function addProperty2hdf5(name,value,units)
      switch name
         case 'temperature'
            givenProperty = [givenProperty {'T'}];
            TinK = ReactionLab.Units.units2units(value,units,'K');
            hdf5write(hdf5path,...
               '/temperature/value', TinK, ...
               '/temperature/units', 'K',  ...
               'WriteMode', 'append'       );
         case 'pressure'
            givenProperty = [givenProperty {'P'}];
            PinPa = ReactionLab.Units.units2units(value,units,'Pa');
            hdf5write(hdf5path,...
               '/pressure/value', PinPa, ...
               '/pressure/units', 'Pa',  ...
               'WriteMode', 'append'       );
         case 'concentration'
            givenProperty = [givenProperty {'C'}];
            CinMolCM3 = ReactionLab.Units.units2units(value,units,'mol/cm3');
            hdf5write(hdf5path,...
               '/totalConcentration/value', CinMolCM3, ...
               '/totalConcentration/units', 'mol/cm3', ...
               'WriteMode', 'append'                    );
         case 'flow rate'
            givenProperty = [givenProperty {'U'}];
            hdf5write(hdf5path,...
               '/flowRate/value', value, ...
               '/flowRate/units', units,  ...
                'WriteMode', 'append'         );
         case 'initial composition'
            givenProperty = [givenProperty {'X'}];
            [speKey,spePrimeId,speMolFract] = getInitComposition(value);
            hdf5write(hdf5path,...
               '/species/key',         speKey,       ...
               '/species/primeID',     spePrimeId,   ...
               '/species/molFraction', speMolFract , ...
               'WriteMode', 'append'                   );
         otherwise
            error(['undefined property: ' name]);
      end
   end

   function [value,units] = getProperty(node,propType)
      value = str2double(char(...
         node.GetElementsByTagName('value').Item(0).InnerText ));
      units = replaceUnits(node.GetAttribute('units'));
   end

   function units = replaceUnits(fromUnits)
       units = char(fromUnits.Replace(char(179),'3').Replace( ...
               System.Convert.ToString(char(181)),System.String('micro')));
   end

   function [key,primeid,value] = getInitComposition(node)
      componentNodes = node.GetElementsByTagName('component');
      nComp = componentNodes.Count;
      key = cell(1,nComp);  primeid = key;  value = zeros(1,nComp);
      for i1 = 1:nComp
         cNode = componentNodes.Item(i1-1);
         key{i1} = strtrim(char(...
            cNode.GetElementsByTagName('speciesLink').Item(0)...
                 .GetAttribute('preferredKey')));
         primeid{i1} = char(...
            cNode.GetElementsByTagName('speciesLink').Item(0)...
                 .GetAttribute('primeID'));
         amountNode = cNode.GetElementsByTagName('amount').Item(0);
         val = str2double(char(amountNode.InnerText));
         units = replaceUnits(amountNode.GetAttribute('units'));
         value(i1) = ReactionLab.Units.units2units(val,units,'mole fraction');
      end
   end

end