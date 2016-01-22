function LookSetup(~,~)
global UserValues
h.Look=findobj('Tag','Look');
if ~isempty(h.Look) %%% Gives focus to Look figure if it already exists
    figure(h.Look); return;
end  
%%% Loads user profile    
LSUserValues(0);
%%% Disables negative values for log plot warning
warning('off','MATLAB:Axes:NegativeDataInLogAxis');
%%% To save typing
Look = UserValues.Look;
%% Generates the Look figure
h.Look = figure(...
    'Units','normalized',...
    'Tag','Look',...
    'Name','Pam Look Setup',...
    'NumberTitle','off',...
    'Menu','none',...
    'defaultUicontrolFontName',Look.Font,...
    'defaultAxesFontName',Look.Font,...
    'defaultTextFontName',Look.Font,...
    'UserData',[],...
    'OuterPosition',[0.11 0.2 0.8 0.7],...
    'CloseRequestFcn',@Close_Look,...
    'Visible','on');

%%% Sets background of axes and other things
whitebg(Look.Axes);
%%% Changes Pam background; must be called after whitebg
h.Look.Color=Look.Back;

h.Look_Panel = uibuttongroup(...
    'Parent',h.Look,...
    'Tag','Progress_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'ButtonDownFcn',{@Change_Look,0},...
    'Position',[0.01 0.01 0.98 0.98]);

%% Axes for 2D plots
h.Look_Axes2D = axes(...
    'Parent',h.Look_Panel,...
    'Tag','Progress_Axes',...
    'Units','normalized',...
    'Color',Look.Axes,...
    'Position',[0.05 0.35 0.35 0.6],...
    'FontSize',12,...
    'NextPlot','add',...
    'ButtonDownFcn',{@Change_Look,0},...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'XLim',[0 1000],...
    'YLim', [0 1.05]);
plot(h.Look_Axes2D, 1:1000, exp(-((1:1000)-300).^2./10000),'LineWidth',2,'Color','y');
plot(h.Look_Axes2D, 1:1000, exp(-((1:1000)-500).^2./5000),'LineWidth',2,'Color','c');
plot(h.Look_Axes2D, 1:1000, exp(-((1:1000)-700).^2./15000),'LineWidth',2,'Color','b');
h.Look_Axes2D.XLabel.String = 'X Axis Label';
h.Look_Axes2D.XLabel.Color = Look.Fore;
h.Look_Axes2D.YLabel.String = 'Y Axis Label';
h.Look_Axes2D.YLabel.Color = Look.Fore;
grid minor
h.AxesText2D = text(...
    'Parent',h.Look_Axes2D,...
    'Position',[10,1.02],...
    'FontSize',14,...
    'Color',Look.AxesFore,...
    'ButtonDownFcn',{@Change_Look,8},...
    'String','Axes Text');
%% Axes for 3D plots
h.Look_Axes3D = axes(...
    'Parent',h.Look_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'ZColor',Look.Fore,...
    'NextPlot','add',...
    'ButtonDownFcn',{@Change_Look,0},...
    'View',[145,25],...
    'ZLim', [-0.05 1.05],...
    'Position',[0.5 0.35 0.48 0.6]);  
colormap(jet);
h.Look_Colorbar = colorbar;
h.Look_Colorbar.YColor = Look.Fore;
h.Look_Colorbar.Label.String = 'Colorbar';
h.Look_Colorbar.Label.Color = Look.Fore;

[X,Y] = meshgrid(1:20,(1:20)');
h.Plots.Main=surf(exp(-((X-10).^2+(Y-10).^2)./10),...
    'Parent',h.Look_Axes3D,...
    'FaceColor','Flat');
h.Look_Axes3D.XLabel.String = 'X Axis Label';
h.Look_Axes3D.XLabel.Color = Look.Fore;
h.Look_Axes3D.YLabel.String = 'Y Axis Label';
h.Look_Axes3D.YLabel.Color = Look.Fore;
h.Look_Axes3D.ZLabel.String = 'Z Axis Label';
h.Look_Axes3D.ZLabel.Color = Look.Fore;
grid minor
h.AxesText3D = text(...
    'Parent',h.Look_Axes3D,...
    'Position',[18, 2, 1],...
    'FontSize',14,...
    'Color',Look.AxesFore,...
    'ButtonDownFcn',{@Change_Look,8},...
    'String','Axes Text');
%% Controls
h.Look_Button = uicontrol(...
    'Parent',h.Look_Panel,...
    'Units','normalized',...
    'Position',[0.01 0.2 0.06 0.03],...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'FontSize',12,...
    'Style', 'Push',...
    'Enable','inactive',...
    'ButtonDownFcn',{@Change_Look,1},...
    'String','Button');
h.Look_Edit = uicontrol(...
    'Parent',h.Look_Panel,...
    'Units','normalized',...
    'Position',[0.08 0.2 0.06 0.03],...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'FontSize',12,...
    'Style', 'Edit',...
    'Enable','inactive',...
    'ButtonDownFcn',{@Change_Look,1},...
    'String','Edit');
h.Look_Disabled = uicontrol(...
    'Parent',h.Look_Panel,...
    'Units','normalized',...
    'Position',[0.01 0.16 0.06 0.03],...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Disabled,...
    'FontSize',12,...
    'Style', 'Push',...
    'Enable','inactive',...
    'ButtonDownFcn',{@Change_Look,4},...
    'String','Button');
h.Look_Check = uicontrol(...
    'Parent',h.Look_Panel,...
    'Units','normalized',...
    'Position',[0.08 0.16 0.06 0.03],...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'FontSize',12,...
    'Style', 'Check',...
    'Enable','inactive',...
    'ButtonDownFcn',{@Change_Look,1},...
    'String','Text');
h.Look_Shadow = uicontrol(...
    'Parent',h.Look_Panel,...
    'Units','normalized',...
    'Position',[0.01 0.12 0.06 0.03],...
    'BackgroundColor', Look.Shadow,...
    'ForegroundColor', 1-Look.Shadow,...
    'FontSize',12,...
    'Style', 'Push',...
    'Enable','inactive',...
    'ButtonDownFcn',{@Change_Look,5},...
    'String','Shadow');
h.Look_List = uicontrol(...
    'Parent',h.Look_Panel,...
    'Units','normalized',...
    'Position',[0.15 0.12 0.12 0.11],...
    'BackgroundColor', Look.List,...
    'ForegroundColor', Look.ListFore,...
    'FontSize',12,...
    'Style', 'List',...
    'Enable','inactive',...
    'Max',2,...
    'Value',[],...
    'ButtonDownFcn',{@Change_Look,8},...
    'String',{'List 1'; 'List 2'} );
h.Look_Table = uitable(...
    'Parent',h.Look_Panel,...
    'Units','normalized',...
    'Position',[0.28 0.12 0.12 0.11],...
    'BackgroundColor', [Look.Table1;Look.Table2],...
    'ForegroundColor', Look.TableFore,...
    'FontSize',12,...
    'Enable','inactive',...
    'Data',{'Entry1';'Entry2'},...
    'ButtonDownFcn',{@Change_Look,10});

h.Look_Reset = uicontrol(...
    'Parent',h.Look_Panel,...
    'Units','normalized',...
    'Position',[0.01 0.04 0.13 0.07],...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'FontSize',16,...
    'Style', 'Push',...
    'Enable','inactive',...
    'ButtonDownFcn',{@Change_Look,12},...
    'String','Reset');
h.Look_Text = uicontrol(...
    'Parent',h.Look_Panel,...
    'Units','normalized',...
    'Position',[0.5 0.04 0.13 0.07],...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'FontSize',28,...
    'Style', 'text',...
    'Enable','on',...
    'ButtonDownFcn',{@Change_Look,13},...
    'String',Look.Font);
%% Saves handles
guidata(h.Look,h);  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions that executes upon closing of Look window %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Close_Look(Obj,~)
Phasor=findobj('Tag','Phasor');
FCSFit=findobj('Tag','FCSFit');
MIAFit=findobj('Tag','MIAFit');
Mia=findobj('Tag','Mia');
Sim=findobj('Tag','Sim');
PCF=findobj('Tag','PCF');
BurstBrowser=findobj('Tag','BurstBrowser');
TauFit=findobj('Tag','TauFit');
PhasorTIFF = findobj('Tag','PhasorTIFF');
Pam = findobj('Tag','Pam');
if isempty(Phasor) && isempty(FCSFit) && isempty(MIAFit) && isempty(PCF) &&...
   isempty(Mia) && isempty(Sim) && isempty(BurstBrowser) && isempty(TauFit) &&...
   isempty(PhasorTIFF) && isempty(Pam)
    clear global -regexp UserValues
end
delete(Obj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions change the color p?roperties of pam windows %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Change_Look(Obj,~,mode)
global UserValues
h = guidata(findobj('Tag','Look'));

if strcmp(h.Look.SelectionType,'alt')
    switch Obj
        case {h.Look_Button; h.Look_Edit}
            mode = 2;
        case {h.Look_Check; h.Look_Panel; h.Look_Disabled}
            mode = 3;
        case {h.Look_Axes2D; h.Look_Axes3D}
            mode = 6;
        case {h.Look_List}
            mode = 9;
        case {h.Look_Table}
            mode = 11;
    end
end

if any(mode == 1:11)
    Color = uisetcolor;
    if numel(Color)~=3
        return;
    end
end

LSUserValues(0);
switch mode
    case 1 %%% Foreground
        h.Look_Button.ForegroundColor = Color;
        h.Look_Reset.ForegroundColor = Color;
        h.Look_Edit.ForegroundColor = Color;
        h.Look_Check.ForegroundColor = Color;
        h.Look_Axes3D.XColor = Color;
        h.Look_Axes3D.YColor = Color;
        h.Look_Axes3D.ZColor = Color;        
        h.Look_Colorbar.YColor = Color;
        h.Look_Colorbar.Label.Color = Color;
        h.Look_Axes3D.XLabel.Color = Color;
        h.Look_Axes3D.YLabel.Color = Color;
        h.Look_Axes3D.ZLabel.Color = Color;
        h.Look_Axes2D.XColor = Color;
        h.Look_Axes2D.YColor = Color;
        h.Look_Axes2D.XLabel.Color = Color;
        h.Look_Axes2D.YLabel.Color = Color;        
        UserValues.Look.Fore = Color;
    case 2 %%% Control
        h.Look_Button.BackgroundColor = Color;
        h.Look_Reset.BackgroundColor = Color;
        h.Look_Edit.BackgroundColor = Color;
        h.Look_Panel.HighlightColor = Color;
        UserValues.Look.Control = Color;
    case 3 %%% Background
        h.Look_Check.BackgroundColor = Color;
        h.Look_Disabled.BackgroundColor = Color;
        h.Look_Panel.BackgroundColor = Color;
        h.Look.Color = Color;
        UserValues.Look.Back = Color;
    case 4 %%% Disabled
        h.Look_Disabled.ForegroundColor = Color;
        UserValues.Look.Disabled = Color;
    case 5 %%% Shadow
        h.Look_Panel.ShadowColor = Color;
        h.Look_Shadow.ForegroundColor = 1-Color;
        h.Look_Shadow.BackgroundColor = Color;
        UserValues.Look.Shadow = Color;
    case 6 %%% Axes
        h.Look_Axes2D.Color = Color;
        h.Look_Axes3D.Color = Color;
        UserValues.Look.Axes = Color;
    case 7 %%% AxesForew
        h.Look_AxesText2D.Color = Color;
        h.Look_AxesText3D.Color = Color;
        UserValues.Look.AxesFore = Color;
    case 8 %%% ListFore
        h.Look_List.ForegroundColor = Color;
        UserValues.Look.ListFore = Color;
    case 9 %%% List
        h.Look_List.BackgroundColor = Color;
        UserValues.Look.List = Color;
    case 10 %%% TableFore
        h.Look_Table.ForegroundColor = Color;
        UserValues.Look.TableFore = Color;
    case 11 %%% Table1 and Table2
        Color2 = uisetcolor;
        if numel(Color2)~=3
            return;
        end
        h.Look_Table.BackgroundColor = [Color;Color2];
        UserValues.Look.Table1 = Color;
        UserValues.Look.Table2 = Color2;
    case 12 %%% Reset
        UserValues.Look.Fore = [1 1 1];     
        h.Look_Button.ForegroundColor = UserValues.Look.Fore;
        h.Look_Reset.ForegroundColor = UserValues.Look.Fore;
        h.Look_Edit.ForegroundColor = UserValues.Look.Fore;
        h.Look_Check.ForegroundColor = UserValues.Look.Fore;
        h.Look_Axes3D.XColor = UserValues.Look.Fore;
        h.Look_Axes3D.YColor = UserValues.Look.Fore;
        h.Look_Axes3D.ZColor = UserValues.Look.Fore;        
        h.Look_Colorbar.YColor = UserValues.Look.Fore;
        h.Look_Colorbar.Label.Color = UserValues.Look.Fore;
        h.Look_Axes3D.XLabel.Color = UserValues.Look.Fore;
        h.Look_Axes3D.YLabel.Color = UserValues.Look.Fore;
        h.Look_Axes3D.ZLabel.Color = UserValues.Look.Fore;
        h.Look_Axes2D.XColor = UserValues.Look.Fore;
        h.Look_Axes2D.YColor = UserValues.Look.Fore;
        h.Look_Axes2D.XLabel.Color = UserValues.Look.Fore;
        h.Look_Axes2D.YLabel.Color = UserValues.Look.Fore;  
        
        UserValues.Look.Control = [0.4 0.4 0.4];
        h.Look_Button.BackgroundColor = UserValues.Look.Control;
        h.Look_Reset.BackgroundColor = UserValues.Look.Control;
        h.Look_Edit.BackgroundColor = UserValues.Look.Control;
        h.Look_Panel.HighlightColor = UserValues.Look.Control; 
        
        UserValues.Look.Back = [0.2 0.2 0.2];
        h.Look_Check.BackgroundColor = UserValues.Look.Back;
        h.Look_Disabled.BackgroundColor = UserValues.Look.Back;
        h.Look_Panel.BackgroundColor = UserValues.Look.Back;
        h.Look.Color = UserValues.Look.Back;
        
        UserValues.Look.Disabled = [0 0 0];
        h.Look_Disabled.ForegroundColor = UserValues.Look.Disabled;
        
        UserValues.Look.Shadow = [0.4 0.4 0.4];
        h.Look_Panel.ShadowColor = UserValues.Look.Shadow;
        h.Look_Shadow.ForegroundColor = 1-UserValues.Look.Shadow;
        h.Look_Shadow.BackgroundColor = UserValues.Look.Shadow;
        
        UserValues.Look.Axes = [0.8 0.8 0.8];
        h.Look_Axes2D.Color = UserValues.Look.Axes;
        h.Look_Axes3D.Color = UserValues.Look.Axes;
        
        UserValues.Look.AxesFore = [0 0 0];
        h.Look_AxesText2D.Color = UserValues.Look.AxesFore;
        h.Look_AxesText3D.Color = UserValues.Look.AxesFore;
        
        UserValues.Look.ListFore = [0 0 0];
        h.Look_List.ForegroundColor = UserValues.Look.ListFore;
        
        UserValues.Look.List = [0.8 0.8 0.8];
        h.Look_List.BackgroundColor = UserValues.Look.List;
        
        UserValues.Look.TableFore = [0 0 0];
        h.Look_Table.ForegroundColor = UserValues.Look.TableFore;
        
        UserValues.Look.Table1 = [0.9 0.9 0.9];
        UserValues.Look.Table2 = [0.8 0.8 0.8];
        h.Look_Table.BackgroundColor = [UserValues.Look.Table1;UserValues.Look.Table2];
        
        UserValues.Look.Font = 'Times';
        h.Look_Text.String = UserValues.Look.Font;
    case 13
        Font = uisetfont;
        UserValues.Look.Font = Font.FontName;
        h.Look_Text.String = Font.FontName;
        h.Look_Text.FontName = Font.FontName;
        f = fieldnames(h);
        for i = 1:numel(f)
            if isprop(h.(f{i}),'FontName')
                h.(f{i}).FontName = Font.FontName;
            end
        end
end
LSUserValues(1);
