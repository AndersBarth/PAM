function PDA_E_tau_comparison(~,~)
%%% Prepares a plot of FRET efficiency vs. donor fluorescence liftime,
%%% including bin-wise averaging with respect to the FRET efficiency.
%%% (Similar to the procedure outlined in the Burst Variance Analysis
%%% paper).
%%% Additionally, confidence intervals for the static FRET line are
%%% estimated.
%% get data
global BurstData BurstTCSPCData UserValues BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));
file = BurstMeta.SelectedFile;

E = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET Efficiency'));
tauD = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Lifetime D [ns]'));
N_phot_D = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (DD)'));

selected = BurstData{file}.Selected;
E = E(selected);
tauD0 = BurstData{file}.Corrections.DonorLifetime;
tauD = tauD(selected)./tauD0;
R0 = BurstData{file}.Corrections.FoersterRadius;
sigmaR = BurstData{file}.Corrections.LinkerLength;
N_phot_D = N_phot_D(selected);
threshold = UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA;

%% average lifetime in FRET efficiency bins
bin_number = UserValues.BurstBrowser.Settings.NumberOfBins_BVA; % bins for range 0-1
bin_edges = linspace(0,1,bin_number); bin_centers = bin_edges(1:end-1) + min(diff(bin_edges))/2;
[~,~,bin] = histcounts(E,bin_edges);
mean_tau = NaN(1,numel(bin_edges)-1);
for i = 1:numel(bin_edges)-1
    %%% compute bin-wise intensity-averaged lifetime for donor
    if sum(bin == i) > threshold
        mean_tau(i) = sum(N_phot_D(bin==i).*tauD(bin==i))./sum(N_phot_D(bin==i));
    end
end

%% to get confidence intervals, resample each burst as "static" according to the FRET efficiency
Progress(0,h.Progress_Axes,h.Progress_Text,'Estimating Confidence Intervals...');
burstwise = true;
number_of_bursts = numel(bin);
bursts_done = 0;
sampling = 1;
if burstwise
    tau_int_R = NaN(sampling,numel(bin_edges)-1);
    tau_species_R = NaN(sampling,numel(bin_edges)-1);
    E_resampled = NaN(sampling,numel(bin_edges)-1);
    for i = 1:numel(bin_edges)-1
        %tau_static_bin = zeros(sum(bin == i),1);
        tau_static_bin_R = zeros(sum(bin == i),1);
        if sum(bin == i) > threshold
            E_bin = E(bin == i);
            valid = E_bin > 0;
            E_bin = E_bin(valid);
            N_phot_bin = N_phot_D(valid);
            % find the correct center distance that corresponds to the center
            % of the normal distribution of distances that generates the
            % observed average efficiency value given the sigmaR
            for k = 1:numel(E_bin)
                R_bin(k) = find_center_R(E_bin(k),sigmaR,R0);%R0.*(1./E_bin-1).^(1/6);
            end
            R_phot = zeros(sum(N_phot_bin),1);
            idx = [1;cumsum(N_phot_bin)];
            for m = 1:numel(idx)-1
                R_phot(idx(m):idx(m+1)) = R_bin(m);
            end
            %R_bin = R0.*(1./E_phot-1).^(1/6);
            for s = 1:sampling
                R_randomized = normrnd(R_phot,sigmaR);
                R_randomized(R_randomized<0) = 0;
                E_randomized = 1./(1+(R_randomized./R0).^6);
                % intensity weighted lifetime
                delay_times = exprnd(tauD0./(1+(R0./R_randomized).^6));     
                tau_int_R(s,i) = sum((1-E_randomized).*delay_times)./sum(1-E_randomized)./tauD0;
                tau_species_R(s,i) = mean(delay_times)./tauD0;
                E_resampled(s,i) = mean(E_randomized);
            end
        end
        bursts_done = bursts_done + sum(bin==i);
        Progress(bursts_done/number_of_bursts,h.Progress_Axes,h.Progress_Text,'Estimating Confidence Intervals...');
    end
else
    %%% do it for all bins to simulate static FRET line with MC
    %%% only for bins above threshold
    %%% based on the number of photons in that bin
    %%% parameters for MLE fit
    %fitopts = optimset('MaxFunEvals',1E5,'Display','off');
    tau_species_R = NaN(sampling,numel(bin_edges)-1);
    tau_int_R = NaN(sampling,numel(bin_edges)-1);
    E_resampled = NaN(sampling,numel(bin_edges)-1);
    for i = 1:numel(bin_edges)-1
        tau_static_bin_R = zeros(sum(bin == i),1);
        E_bin = bin_centers(i);
        N = sum(N_phot_D(bin == i));
        % find the correct center distance that corresponds to the center
        % of the normal distribution of distances that generates the
        % observed average efficiency value given the sigmaR
        R_bin = find_center_R(E_bin,sigmaR,R0);%R0.*(1./E_bin-1).^(1/6);
        for s = 1:sampling
            R_randomized = normrnd(R_bin,sigmaR,N,1);
            R_randomized(R_randomized<0) = 0;
            E_randomized = 1./(1+(R_randomized./R0).^6);
            % intensity weighted lifetime
            delay_times = exprnd(tauD0./(1+(R0./R_randomized).^6));
            % fit (return identical result to weighted sum)
%             delay_times_red = delay_times(logical(binornd(1,1-E_randomized)));
%             [ht,xt] = histcounts(delay_times_red);
%             xt = xt(1:end-1) + min(diff(xt))/2;
%             ht = ht./sum(ht);
%             % MLE fit            
%             tau = fminsearch(@(tau) lifetime_MLE(xt,ht,tau),1,fitopts);
%             tau_static_R(s,i) = tau./tauD0;
            tau_int_R(s,i) = sum((1-E_randomized).*delay_times)./sum((1-E_randomized))./tauD0;
            % just species weighted
            tau_species_R(s,i) = mean(delay_times)./tauD0;
            E_resampled(s,i) = mean(E_randomized);
        end
        bursts_done = bursts_done + sum(bin==i);
        Progress(bursts_done/number_of_bursts,h.Progress_Axes,h.Progress_Text,'Estimating Confidence Intervals...');
    end
end
Progress(1,h.Progress_Axes,h.Progress_Text,'Estimating Confidence Intervals...');
mean_tau_static_R = mean(tau_int_R,1);
mean_tau_species_R = mean(tau_species_R,1);
bin_centers_cor = 1-mean_tau_species_R;
mean_E_resampled = mean(E_resampled,1);
% get percentiles
alpha = 0.001;
%upper_bound = prctile(tau_int_R,100-alpha/(numel(bin_edges)-1),1);
upper_bound = mean(tau_int_R,1) + std(tau_int_R,0,1)*norminv(1-alpha/(numel(bin_edges)-1)/100);
%% plot smoothed dynamic FRET line
[H,x,y] = histcounts2(E,tauD,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[-0.1,1.1],'YBinLimits',[0,1.2]);
H = H./max(H(:)); %H(H<UserValues.BurstBrowser.Display.ContourOffset/100) = NaN;
f = figure('Color',[1,1,1],'Position',[100,100,600,600]); hold on;
contourf(y(1:end-1),x(1:end-1),H,'LevelList',max(H(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels),'EdgeColor','none');
colormap(f,colormap(h.BurstBrowser));
ax = gca;
ax.CLimMode = 'auto';
ax.CLim(1) = 0;
ax.CLim(2) = max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100;
% plot patch to phase contour plot out
patch([0,1.2,1.2,0],[-0.1,-0.1,1.1,1.1],[1,1,1],'FaceAlpha',0.5,'EdgeColor','none');
%%% add static FRET line
plot(BurstMeta.Plots.Fits.staticFRET_EvsTauGG.XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.staticFRET_EvsTauGG.YData,'-','LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
plot(BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).YData,'--','LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);

scatter(mean_tau,bin_centers,100,'diamond','filled','MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1);
%plot(mean_tau_static,bin_centers,'-g','LineWidth',2);
%scatter(mean_tau_static_R,bin_centers_cor,100,'diamond','filled','MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2);
%plot(upper_bound(isfinite(upper_bound)),bin_centers_cor(isfinite(upper_bound)),':g','LineWidth',2);
%area([0,0,fliplr(upper_bound(isfinite(upper_bound)))],[0,max(bin_centers_cor(isfinite(upper_bound))),fliplr(bin_centers_cor(isfinite(upper_bound)))],'FaceColor',0.25*[1,1,1],'FaceAlpha',0.25,'LineStyle','none');
%patch([0,0,fliplr(upper_bound(isfinite(upper_bound)))],[min(bin_centers_cor(isfinite(upper_bound))),max(bin_centers_cor(isfinite(upper_bound))),fliplr(bin_centers_cor(isfinite(upper_bound)))],0.25*[1,1,1],'FaceAlpha',0.25,'LineStyle','none');
set(gca,'Color',[1,1,1]);

ax.XLim = [0,1.2];
ax.YLim = [0,1];

xlabel('\tau_{D,A}/\tau_{D,0}');
ylabel('FRET Efficiency');
set(gca,'FontSize',24,'LineWidth',2,'Box','on','DataAspectRatio',[1,1,1],'XColor',[0,0,0],'YColor',[0,0,0],'Layer','top');

%plot_E_tau(E_cor,tau_average);


%% "transformed" FRET line so that static is horizontal
transformed = false;
if transformed    
    %%% transform quantities
    % species-weighted tau, normalized to tauD0
    tauDA = (1-E);
    % standard deviation of the species weighted tau, normalized to tauD0
    % estimated var can be < 0 due to shot noise
    var_tauDA =  (1-E).*( tauD - (1-E)) ;
    
    %%% do the same for all bins
    mean_tauDA_static = 1-mean_E_resampled;
    mean_var_tauDA_static = mean_tauDA_static.*( mean_tau_static_R - mean_tauDA_static);
    
    % and for the averaged values from the data
    data_mean_tauDA = 1-bin_centers;
    data_mean_var_tauDA = data_mean_tauDA.*( mean_tau - data_mean_tauDA);
    
    % for each draw sample, calculate the y value (i.e. var_tauDA)
    var_tauDA_static = (1-E_resampled).*(tau_int_R- (1-E_resampled));
    % get percentiles
    alpha = 0.001;  
    upper_bound_var = prctile(var_tauDA_static,100-alpha/(numel(bin_edges)-1),1);
    
    %%% plot
    [H,x,y] = histcounts2(var_tauDA,tauDA,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[-.15,.5],'YBinLimits',[-0.1,1.1]);
    H = H./max(H(:)); %H(H<UserValues.BurstBrowser.Display.ContourOffset/100) = NaN;
    f2 = figure('Color',[1,1,1],'Position',[f.Position(1)+f.Position(3),100,600,600]); hold on;
    contourf(y(1:end-1),x(1:end-1),H,'LevelList',max(H(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels),'EdgeColor','none');
    colormap(f2,colormap(h.BurstBrowser));
    ax = gca;
    ax.CLimMode = 'auto';
    ax.CLim(1) = 0;
    ax.CLim(2) = max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100;
    ax.XLim = [0,1];
    ax.YLim = [-.15,.3];
    
    % plot patch to phase contour plot out
    xlim = ax.XLim;
    ylim = ax.YLim;
    patch([xlim(1),xlim(2),xlim(2),xlim(1)],[ylim(1),ylim(1),ylim(2),ylim(2)],[1,1,1],'FaceAlpha',0.5,'EdgeColor','none');
    %%% add static FRET line
    tau_line = BurstMeta.Plots.Fits.staticFRET_EvsTauGG.XData./BurstData{file}.Corrections.DonorLifetime;
    E_line = BurstMeta.Plots.Fits.staticFRET_EvsTauGG.YData;    
    plot(1-E_line,(1-E_line).*(tau_line-(1-E_line)),'-','LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
    tau_line = BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).XData./BurstData{file}.Corrections.DonorLifetime;
    E_line = BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).YData; 
    plot(1-E_line,(1-E_line).*(tau_line-(1-E_line)),'--','LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);

    scatter(data_mean_tauDA,data_mean_var_tauDA,100,'diamond','filled','MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1);
    scatter(mean_tauDA_static,mean_var_tauDA_static,100,'diamond','filled','MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2);
    
    patch([max(mean_tauDA_static(isfinite(upper_bound_var))),mean_tauDA_static(isfinite(upper_bound_var)),min(mean_tauDA_static(isfinite(upper_bound_var)))],[ylim(1),upper_bound_var(isfinite(upper_bound_var)),ylim(1)],0.25*[1,1,1],'FaceAlpha',0.25,'LineStyle','none');
    set(gca,'Color',[1,1,1]);

    xlabel('\tau_{D,A}/\tau_{D,0}');
    ylabel('var(\tau_{D,A})');
    set(gca,'FontSize',24,'LineWidth',2,'Box','on','XColor',[0,0,0],'YColor',[0,0,0],'Layer','top');
end

%% Simulation for PDA comparison

n_states = 2;
switch n_states
    case 2
        rate_matrix = 1000*cell2mat(h.KineticRates_table.Data(1:2,1:2)); %%% rates in Hz %1000*[0,0.01;0.01,0];%
        %E_states = [0.2,0.8];
        R_states = [str2double(h.Rstate1_edit.String),str2double(h.Rstate2_edit.String)]; %[40,60];
        sigmaR_states = [str2double(h.Rsigma1_edit.String),str2double(h.Rsigma2_edit.String)];
    case 3
        rate_matrix = 1000*cell2mat(h.KineticRates_table.Data); %%% rates in Hz
        R_states = [str2double(h.Rstate1_edit.String),str2double(h.Rstate2_edit.String),str2double(h.Rstate3_edit.String)];
        sigmaR_states = [str2double(h.Rsigma1_edit.String),str2double(h.Rsigma2_edit.String),str2double(h.Rsigma3_edit.String)];
end
rate_matrix(isnan(rate_matrix)) = 0;
kinetic_consistency_check('Lifetime',n_states,rate_matrix,R_states,sigmaR_states,f);

% switch UserValues.BurstBrowser.Display.PlotType
%     case {'Contour','Scatter'}
%         legend('Burst SD','Expected SD','Binned SD','PDA model','PDA bins','Location','northeast')
%     case {'Image','Hex'}
%         legend('Expected SD','Binned SD','Location','northeast')
%         BVA_cbar = colorbar; ylabel(BVA_cbar,'Number of Bursts')
% end