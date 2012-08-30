function displayGeomPanel(speGUI)
% displayGeomPanel(speGUI)

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: July 23, 2012


if isempty(speGUI.Hgeom.currentAxesPanel) || ...
           speGUI.Hgeom.currentSpecies ~= speGUI.CurrentSpecies    % if new species
   delete(findobj([speGUI.Hgeom.panel2D speGUI.Hgeom.panel3D],'Type','axes'));
   if ~getNewSpecies(), return, end
end

HselectedBtn = get(speGUI.Hgeom.Hbtns,'SelectedObject');
if ~isempty(speGUI.Hgeom.currentAxesPanel)
   set(speGUI.Hgeom.currentAxesPanel,'Visible','off');
   drawnow
end

geomDim = get(HselectedBtn,'String');   %  '2D'  or  '3D'
speGUI.Hgeom.currentAxesPanel = speGUI.Hgeom.(['panel' upper(geomDim)]);
curAxes = findobj([speGUI.Hgeom.currentAxesPanel],'Type','axes');
if isempty(curAxes)
   spe = speGUI.CurrentSpecies;
   if isprop(spe,'MolecularStructure')
      molModel = spe.MolecularStructure;
   else
      addprop(spe,'MolecularStructure');
      molModel = ReactionLab.SpeciesData.SpeciesStructure.MolecularModel('nci_nih');  % 'ob|nci_nih'
      molModel.InputString = spe.InChI;
      spe.MolecularStructure = molModel;
   end
   if isempty(molModel.Geom2d)
      set(speGUI.Hgeom.panel,'Visible','Off');
      errordlg([spe.InChI ' is not resolved'],'NCI-NIH Resolver','modal');
      return
   else
      set(speGUI.Hgeom.panel,'Visible','On')
   end
   elems = speGUI.Hgeom.currentSpecies.Elements;
   if sum([elems.number]) == length(molModel.(['Geom' lower(geomDim)]).atoms)
      molModel.Hgeom  = speGUI.Hgeom;
      molModel.Hpanel = speGUI.Hgeom.currentAxesPanel;
      molModel.plot(geomDim);
   end
else
   set(curAxes,'Layer','top');
   rotate3d(curAxes,'on'); axis vis3d;
end
set(speGUI.Hgeom.currentAxesPanel,'Visible','on');
drawnow


   function y = getNewSpecies
      y = 1;
      spe = speGUI.CurrentSpecies;
      speGUI.Hgeom.currentSpecies = spe;
      if sum([spe.Elements.number]) < 2
         y = 0;
         return
      end
      inchi = spe.InChI;
      if isempty(inchi)
         Hdlg = errordlg(['Species ' spe.Key ' does not have InChI'],'modal');
         waitfor(Hdlg);
         y = 0;
         return
      end
   end

end