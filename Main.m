%% 储能调频
% 粒子群算法版

%%  变量定义如下：
% 决策变量：% 较高, 较低, 购电，售电，最大值
% x=[soc_h, soc_l, P_b，P_s，P_m];

clc;
clear;
close all;

%% 算法参数
parameter;

nVar = 5;              % 决策变量个数
VarMin = [ones(1, 2)*soc_min, zeros(1, 3)]; % 变量下限
VarMax = [ones(1, 2)*soc_max, ones(1, 3)*P_max]; % 变量上限
MaxIt = 30000;      % 最大迭代次数
nPop = 10;        % 种群数量

%% 计算
[bestPosition, fitValue] = PSOFUN( @fun_objective, nVar, VarMin, VarMax, MaxIt, nPop );
x = bestPosition;

[fun, g, Pt, ft, Q_soc] = fun_jieguo(x);

%% 各个决策变量的含义
soc_h = x(1);    % 较高
soc_l = x(2);   % 较低
P_b = x(3);     % 购电
P_s = x(4);    % 售电
P_m = fix(x(5) + 1);        % 最大值
E_b = 0.32*P_m;    %容量
Q_soc;
J1 = fun;
Qsoc_high = soc_h;
Qsoc_low = soc_l;
P_buy = P_b;
P_sell = P_s;
P_rated = P_m;
Qsoc_rms = Q_soc;
E_rated = E_b;
%% 画图
subplot(2, 2, 3)
plot(u1, 'k')
title('优化前频率偏差')
xlabel('时间/s')
ylabel('频率偏差/Hz')
legend('频率偏差')

subplot(2, 2, 4)
plot(ft, 'k')
title('优化后频率偏差')
xlabel('时间/s')
ylabel('频率偏差/Hz')
legend('频率偏差')

subplot(2, 2, 2)
plot(-Pt, 'k', 'LineWidth', 2)
title('出力')
xlabel('时间/s')
ylabel('出力/MW')
legend('可控电源出力')
