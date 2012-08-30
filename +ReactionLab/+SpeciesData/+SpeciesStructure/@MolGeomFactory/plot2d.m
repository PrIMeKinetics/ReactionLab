function plot2d(obj,molModelObj)
% plot(MolGeomFactoryObj,MolecularModelObj)

% Copyright 1999-2012 Michael Frenklach
% $Revision: 1.1 $
% Last modified: July 6, 2012

panelColor = get(molModelObj.Hpanel,'BackgroundColor');
Haxes = axes('Parent',molModelObj.Hpanel,...
             'Units', 'normalized',...
             'OuterPosition',[0 0 1 1]);   %     'Layer','top',...

bb = molModelObj.Geom2d.bonds;
for j1 = 1:length(bb)
   a1 = bb(j1).From;
   a2 = bb(j1).To;
   ro = bb(j1).Order;
   if     ro == 1,   draw10;
   elseif ro == 1.5, draw15;
   elseif ro == 2  , draw20;
   elseif ro == 3  , draw30;
   else
      error(['undefined reaction order ' num2str(ro)]);
   end
end

aa = molModelObj.Geom2d.atoms;
for i1 = 1:length(aa)
   text(aa(i1).X,aa(i1).Y,0.001,upper(aa(i1).Element),...
       'Parent',Haxes,'BackgroundColor',panelColor,...
       'Color','b','FontWeight','bold','FontSize',18,...
       'HorizontalAlignment', 'center');
end

rotate3d(Haxes,'on');
axis vis3d
axis(Haxes,'off','equal');
drawnow


   function draw10
      line([a1.X a2.X],[a1.Y a2.Y],...
           'Parent',Haxes,'Color','black','LineWidth',2);
   end
   function draw15
%                line([a1.X a2.X],[a1.Y a2.Y],'LineStyle',':',...
%                     'Parent',Haxes,'Color',[0.8 0.8 0.8],'LineWidth',5);
      line([a1.X a2.X],[a1.Y a2.Y],'LineStyle',':',...
           'Parent',Haxes,'Color','y','LineWidth',5);
      line([a1.X a2.X],[a1.Y a2.Y],...
           'Parent',Haxes,'Color','black','LineWidth',2);
   end
   function draw20
      line([a1.X a2.X],[a1.Y a2.Y],...
           'Parent',Haxes,'Color','black','LineWidth',4.5);
      line([a1.X a2.X],[a1.Y a2.Y],...
           'Parent',Haxes,'Color',panelColor,'LineWidth',1.5);
   end
   function draw30
      line([a1.X a2.X],[a1.Y a2.Y],...
           'Parent',Haxes,'Color','black','LineWidth',5);
      line([a1.X a2.X],[a1.Y a2.Y],...
           'Parent',Haxes,'Color',panelColor,'LineWidth',3);
      line([a1.X a2.X],[a1.Y a2.Y],...
           'Parent',Haxes,'Color','black','LineWidth',1);
   end

end