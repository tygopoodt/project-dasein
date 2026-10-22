%% Project Dasein - Swarm size trade study
% First-order model comparing swarm sizes on coverage time, radio load,
% coordination complexity, redundancy and cost.
% See docs/requirements/01-swarm-size-trade-study.md for the write-up.

clear; clc;

%% Parameters (illustrative - refine once the mission is fixed)
N            = [5 10 15 20 30 50];  % candidate swarm sizes
area_m2      = 0.5e6;               % mission area [m^2]
swath_m      = 20;                  % sensor swath width [m]
speed_ms     = 5;                   % cruise speed [m/s]
endurance_s  = 12 * 60;             % flight endurance [s]
bcast_hz     = 20;                  % state broadcast rate per drone [Hz]
slot_s       = 0.5e-3;              % TDMA slot duration incl. guard [s]
k_neighbours = 6;                   % neighbours used in local-interaction schemes
p_fail       = 0.05;                % per-drone failure probability per sortie
healthy_frac = 0.8;                 % fraction of swarm that must remain healthy
bom_eur      = 90;                  % bill of materials per drone [EUR]
infra_eur    = 300;                 % shared ground infrastructure [EUR]

%% Model
coverage_s   = area_m2 ./ (swath_m * speed_ms .* N);
channel_use  = N .* bcast_hz .* slot_s;
pairs_all    = N .* (N - 1) / 2;
pairs_local  = N .* k_neighbours;
cost_eur     = N .* bom_eur + infra_eur;

p_healthy = zeros(size(N));
for i = 1:numel(N)
    M = ceil(healthy_frac * N(i));
    k = M:N(i);
    p_healthy(i) = sum(arrayfun(@(kk) nchoosek(N(i), kk), k) ...
                   .* (1 - p_fail).^k .* p_fail.^(N(i) - k));
end

%% Results table
T = table(N', coverage_s'/60, coverage_s' <= endurance_s, 100*channel_use', ...
          pairs_all', pairs_local', 100*p_healthy', cost_eur', ...
          'VariableNames', {'N', 'Coverage_min', 'FitsEndurance', ...
          'ChannelUse_pct', 'PairsAllToAll', 'PairsLocal', ...
          'PHealthy_pct', 'Cost_EUR'});
disp(T);

%% Plots
figure('Name', 'Dasein swarm size trade study');
tiledlayout(2, 2);

nexttile;
plot(N, coverage_s/60, '-o'); hold on;
yline(endurance_s/60, '--r', 'Endurance');
xlabel('Swarm size N'); ylabel('Coverage time [min]'); grid on;
title('Mission coverage time');

nexttile;
plot(N, 100*channel_use, '-o'); hold on;
yline(50, '--r', '50% saturation');
xlabel('Swarm size N'); ylabel('Channel use [%]'); grid on;
title('Shared radio channel load');

nexttile;
plot(N, pairs_all, '-o', N, pairs_local, '-s');
legend('All-to-all', sprintf('%d nearest neighbours', k_neighbours), ...
       'Location', 'northwest');
xlabel('Swarm size N'); ylabel('Interactions'); grid on;
title('Coordination complexity');

nexttile;
yyaxis left;  plot(N, 100*p_healthy, '-o'); ylabel('P(\geq80% healthy) [%]');
yyaxis right; plot(N, cost_eur, '-s');      ylabel('Cost [EUR]');
xlabel('Swarm size N'); grid on;
title('Redundancy vs cost');
