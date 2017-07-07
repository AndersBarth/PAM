%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Phasor referencing for TIFF based data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PhasorTIFF(~,~)
global UserValues
h.PhasorTIFF = findobj('Tag','PhasorTIFF');

addpath(genpath(['.' filesep 'functions']));

if isempty(h.PhasorTIFF)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Figure generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Disables uitabgroup warning
    warning('off','MATLAB:uitabgroup:OldVersion');
    %%% Loads user profile
    LSUserValues(0);
    %%% To save typing
    Look=UserValues.Look;
    %%% Generates the Pam figure
    h.PhasorTIFF = figure(...
        'Units','normalized',...
        'Tag','PhasorTIFF',...
        'Name','PhasorTIFF',...
        'NumberTitle','off',...
        'Menu','none',...
        'defaultUicontrolFontName',Look.Font,...
        'defaultAxesFontName',Look.Font,...
        'defaultTextFontName',Look.Font,...
        'defaultAxesYColor',Look.Fore,...
        'Toolbar','figure',...
        'UserData',[],...
        'BusyAction','cancel',...
        'OuterPosition',[0.01 0.1 0.98 0.9],...
        'CloseRequestFcn',@CloseWindow,...
        'Visible','on');
    %%% Sets background of axes and other things
    whitebg(Look.Fore);
    %%% Changes Pam background; must be called after whitebg
    h.PhasorTIFF.Color=Look.Back;
    %%% Remove unneeded items from toolbar
    toolbar = findall(h.PhasorTIFF,'Type','uitoolbar');
    toolbar_items = findall(toolbar);
    delete(toolbar_items([2:7 9 13:17]));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Menues %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% Menues for loading Phasor Data
    h.Load = uimenu(...
    'Parent',h.PhasorTIFF,...
    'Label','Load...',...
    'Tag','Load');
    h.Load_Ref = uimenu(...
    'Parent',h.Load,...
    'Label','...Reference Data',...
    'Callback',{@Load_Data,1},...
    'Tag','Load_Reference_Data');
    h.Load_Tif = uimenu(...
    'Parent',h.Load,...
    'Label','...Data',...
    'Callback',{@Load_Data,2},...
    'Tag','Load_Data');
    
    %%% Menues for Saving Phasor Data
    h.Save = uimenu(...
    'Parent',h.PhasorTIFF,...
    'Label','Save...',...
    'Tag','Save');
    h.Save_Phasor = uimenu(...
    'Parent',h.Save,...
    'Label','...Phasor Data',...
    'Callback',{@Calc_Phasor,1},...
    'Tag','Save_Phasor');
    h.Save_Phasor_Multi = uimenu(...
    'Parent',h.Save,...
    'Label','...Multiple Phasor Data',...
    'Callback',{@Calc_Phasor,2},...
    'Tag','Save_Phasor_Multi');  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Progressbar and file name %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Panel for progressbar
    h.Progress_Panel = uibuttongroup(...
        'Parent',h.PhasorTIFF,...
        'Tag','Progress_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0.05 0.96 0.8 0.03]);
    %%% Axes for progressbar
    h.Progress_Axes = axes(...
        'Parent',h.Progress_Panel,...
        'Tag','Progress_Axes',...
        'Units','normalized',...
        'Color',Look.Control,...
        'Position',[0 0 1 1]);
    h.Progress_Axes.XTick = []; 
    h.Progress_Axes.YTick = [];
    %%% Progress and filename text
    h.Progress_Text = text(...
        'Parent',h.Progress_Axes,...
        'Tag','Progress_Text',...
        'Units','normalized',...
        'FontSize',12,...
        'FontWeight','bold',...
        'String','Nothing loaded',...
        'Interpreter','none',...
        'HorizontalAlignment','center',...
        'BackgroundColor','none',...
        'Color',Look.Fore,...
        'Position',[0.5 0.5]);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%% Lifetime histogram / Modulation plot
    h.Phasor_Axes=axes(...
        'Parent',h.PhasorTIFF,...
        'Tag','Phasor_Axes',...
        'Units','normalized',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'Position',[0.05 0.48 0.8 0.46],...
        'Box','on');
    h.Phasor_Axes.XLabel.String = 'Phase Channel';
    h.Phasor_Axes.XLabel.Color = Look.Fore;
    h.Phasor_Axes.YLabel.String = 'Normalized Counts';
    h.Phasor_Axes.YLabel.Color = Look.Fore;
    hold on;
    h.Plot_Ref = plot([0 1],[0 0],'b');
    h.Plot_Data = plot([0 1],[0 0],'r');
    h.Plot_Last = plot([0 1],[0 0],'g');
    
    %%% Intensity Image plot
    h.Text = {};
    h.Text{end+1} = uicontrol(...
        'Style','text',...
        'Parent',h.PhasorTIFF,...
        'Units','normalized',...
        'Fontsize',16,...
        'Position', [0.01 0.4 0.25 0.03],...
        'Backgroundcolor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'String', 'Intensity image');    
    h.Intensity_Axes = axes(...
        'Parent',h.PhasorTIFF,...
        'Tag','Intensity_Axes',...
        'Units','normalized',...
        'Position',[0.01 0.03 0.3 0.35],...
        'Box','on');
    h.Plot_Image = imagesc(zeros(2));
    h.Intensity_Axes.XTick = [];
    h.Intensity_Axes.YTick = [];
    h.Intensity_Axes.DataAspectRatio = [1 1 1];
    h.Intensity.Colorbar = colorbar(h.Intensity_Axes);
    h.Intensity.Colorbar.YColor = Look.Fore;
    h.Intensity.Colorbar.Label.String = 'Counts';
    h.Intensity.Colorbar.Label.Color = Look.Fore;
       
    %%% TauP/TauM intensity plot
    h.Text{end+1} = uicontrol(...
        'Style','text',...
        'Parent',h.PhasorTIFF,...
        'Units','normalized',...
        'Fontsize',16,...
        'Position', [0.335 0.4 0.25 0.03],...
        'Backgroundcolor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'String', 'TauM image');    
    h.TauP_Axes = axes(...
        'Parent',h.PhasorTIFF,...
        'Tag','TauP_Axes',...
        'Units','normalized',...
        'Position',[0.335 0.03 0.3 0.35],...
        'Box','on');
    h.Plot_TauP = imagesc(zeros(2));
    h.TauP_Axes.XTick = [];
    h.TauP_Axes.YTick = [];
    h.TauP_Axes.DataAspectRatio = [1 1 1];
    h.TauP.Colorbar = colorbar(h.TauP_Axes);
    h.TauP.Colorbar.YColor = Look.Fore;
    h.TauP.Colorbar.Label.String = 'Counts';
    h.TauP.Colorbar.Label.Color = Look.Fore;
    
    h.Text{end+1} = uicontrol(...
        'Style','text',...
        'Parent',h.PhasorTIFF,...
        'Units','normalized',...
        'Fontsize',16,...
        'Position', [0.68 0.4 0.25 0.03],...
        'Backgroundcolor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'String', 'TauP image');    
    h.TauM_Axes=axes(...
        'Parent',h.PhasorTIFF,...
        'Tag','TauM_Axes',...
        'Units','normalized',...
        'Position',[0.68 0.03 0.3 0.35],...
        'Box','on');
    h.Plot_TauM = imagesc(zeros(2));
    h.TauM_Axes.XTick = [];
    h.TauM_Axes.YTick = [];
    h.TauM_Axes.DataAspectRatio = [1 1 1];
    h.TauM.Colorbar = colorbar(h.TauM_Axes);
    h.TauM.Colorbar.YColor = Look.Fore;
    h.TauM.Colorbar.Label.String = 'Counts';
    h.TauM.Colorbar.Label.Color = Look.Fore;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Setting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    h.Text{end+1} = uicontrol(...
        'Style','text',...
        'Parent',h.PhasorTIFF,...
        'Units','normalized',...
        'Fontsize',12,...
        'HorizontalAlignment','left',...
        'Position', [0.86 0.95 0.13 0.03],...
        'Backgroundcolor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'String', 'Frequency [Mhz]:');    
    h.Freq = uicontrol(...
        'Parent',h.PhasorTIFF,...
        'Units','normalized',...
        'Position',[0.86 0.92 0.13 0.03],...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Tag','Freq',...
        'HorizontalAlignment','right',...
        'FontSize',12,...
        'Style', 'Edit',...
        'String','70'); 
    
    h.Text{end+1} = uicontrol(...
        'Style','text',...
        'Parent',h.PhasorTIFF,...
        'Units','normalized',...
        'Fontsize',12,...
        'HorizontalAlignment','left',...
        'Position', [0.86 0.88 0.13 0.03],...
        'Backgroundcolor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'String', 'Reference lifetime [ns]:');    
    h.LT_Ref = uicontrol(...
        'Parent',h.PhasorTIFF,...
        'Units','normalized',...
        'Position',[0.86 0.85 0.13 0.03],...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Tag','LT_Ref',...
        'HorizontalAlignment','right',...
        'FontSize',12,...
        'Style', 'Edit',...
        'String','3.9');
    
    h.Text{end+1} = uicontrol(...
        'Style','text',...
        'Parent',h.PhasorTIFF,...
        'Units','normalized',...
        'Fontsize',12,...
        'HorizontalAlignment','left',...
        'Max',2,...
        'Position', [0.86 0.8 0.13 0.04],...
        'Backgroundcolor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'String', 'Intensity threshold [% of max]');    
    h.Fraction = uicontrol(...
        'Parent',h.PhasorTIFF,...
        'Units','normalized',...
        'Position',[0.86 0.76 0.13 0.03],...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Tag','Fraction',...
        'HorizontalAlignment','right',...
        'FontSize',12,...
        'Style', 'Edit',...
        'String','10',...
        'Callback',{@Update_Plots,1});
    
    h.Text{end+1} = uicontrol(...
        'Style','text',...
        'Parent',h.PhasorTIFF,...
        'Units','normalized',...
        'Fontsize',12,...
        'HorizontalAlignment','left',...
        'Position', [0.86 0.72 0.13 0.03],...
        'Backgroundcolor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'String', 'Median filter deviation:');    
    h.Median = uicontrol(...
        'Parent',h.PhasorTIFF,...
        'Units','normalized',...
        'Position',[0.86 0.69 0.13 0.03],...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Tag','Median',...
        'HorizontalAlignment','right',...
        'FontSize',12,...
        'Style', 'Edit',...
        'String','2');
    
    h.Text{end+1} = uicontrol(...
        'Style','text',...
        'Parent',h.PhasorTIFF,...
        'Units','normalized',...
        'Fontsize',12,...
        'HorizontalAlignment','left',...
        'Position', [0.86 0.65 0.13 0.03],...
        'Backgroundcolor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'String', 'Lifetime limits [ns]:');    
    h.LT_Min = uicontrol(...
        'Parent',h.PhasorTIFF,...
        'Units','normalized',...
        'Position',[0.86 0.62 0.06 0.03],...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Tag','LT_Min',...
        'HorizontalAlignment','right',...
        'FontSize',12,...
        'Style', 'Edit',...
        'String','0');    
    h.LT_Max = uicontrol(...
        'Parent',h.PhasorTIFF,...
        'Units','normalized',...
        'Position',[0.93 0.62 0.06 0.03],...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Tag','LT_Max',...
        'HorizontalAlignment','right',...
        'FontSize',12,...
        'Style', 'Edit',...
        'String','4');
    
    h.Text{end+1} = uicontrol(...
        'Style','text',...
        'Parent',h.PhasorTIFF,...
        'Units','normalized',...
        'Fontsize',12,...
        'HorizontalAlignment','left',...
        'Position', [0.86 0.58 0.13 0.03],...
        'Backgroundcolor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'String', 'Moving average [Pixel]:');    
    h.MA_Span = uicontrol(...
        'Parent',h.PhasorTIFF,...
        'Units','normalized',...
        'Position',[0.86 0.55 0.13 0.03],...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Tag','MA_Span',...
        'HorizontalAlignment','right',...
        'FontSize',12,...
        'Style', 'Edit',...
        'String','1');
    
    h.Use_Mean = uicontrol(...
        'Parent',h.PhasorTIFF,...
        'Units','normalized',...
        'Position',[0.86 0.51 0.13 0.03],...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Tag','Median',...
        'HorizontalAlignment','right',...
        'FontSize',12,...
        'Style', 'Checkbox',...
        'Value',0,...
        'String','Use mean for ploting',...
        'Callback',{@Update_Plots,[1 2]});
    
    h.Invert_Tif = uicontrol(...
        'Parent',h.PhasorTIFF,...
        'Units','normalized',...
        'Position',[0.86 0.48 0.13 0.03],...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Tag','Invert_Tif',...
        'HorizontalAlignment','right',...
        'FontSize',12,...
        'Style', 'Checkbox',...
        'Value',0,...
        'String','Invert TIFs',...
        'Callback',{@Update_Plots,[1 2]});
    guidata(h.PhasorTIFF,h);
else
    figure(h.PhasorTIFF);
end
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Loads and displays new data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Data(~,~,mode,FileName,PathName)
global PhasorTIFFData UserValues
h = guidata(findobj('Tag','PhasorTIFF'));
LSUserValues(0);

if nargin<5
    %%% Selects a file to load
    [FileName, PathName] = uigetfile({'.tif';}, 'Choose a FLIM file to load', UserValues.File.PhasorTIFFPath, 'Multiselect', 'on');
    if ~iscell(FileName)
        FileName={FileName};
    end
end

if all(FileName{1}==0) && ~exist(fullfile(PathName,FileName{1}),'file')
    return
end

UserValues.File.PhasorTIFFPath=PathName;
LSUserValues(1);
FileInfo=imfinfo(fullfile(PathName,FileName{1}));

switch mode
    case 1 %%% Reference data
        Progress (0, h.Progress_Axes, h.Progress_Text,'Loading Reference Files:')
        PhasorTIFFData.Reference = single(zeros(FileInfo(1).Height,FileInfo(1).Width,numel(FileInfo)));
        %%% Read TIFs frame by frame and sums up all selected files
        for j = 1:numel(FileName)
            for i = 1:numel(FileInfo);
                PhasorTIFFData.Reference(:,:,i) = PhasorTIFFData.Reference(:,:,i)+single(imread(fullfile(PathName,FileName{j}),'TIFF','Index',i));
            end
            Progress (j/numel(FileName), h.Progress_Axes, h.Progress_Text,'Loading Reference Files:')
        end        
        Update_Plots ([],[],1)
        
    case 2 %%% Actual data
        if nargin<5
            Progress (0, h.Progress_Axes, h.Progress_Text,'Loading Files:')
        end
        PhasorTIFFData.Data=single(zeros(FileInfo(1).Height,FileInfo(1).Width,numel(FileInfo)));
        %%% Read TIFs frame by frame and sums up all selected files
        for j = 1:numel(FileName)
            for i = 1:numel(FileInfo);
                PhasorTIFFData.Data(:,:,i) = PhasorTIFFData.Data(:,:,i)+single(imread(fullfile(PathName,FileName{j}),'TIFF','Index',i));
            end
            if nargin<5
                Progress (j/numel(FileName), h.Progress_Axes, h.Progress_Text,'Loading Files:')
            end
        end
        %%% Sets negative intensities to 0
        PhasorTIFFData.Data(PhasorTIFFData.Data<0) = 0;
        PhasorTIFFData.FileNames = FileName;
        Update_Plots ([],[],2)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculated Phasor and saved data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Calc_Phasor(~,~,mode)
global PhasorTIFFData UserValues
h = guidata(findobj('Tag','PhasorTIFF'));
LSUserValues(0);

To = size(PhasorTIFFData.Reference,3);
Freq = str2double(h.Freq.String)*10^6;
LT = str2double(h.LT_Ref.String)*10^-9;

%%% Only executes, if Reference Data was loaded
if ~isfield(PhasorTIFFData,'Reference')    
    return;
end

switch mode
    case 1 %% Save loaded file
        %%% Choose filename
        [FileName,PathName] = uiputfile('*.phr','Save Phasor Data',UserValues.File.PhasorPath);
        
        %%% Only executes, if Data was loaded and a filename selected
        if all(FileName==0) || ~isfield(PhasorTIFFData,'Data')
            return
        end
        Progress(0);
        
        UserValues.File.PhasorPath=PathName;
        LSUserValues(1);
        
        %%% Inverts timeaxis if selected (needed for some systems)
        if h.Invert_Tif.Value
            Reference = flip(PhasorTIFFData.Reference,3);
            Data1 = flip(PhasorTIFFData.Data,3);
        else
            Reference = PhasorTIFFData.Reference;
            Data1 = PhasorTIFFData.Data;
        end
        %%% Discards reference pixels below certain treshold (to minimize
        %%% background and artifacts) and normalizes referecne
        Scale=sum(Reference,3) > str2double(h.Fraction.String)/100*max(max(sum(Reference,3)));      
        Reference = squeeze(sum(sum(Reference.*repmat(Scale,[1 1 size(Reference,3)]),1),2));
        Reference = Reference/sum(Reference);
        
        %%% Calculates theoretical phase and modulation for reference
        Fi_ref = atan((2*pi*Freq*LT));
        M_ref  = 1/sqrt(1+(2*pi*Freq*LT)^2);

        %%% Applies moving average (Span=1 equals no averaging)
        Span = str2double(h.MA_Span.String);
        Data1(end+Span-1,end+Span-1,end) = 0;
        Data=zeros(size(Data1));
        for i=floor(-Span/2+1):floor(Span/2)
            for k=floor(-Span/2+1):floor(Span/2);
                Data=Data+circshift(Data1,[i,k,0]);
            end
        end
        Data = Data(1:size(PhasorTIFFData.Data,1),1:size(PhasorTIFFData.Data,2),:);
        %%% Normalized data
        Data = Data./repmat(sum(Data,3),1,1,size(Data,3));
        
        %%% Calculates phase and modulation of the instrument
        G_inst(1:To) = cos((2*pi/To).*(0:(To-1))-Fi_ref)/M_ref;
        S_inst(1:To) = sin((2*pi/To).*(0:(To-1))-Fi_ref)/M_ref;
        g_inst = sum(Reference(1:To).*G_inst');
        s_inst = sum(Reference(1:To).*S_inst');
        Fi_inst = atan(s_inst/g_inst);
        M_inst = sqrt(s_inst^2+g_inst^2);
        if (g_inst<0 && s_inst<0)
            Fi_inst = Fi_inst+pi;
        end
        
        %%%% Phasor for whole Image
        G(1,1,1:To) = single(cos((2*pi/To).*(0:(To-1))-Fi_inst)/M_inst);
        G = repmat(G,[size(Data,1),size(Data,2),1]);
        S(1,1,1:To) = single(sin((2*pi/To).*(0:(To-1))-Fi_inst)/M_inst);
        S = repmat(S,[size(Data,1),size(Data,2),1]);
        g = double(sum(G.*Data,3));
        s = double(sum(S.*Data,3));
        clear G S Data
        
        %%% Changes NaN to zeros
        s(isnan(g)) = 0; g(isnan(g)) = 0;
        g(isnan(s)) = 0; s(isnan(s)) = 0;
        
        %%% If phase is off by pi
        neg = s<0 & g<0;
        s(neg) = -s(neg);
        g(neg) = -g(neg);
        
        %%% Calculates TauM and TauP
        TauP = real((s./g)./(2*pi*Freq))*10^9;
        TauM = real(sqrt((1./(s.^2+g.^2))-1)/(2*pi*Freq))*10^9;
        
        %%% Updates TauM and TauP images 
        PhasorTIFFData.TauM = TauM;
        PhasorTIFFData.TauP = TauP;        
        Update_Plots([],[],3);
        
        %%% Generates some variables needed for Phasor
        Frames=1; %#ok<NASGU>
        Imagetime=1000; %#ok<NASGU>
        Intensity=sum(PhasorTIFFData.Data,3);
        Lines=size(g,1); %#ok<NASGU>
        Path = PathName; %#ok<NASGU>
        FileNames = FileName;
        if ~iscell(FileNames)
            FileNames = {FileNames}; %#ok<NASGU>
        end
        
        %%% Generates an imagae with the hue corresponding to the
        %%% lifetime and the brightness to the intensity
        LT_Max = str2double(h.LT_Max.String);
        LT_Min = str2double(h.LT_Min.String);
        Color = jet(64);
        
        TauM_rgb = ceil((TauM-LT_Min)/(LT_Max-LT_Min)*64);
        TauM_rgb(TauM_rgb>64) = 64;
        TauM_rgb(TauM_rgb<1 | isnan(TauM_rgb)) = 1;
        TauM_RGB = repmat(TauM_rgb,[1 1 3]);
        
        TauP_rgb = ceil((TauP-LT_Min)/(LT_Max-LT_Min)*64);
        TauP_rgb(TauP_rgb>64) = 64;
        TauP_rgb(TauP_rgb<1 | isnan(TauP_rgb)) = 1;
        TauP_RGB=repmat(TauP_rgb,[1 1 3]);
        
        for i=1:3
            TauM_RGB(:,:,i) = Intensity/max(max(Intensity)).*reshape(Color(TauM_rgb(:),i),size(TauM_rgb));
            TauP_RGB(:,:,i) = Intensity/max(max(Intensity)).*reshape(Color(TauP_rgb(:),i),size(TauM_rgb));
        end
        
        %%% Calculates mean arrival time (does not make sense for
        %%% frequency domain)
        Mean_LT = sum(PhasorTIFFData.Data.*permute(repmat(1:size(PhasorTIFFData.Data,3),[size(PhasorTIFFData.Data,1),1,size(PhasorTIFFData.Data,2)]),[1 3 2]),3)./sum(PhasorTIFFData.Data,3); %#ok<NASGU>
        
        %%% Saves Phasor file
        save(fullfile(PathName,FileName), 'g','s','Intensity','Lines','Freq','Imagetime','Frames','TauM','TauP','TauM_RGB','TauP_RGB','Mean_LT','Path','FileNames');
        Progress(1)
        
    case 2 %% Reference multiple files
        %%% Choose files to load
        [FileName,PathName] = uigetfile('*.tif','Choose FLIM data','Multiselect','on',UserValues.File.PhasorTIFFPath);

        if ~iscell(FileName)
            FileName={FileName};
        end
        
        %%% Only executes, if Data was loaded and a filename selected
        if numel(FileName) < 1 || all(FileName{1}==0)
            return;
        end
            
        Progress (0, h.Progress_Axes, h.Progress_Text,'Starting Calculations:')
        
        %%% Calculates theoretical phase and modulation for reference
        Fi_ref = atan((2*pi*Freq*LT));
        M_ref  = 1/sqrt(1+(2*pi*Freq*LT)^2);
        
        %%% Inverts timeaxis if selected (needed for some systems)
        if h.Invert_Tif.Value
            Reference = flip(PhasorTIFFData.Reference,3);
        else
            Reference = PhasorTIFFData.Reference;
        end
        %%% Discards reference pixels below certain treshold (to minimize
        %%% background and artifacts) and normalizes referecne
        Scale = sum(Reference,3) > str2double(h.Fraction.String)/100*max(max(sum(Reference,3)));      
        Reference = squeeze(sum(sum(Reference.*repmat(Scale,[1 1 size(Reference,3)]),1),2));
        Reference = Reference/sum(Reference);       
        
        %%% Calculates phase and modulation of the instrument
        G_inst(1:To) = cos((2*pi/To).*(0:(To-1))-Fi_ref)/M_ref;
        S_inst(1:To) = sin((2*pi/To).*(0:(To-1))-Fi_ref)/M_ref;
        g_inst = sum(Reference(1:To).*G_inst');
        s_inst = sum(Reference(1:To).*S_inst');
        Fi_inst = atan(s_inst/g_inst);
        M_inst = sqrt(s_inst^2+g_inst^2);
        if (g_inst<0 && s_inst<0)
            Fi_inst = Fi_inst+pi;
        end
        
        %%% Executes Phasor calculation for each selected file
        for j=1:numel(FileName);
            Progress ((j-1)/numel(FileName), h.Progress_Axes, h.Progress_Text,'Loading Files:')
            Load_Data([],[],2,FileName(j),PathName)
            Progress ((j-1)/numel(FileName), h.Progress_Axes, h.Progress_Text,'Calculating Phasor:')            
            %%% Inverts timeaxis if selected
            if h.Invert_Tif.Value
                Data1 = flip(PhasorTIFFData.Data,3);
            else
                Data1 = PhasorTIFFData.Data;
            end
            
            %%% Applies moving average (Span=1 equals no averaging)
            Span=str2double(h.MA_Span.String);
            Data1(end+Span-1,end+Span-1,end)=0;
            Data=zeros(size(Data1));
            for i=floor(-Span/2+1):floor(Span/2)
                for k=floor(-Span/2+1):floor(Span/2);
                    Data=Data+circshift(Data1,[i,k,0]);
                end
            end
            Data = Data(1:size(PhasorTIFFData.Data,1),1:size(PhasorTIFFData.Data,2),:);
            %%% Normalized data
            Data = Data./repmat(sum(Data,3),1,1,size(Data,3));
                        
            %%%% Phasor for whole Image
            G(1,1,1:To) = single(cos((2*pi/To).*(0:(To-1))-Fi_inst)/M_inst);
            G = repmat(G,[size(Data,1),size(Data,2),1]);
            S(1,1,1:To) = single(sin((2*pi/To).*(0:(To-1))-Fi_inst)/M_inst);
            S = repmat(S,[size(Data,1),size(Data,2),1]);
            g = double(sum(G.*Data,3));
            s = double(sum(S.*Data,3));
            clear G S Data
            
            %%% Changes NaN to zeros
            s(isnan(g)) = 0;g(isnan(g))=0;
            g(isnan(s)) = 0;s(isnan(s))=0;
            
            %%% If phase is off by pi
            neg = s<0 & g<0;
            s(neg) = -s(neg);
            g(neg) = -g(neg);
            
            %%% Calculated phase and modulation lifetimes
            TauP = real((s./g)./(2*pi*Freq))*10^9;
            TauP(isnan(TauP) | isinf(TauP) | TauP<0) = 0;
            TauM = real(sqrt((1./(s.^2+g.^2))-1)/(2*pi*Freq))*10^9;
            TauM(isnan(TauM) | isinf(TauM) | TauM<0) = 0;
            
            %%% Updates TauM and TauP images
            PhasorTIFFData.TauM = TauM;
            PhasorTIFFData.TauP = TauP;
            Update_Plots([],[],3);
            
            %%% Generates some variables needed for Phasor
            Frames = 1;
            Imagetime = 1000;
            Intensity = sum(PhasorTIFFData.Data,3);
            Lines = size(g,1);
            Path = PathName;
            FileNames = {FileName{j}};
            
            %%% Generates an imagae with the hue corresponding to the
            %%% lifetime and the brightness to the intensity
            LT_Max = str2double(h.LT_Max.String);
            LT_Min = str2double(h.LT_Min.String);
            Color = jet(64);
            
            TauM_rgb = ceil((TauM-LT_Min)/(LT_Max-LT_Min)*64);
            TauM_rgb(TauM_rgb>64) = 64;
            TauM_rgb(TauM_rgb<1) = 1;
            TauM_RGB = repmat(TauM_rgb,[1 1 3]);
            
            TauP_rgb = ceil((TauP-LT_Min)/(LT_Max-LT_Min)*64);
            TauP_rgb(TauP_rgb>64) = 64;
            TauP_rgb(TauP_rgb<1) = 1;
            TauP_RGB = repmat(TauP_rgb,[1 1 3]);
            
            for i=1:3
                TauM_RGB(:,:,i) = Intensity/max(max(Intensity)).*reshape(Color(TauM_rgb(:),i),size(TauM_rgb));
                TauP_RGB(:,:,i) = Intensity/max(max(Intensity)).*reshape(Color(TauP_rgb(:),i),size(TauM_rgb));
            end
            
            %%% Calculates mean arrival time (does not make sense for
            %%% frequency domain)
            Mean_LT = sum(PhasorTIFFData.Data.*permute(repmat(1:size(PhasorTIFFData.Data,3),[size(PhasorTIFFData.Data,1),1,size(PhasorTIFFData.Data,2)]),[1 3 2]),3)./sum(PhasorTIFFData.Data,3);
            Progress ((j-1)/numel(FileName), h.Progress_Axes, h.Progress_Text,'Saving File')
            save(fullfile(PathName,[FileName{j}(1:end-4) '.phr']), 'g','s','Intensity','Lines','Freq','Imagetime','Frames','TauM','TauP','TauM_RGB','TauP_RGB','Mean_LT','Path','FileNames');
            
            %%% Calculates mean paramteters
            
            %%% Uses only pixels with >fraction of  max intesity
            Scale=sum(PhasorTIFFData.Data,3) > str2double(h.Fraction.String)/100*max(max(sum(PhasorTIFFData.Data,3)));
            %%% Use median filter to remove outliers
            Scale = Scale.*(abs(g-median(g(:))) < str2double(h.Median.String)/100*median(g(:)));
            Scale = Scale.*(abs(s-median(s(:))) < str2double(h.Median.String)/100*median(s(:)));
            Scale = Scale.*(abs(TauM-median(TauM(:))) < str2double(h.Median.String)/100*median(TauM(:)));
            Scale = Scale.*(abs(TauP-median(TauP(:))) < str2double(h.Median.String)/100*median(TauP(:)));
            
            %%% Calculates mean values based on the median and
            %%% intensity filters
            Mean.g(j) = sum(sum(Scale.*sum(PhasorTIFFData.Data,3).*g))/sum(sum(Scale.*sum(PhasorTIFFData.Data,3)));
            Mean.s(j) = sum(sum(Scale.*sum(PhasorTIFFData.Data,3).*s))/sum(sum(Scale.*sum(PhasorTIFFData.Data,3)));
            Mean.TauM(j) = sum(sum(Scale.*sum(PhasorTIFFData.Data,3).*TauM))/sum(sum(Scale.*sum(PhasorTIFFData.Data,3)));
            Mean.TauP(j) = sum(sum(Scale.*sum(PhasorTIFFData.Data,3).*TauP))/sum(sum(Scale.*sum(PhasorTIFFData.Data,3)));
            
        end
        %%% Saves a textfile with mean parameters
        FileID=fopen([PathName filesep 'Mean_Phasor.txt'],'w');
        fprintf(FileID, 'g\t s\t TauM\t TauP\t Filename\n');
        for i=1:numel(Mean.g)
            fprintf(FileID, '%8.8f\t%8.8f\t%8.8f\t',[Mean.g(i);Mean.s(i); Mean.TauM(i); Mean.TauP(i)]);
            fprintf(FileID,[FileName{i} '\n']);
        end
        fclose(FileID);
        
        Progress (1, h.Progress_Axes, h.Progress_Text,'Done')
        PhasorTIFFData.FileNames = FileName;
        
        Update_Plots([],[],2);
        
        
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Updates Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Plots (~,~,mode)
global PhasorTIFFData
h = guidata(findobj('Tag','PhasorTIFF'));

if any(mode == 1) && isfield(PhasorTIFFData, 'Reference') %%% Reference Data
        %%% Sets pixels <fraction max intensity to 0 to remove artifacts
        %%% from edges;
        Scale=sum(PhasorTIFFData.Reference,3) > str2double(h.Fraction.String)/100*max(max(sum(PhasorTIFFData.Reference,3)));      
        Reference = PhasorTIFFData.Reference.*repmat(Scale,[1 1 size(PhasorTIFFData.Reference,3)]);
        
        %%% Inverts timeaxis if selected
        if h.Invert_Tif.Value
            Reference=flip(Reference,3);
        end
        %%% Sum up all pixels
        Reference=squeeze(sum(sum(Reference,1),2));
        
        %%% Plots data depending on the normalization procedure
        if h.Use_Mean.Value
            h.Plot_Ref.YData = Reference/mean(Reference);
        else
            h.Plot_Ref.YData = Reference/max(Reference);
        end
        h.Plot_Ref.XData=0:size(Reference)-1;
        if isfield(PhasorTIFFData, 'FileNames') && ~isempty(PhasorTIFFData.FileNames);
            h.Progress_Text.String = PhasorTIFFData.FileNames{end};
        end
end

if any(mode == 2) && isfield(PhasorTIFFData, 'Data') %%% Update Data plots and images
        
    %%% Inverts timeaxis if selected
    if h.Invert_Tif.Value
        Data = flip(PhasorTIFFData.Data,3);
    else
        Data = PhasorTIFFData.Data;
    end
    %%% Plots data depending on the normalization procedure
    if h.Use_Mean.Value
        h.Plot_Data.YData=squeeze(sum(sum(Data,1),2))/mean(sum(sum(Data,1),2));
    else
        h.Plot_Data.YData=squeeze(sum(sum(Data,1),2))/max(sum(sum(Data,1),2));
    end
    h.Plot_Data.XData=0:size(Data,3)-1;
    
    %%% Plots intensity image
    h.Plot_Image.CData=sum(Data,3);
    h.Intensity_Axes.XLim=[0, size(Data,2)]+0.5;
    h.Intensity_Axes.YLim=[0, size(Data,1)]+0.5;
    if isfield(PhasorTIFFData, 'FileNames') && ~isempty(PhasorTIFFData.FileNames);
        h.Progress_Text.String = PhasorTIFFData.FileNames{end};
    end
end

if any(mode == 3) && isfield(PhasorTIFFData, 'TauM' ) && isfield(PhasorTIFFData, 'TauP') %%% Update TauM and TauP images
        
    %%% Uses only pixels with >50% max Intesity for scaling
    Scale = sum(PhasorTIFFData.Data,3) > 0.5*max(max(sum(PhasorTIFFData.Data,3)));
    
    %%% Plots TauM and TauP images and scales them
    h.Plot_TauM.CData = PhasorTIFFData.TauM;
    h.TauM_Axes.XLim = [0, size(PhasorTIFFData.TauM,1)]+0.5;
    h.TauM_Axes.YLim = [0, size(PhasorTIFFData.TauM,2)]+0.5;
    h.TauM_Axes.CLim = [min(min(PhasorTIFFData.TauM(Scale))) max(max(PhasorTIFFData.TauM(Scale)))];
    h.Plot_TauP.CData = PhasorTIFFData.TauP;
    h.TauP_Axes.XLim = [0, size(PhasorTIFFData.TauP,1)]+0.5;
    h.TauP_Axes.YLim = [0, size(PhasorTIFFData.TauP,2)]+0.5;
    h.TauP_Axes.CLim = [min(min(PhasorTIFFData.TauP(Scale))) max(max(PhasorTIFFData.TauP(Scale)))];
end


