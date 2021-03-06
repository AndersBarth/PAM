%% perform simulation
Freq = 1E6; %%% evaluate every microsecond
TimeSteps = 100; %%% evaluate for 10 seconds of total time
number_of_timewindows = 10;
%%% Rate matrix. Rates are given in Hz = 1/s
DynRates = [  0,  600, 100; ...
            500,    0, 400;
            800,  300,   0];
        
%%% perform simulation
%states = simulate_state_trajectory(DynRates,TimeSteps,Freq);
states = dyn_sim_arbitrary_states_gillespie_trajectory(DynRates,TimeSteps,number_of_timewindows);


%% plot dwell times
n_states = size(DynRates,1);
for i = 1:n_states
    % digitize state trajectory
    s = (states == i);
    w = [ 0; s; 0 ]; % auxiliary vector
    dt{i} = find(diff(w)==-1)-find(diff(w)==1); % lenghts of runs of 1's
end
dt = cellfun(@(x) x./Freq, dt,'UniformOutput',false);

figure('Units','pixel','Position',[100,100,400*n_states,400]);
for i = 1:n_states
    subplot(1,n_states,i);
    %%% dwell time in state 1
    [dwell, time] = histcounts(dt{i},100); 
    semilogy(time(1:end-1)*1000,dwell);
    title(sprintf('Dwell time in state %d: %.4f ms.\n (Rate : %.2f Hz)',i,mean(dt{i}*1000),1/mean(dt{i})));
    xlabel('Time [ms]');
    ylabel('Occurence [log]');
end