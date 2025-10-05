% =========================================================================
% function: input data in the program
% input:
% output: Data.mat
% authors: YZH
% update: 2025/09/16 19:26
% =========================================================================
function get_Data()
%% import data from Excel
gd.DN = readmatrix('./src/Data_IEEE33.xlsx', 'Sheet', 'DN'); % distribution network  
gd.curve = readmatrix('./src/Data_IEEE33.xlsx', 'Sheet', 'curve'); % curve line of load，负荷曲线
gd.sun = readmatrix('./src/Data_IEEE33.xlsx', 'Sheet', 'sun'); % actual irradiance，实际辐照度

%% 通用数据
gd.T = 24; % 调度的时间跨度
gd.Delta_T = 1; % 每个时间跨度的间隔，h

%% DN
gd.N_branch = size(gd.DN, 1); % number of branch line，1表示返回行数
gd.N_bus = gd.N_branch + 1; % number of bus node
gd.fb = gd.DN(:, 2); % from bus
gd.tb = gd.DN(:, 3); % to bus
gd.S_B = gd.DN(1, 9); % base value of apparant power, MVA
gd.V_B = gd.DN(1, 10); % base value of voltage, kV
gd.Z_B = gd.DN(1, 11); % base value of impedence, kA
gd.I_B = gd.DN(1, 12); % base value of current, Ω
gd.V_S = gd.DN(1, 13); % value of slack voltage, p.u.松弛电压
gd.V_min = gd.DN(1, 14); % the minimum voltage limit, p.u.
gd.V_max = gd.DN(1, 15); % the maximum voltage limit, p.u.
gd.cosphi_grid = gd.DN(1, 16); % the power factor功率因数
gd.r = gd.DN(:, 4)/gd.Z_B; % resistance，p.u. 
gd.x = gd.DN(:, 5)/gd.Z_B; % reactance，p.u.
gd.P_BL = [0; gd.DN(:,6)]/gd.S_B/1e3; % end node active base load, p.u.
gd.Q_BL = [0; gd.DN(:,7)]/gd.S_B/1e3; % end node reactive base load, p.u.
gd.P_BL = bsxfun(@times, gd.P_BL, gd.curve'); % active base load following the Curve line，p.u.实现gd.P_BL与gd.curve逐元素相乘
gd.Q_BL = bsxfun(@times, gd.Q_BL, gd.curve'); % reactive base load following the Curve line，p.u.
gd.I_max = gd.DN(:,8)/gd.I_B; % current limit，p.u. (ref. 靳小龙《面向最大供电能力提升的配电网主动重构策略》)
gd.S_max = gd.DN(:,8)*gd.V_B*sqrt(3)/1e3/gd.S_B;
gd.P_max = repmat(gd.S_max, 1, gd.T);
gd.tanphi_grid = sqrt(1-gd.cosphi_grid^2)/(gd.cosphi_grid);

%% PV
gd.Xi_PV = 0.18;
gd.I0 = 1; % kW/m2
gd.I = gd.sun(2:34, 2:25);
gd.PV_bus = [4, 11, 16, 19, 22, 26]; % location of PV
gd.S_PV_max = [0.3, 0.21, 0.15, 0.17, 0.28, 0.2]; % PV最大容量,kW，此处为标幺值，一般10kV配电网节点承载光伏容量不超过6MW
gd.Eta_PV = 0.05;%弃光率，全国平均水平0.57，辽宁低于全国水平

%% EV
gd.N_EVCS_max = [50, 40, 30, 32]; % the max number of EV charging station
gd.S_EVCS = 150/gd.S_B/1e3; % the rated capacity of EV charging station, p.u.单台充电桩容量取150kVA
gd.EV_bus = [2, 8, 12, 30]; % location of EV charging station


%% 保存
save('./src/Data.mat', "gd")
