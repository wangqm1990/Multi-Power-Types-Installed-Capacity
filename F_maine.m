function [E_PVmax, E_WTmax, E_ESmax, P_GTmax, P_BIOmax, P_gridwimax, flag] = F_maine(X_carbon, flag_figure)

%% 模型参数设定
W = 1;               %典型日个数为  1
Tw = 91;             %典型日天数为 91
N = 3;               %微网数为      3
NT = 24;             %调度时段数为 24
M = 1e10;
gamma_EC = 4; %EC的能效比           4
pha_GT = 1.47; %GT和BIO的热电比  1.47
eta_WH = 0.8; %WH的效率
eta_HX = 0.9; %HX的效率
eta_GT = 0.3;
L_NG = 9.7;
gamma_AC = 1.2; %AC的能效比
CEF_GT = 220; %GT的碳排放因子     220
CEF_grid = 500; %grid的碳排放因子 500

Q_ACmin = 0;
Q_ACmax = 4000; %AC出力上下限
P_ECmin = 0;
P_ECmax = 4000; %EC出力上下限
H_HXmin = 0;
H_HXmax = 4000; %HX出力上下限
P_gridmax = 4000; %grid出力上限
C_gas = 2.2; %天然气售价 2.2
C_BIO = 5; %沼气售价 5
C_PV = 1.2;
C_WT = 1.2;
%微网向储能电站的售电电价
sold = [0.20, 0.20, 0.20, 0.20, 0.20, 0.20, ...
        0.20, 0.20, 0.95, 0.95, 0.95, 0.95, ...
        0.55, 0.55, 0.55, 0.55, 0.95, 0.95, ...
        0.95, 0.95, 0.95, 0.55, 0.55, 0.55];
%微网从储能电站购电的电价
buy = [0.40, 0.40, 0.40, 0.40, 0.40, 0.40, ...
       0.40, 0.40, 1.15, 1.15, 1.15, 1.15, ...
       0.75, 0.75, 0.75, 0.75, 1.15, 1.15, ...
       1.15, 1.15, 1.15, 0.75, 0.75, 0.75];
%微网从电网的购电电价
Power_grid_purchase = [0.37, 0.37, 0.37, 0.37, 0.37, 0.37, ...
                       0.37, 0.37, 1.36, 1.36, 1.36, 1.36, ...
                       0.82, 0.82, 0.82, 0.82, 1.36, 1.36, ...
                       1.36, 1.36, 1.36, 0.82, 0.82, 0.82];
%约束条件集
C = [];
%上层变量
P_cha = sdpvar(1, NT);
P_dis = sdpvar(1, NT);
P_GT = sdpvar(1, NT);
P_BIO = sdpvar(1, NT);
E_ES = sdpvar(1, NT + 1);
E_ESmax = sdpvar(1);
P_ESmax = sdpvar(1);
P_GTmax = sdpvar(1);
P_BIOmax = sdpvar(1);
%% 上层模型导入
for i = 2 : NT + 1
    C = [C, ...
         E_ES(i)==(E_ES(i - 1) + (0.95*P_cha(i - 1) - (1/0.95)*P_dis(i - 1))) %储能电站与上一时段的能量变化约束 （2）
        ];
end
C = [C, E_ES(1) == E_ES(25), E_ES(1) == 0.2*E_ESmax];% （3）（4）
C = [C, 0.1*E_ESmax <= E_ES <= 0.9*E_ESmax];% （5）
C = [C, 0 <= P_cha <= P_ESmax, 0 <= P_dis <= P_ESmax];% （6）（7）
C = [C, 0 <= P_GT <= P_GTmax];%（8）
C = [C, 0 <= P_BIO <= P_BIOmax];% （11）

% F = E_ESmax + P_GTmax + P_BIOmax;
F = sum(buy.*P_dis - sold.*P_cha + C_gas*P_GT + C_BIO*P_BIO + 10.7*(P_dis + P_cha));

%% 下层模型导入
[area_1, area_2, area_3] = getdata;
%导入微网1的参数
% area_1 = xlsread('data', '微网1', 'I2:M25'); %'A2:E25' 'I2:M25' 'P2:T25' 'W2:AA25' 'AD2:AH25'
Q_load(1, :) = area_1(:, 1)';
H_load(1, :) = area_1(:, 2)';
P_load(1, :) = area_1(:, 3)';
P_PVmax(1, :) = area_1(:, 4)';
P_WTmax(1, :) = area_1(:, 5)';
%导入微网2的参数(MG2中没有风电)
% area_2 = xlsread('data', '微网2', 'J2:M25'); %'A2:E25' 'J2:M25' 'Q2:T25' 'X2:AA25' 'AE2:AH25'
Q_load(2, :) = area_2(:, 1)';
H_load(2, :) = area_2(:, 2)';
P_load(2, :) = area_2(:, 3)';
P_PVmax(2, :) = area_2(:, 4)';
%导入微网3的参数
% area_3 = xlsread('data', '微网3', 'I2:M25'); %'A2:E25' 'I2:M25' 'P2:T25' 'W2:AA25' 'AD2:AH25'
Q_load(3, :) = area_3(:, 1)';
H_load(3, :) = area_3(:, 2)';
P_load(3, :) = area_3(:, 3)';
P_PVmax(3, :) = area_3(:, 4)';
P_WTmax(3, :) = area_3(:, 5)';
if flag_figure == 1
    figure(1)
    subplot(3, 1, 1)
    bar([P_PVmax(1, :); P_WTmax(1, :)]', 'stacked');
    hold on
    plot(P_load(1, :), 'r*-')
    legend('光伏出力', '风机出力', '负荷');
    xlabel('时间/h');
    ylabel('功率/kW');
    title('微网一');
    box off

    subplot(3, 1, 2)
    bar([P_PVmax(2, :); P_WTmax(2, :)]', 'stacked');
    hold on
    plot(P_load(2, :), 'r*-')
    legend('光伏出力', '风机出力', '负荷');
    xlabel('时间/h');
    ylabel('功率/kW');
    title('微网二');
    box off

    subplot(3, 1, 3)
    bar([P_PVmax(3, :); P_WTmax(3, :)]', 'stacked');
    hold on
    plot(P_load(3, :), 'r*-')
    legend('光伏出力', '风机出力', '负荷');
    xlabel('时间/h');
    ylabel('功率/kW');
    title('微网三');
    box off
end
%下层变量
P_GTwi = sdpvar(N, NT);   %第i个微网GT发电功率
P_WTwi = sdpvar(N, NT);   %第i个微网WT发电功率
P_PVwi = sdpvar(N, NT);   %第i个微网PV发电功率
P_BIOwi = sdpvar(N, NT);  %第i个微网BIO发电功率
P_gridwi = sdpvar(N, NT); %第i个微网从电网购电功率
P_ESbwi = sdpvar(N, NT);  %第i个微网从ES购电功率
P_ESswi = sdpvar(N, NT);  %第i个微网向ES售电功率
P_ECwi = sdpvar(N, NT);   %第i个微网从EC消耗的电功率
Q_ACwi = sdpvar(N, NT);   %第i个微网从AC输出制冷功率
H_HXwi = sdpvar(N, NT);   %第i个微网从HX输出制热功率
U_buy = binvar(N, NT);
U_sale = binvar(N, NT);
% 等式约束
C = [C, P_GTwi + P_WTwi + P_PVwi + P_BIOwi + P_gridwi + P_ESbwi - P_ESswi - P_ECwi - P_load == 0]; %电功率平衡约束 （20）
C = [C, gamma_EC*P_ECwi + Q_ACwi - Q_load == 0]; %冷功率平衡约束 （21）
C = [C, H_HXwi - H_load == 0]; %热功率平衡约束 （22）
C = [C, H_HXwi/eta_HX + Q_ACwi/gamma_AC - (pha_GT*P_BIOwi + pha_GT*P_GTwi)*eta_WH == 0]; %余热锅炉余热平衡约束 （23）
C = [C, sum(P_ESbwi) == P_cha, sum(P_ESswi) == P_dis]; %储能电站充放电功率平衡约束 （24）（25）
C = [C, sum(P_GTwi) == P_GT, sum(P_BIOwi) == P_BIO]; % GT、BIO出力平衡约束 （26）（27）
C = [C, sum(sum((CEF_GT*P_GTwi + CEF_grid*P_gridwi), 2)) == X_carbon]; % 碳减排政策约束 （28）

%定义等式约束的拉格朗日乘子
l1itw = sdpvar(3, NT);
l2itw = sdpvar(3, NT);
l3itw = sdpvar(3, NT);
l4itw = sdpvar(3, NT);
l5itw = sdpvar(1, NT);
l6itw = sdpvar(1, NT);
l7itw = sdpvar(1, NT);
l8itw = sdpvar(1, NT);
l9itw = sdpvar(3, NT);
%定义不等式约束的拉格朗日乘子
u1itmin = sdpvar(3, NT);
u2itmin = sdpvar(3, NT);
u3itmin = sdpvar(3, NT);
u4itmin = sdpvar(3, NT);
u5itmin = sdpvar(3, NT);
u6itmin = sdpvar(3, NT);

u8itmin = sdpvar(3, NT);
u9itmin = sdpvar(3, NT);
u10itmin = sdpvar(3, NT);
u11itmin = sdpvar(3, NT);

u1itmax = sdpvar(3, NT);
u2itmax = sdpvar(3, NT);
u3itmax = sdpvar(3, NT);
u4itmax = sdpvar(3, NT);
u5itmax = sdpvar(3, NT);
u6itmax = sdpvar(3, NT);
u7itmax = sdpvar(3, NT);
u8itmax = sdpvar(3, NT);
u9itmax = sdpvar(3, NT);
u10itmax = sdpvar(3, NT);
u11itmax = sdpvar(3, NT);

% 变量约束
for i = 1:N
    C = [C, Tw*Power_grid_purchase + l1itw(i, :) + l9itw(i, :) - u4itmin(i, :) + u4itmax(i, :) == 0, ...
            Tw*C_gas/eta_GT/L_NG + l1itw(i, :) + l4itw(i, :)*pha_GT*eta_WH + l7itw + l9itw(i, :) - u10itmin(i, :) + u10itmax(i, :) == 0, ...
            Tw*buy + l1itw(i, :) + l5itw - u6itmin(i, :) + u6itmax(i, :) == 0, ...
            -Tw*sold - l1itw(i, :) + l6itw - u5itmin(i, :) + u5itmax(i, :) == 0, ...
        ];
end
C = [C, Tw*C_WT + l1itw - u8itmin + u8itmax == 0, ...
        Tw*C_PV + l1itw - u9itmin + u9itmax == 0;
    ];
for i = 1:N
    C = [C, Tw*C_BIO/eta_GT/L_NG + l1itw(i, :) - l4itw(i, :)*pha_GT*eta_WH + l8itw - u11itmin(i, :) + u11itmax(i, :) == 0];
end

C = [C, -l1itw + l2itw*gamma_EC - u2itmin + u2itmax == 0, ...
        l2itw + l4itw - u1itmin + u1itmax == 0, ...
        l3itw + l4itw - u3itmin + u3itmax == 0, ...
        u5itmax*P_ESmax + u7itmax == 0, ...
        u6itmax*P_ESmax + u7itmax == 0
    ];

% 不等式约束
v1min = binvar(N, NT); v1max = binvar(N, NT);
v2min = binvar(N, NT); v2max = binvar(N, NT);
v3min = binvar(N, NT); v3max = binvar(N, NT);
v4min = binvar(N, NT); v4max = binvar(N, NT);
v5min = binvar(N, NT); v5max = binvar(N, NT);
v6min = binvar(N, NT); v6max = binvar(N, NT);
v7max = binvar(N, NT);
v8min = binvar(N, NT); v8max = binvar(N, NT);
v9min = binvar(N, NT); v9max = binvar(N, NT);
v10min = binvar(N, NT);v10max = binvar(N, NT);
v11min = binvar(N, NT);v11max = binvar(N, NT);
v12max = binvar(N, NT);

C = [C, 0 <= u1itmin <= M*v1min,   0 <= Q_ACwi - Q_ACmin <= M*(1 - v1min), ...
        0 <= u1itmax <= M*v1max,   0 <= Q_ACmax - Q_ACwi <= M*(1 - v1max), ...
        0 <= u2itmin <= M*v2min,   0 <= P_ECwi - P_ECmin <= M*(1 - v2min), ...
        0 <= u2itmax <= M*v2max,   0 <= P_ECmax - P_ECwi <= M*(1 - v2max), ...
        0 <= u3itmin <= M*v3min,   0 <= H_HXwi - H_HXmin <= M*(1 - v3min), ...
        0 <= u3itmax <= M*v3max,   0 <= H_HXmax - H_HXwi <= M*(1 - v3max), ...
        0 <= u4itmin <= M*v4min,   0 <= P_gridwi <= M*(1 - v4min), ...
        0 <= u4itmax <= M*v4max,   0 <= P_gridmax - P_gridwi <= M*(1 - v4max), ...
        0 <= u5itmin <= M*v5min,   0 <= P_ESswi <= M*(1 - v5min), ...
        0 <= u5itmax <= M*v5max,   0 <= P_ESmax*U_sale - P_ESswi <= M*(1 - v5max), ...
        0 <= u6itmin <= M*v6min,   0 <= P_ESbwi <= M*(1 - v6min), ...
        0 <= u6itmax <= M*v6max,   0 <= P_ESmax*U_buy - P_ESbwi <= M*(1 - v6max), ...
        0 <= u7itmax <= M*v7max,   0 <= 1 - U_buy - U_sale <= M*(1 - v7max), ...
        0 <= u8itmin <= M*v8min,   0 <= P_WTwi <= M*(1 - v8min), ...
        0 <= u8itmax <= M*v8max,   0 <= P_WTmax - P_WTwi <= M*(1 - v8max), ...
        0 <= u9itmin <= M*v9min,   0 <= P_PVwi <= M*(1 - v9min), ...
        0 <= u9itmax <= M*v9max,   0 <= P_PVmax - P_PVwi <= M*(1 - v9max), ...
        0 <= u10itmin <= M*v10min, 0 <= P_GTwi <= M*(1 - v10min), ...
        0 <= u10itmax <= M*v10max, 0 <= P_GTmax - P_GTwi <= M*(1 - v10max), ...
        0 <= u11itmin <= M*v11min, 0 <= P_BIOwi <= M*(1 - v11min), ...
        0 <= u11itmax <= M*v11max, 0 <= P_BIOmax - P_BIOwi <= M*(1 - v11max)
        ];

%% 求解

% ops = sdpsettings('solver', 'cplex', 'verbose', 2, 'usex0', 0);
% ops.cplex.mip.tolerances.mipgap = 1e-6;
ops = sdpsettings('solver', 'gurobi', 'verbose', 2, 'usex0', 0);
ops.gurobi.MIPGap = 1e-6;
result = optimize(C, F, ops);
flag = result.problem;

% if result.problem == 0
%     % 代表求解成功
%     % do nothing!
% else
%     error('求解出错');
% end

%% 作图
P_PVwi = double(P_PVwi);
P_WTwi = double(P_WTwi);
P_GTwi = double(P_GTwi);
P_BIOwi = double(P_BIOwi);
P_gridwi = double(P_gridwi);
P_ESbwi = double(P_ESbwi);
P_ESswi = double(P_ESswi);
P_ECwi = double(P_ECwi);

E_PVmax = max(P_PVwi(1, :)) + max(P_PVwi(2, :)) + max(P_PVwi(3, :));
E_WTmax = max(P_WTwi(1, :)) + max(P_WTwi(2, :)) + max(P_WTwi(3, :));
E_ESmax = double(E_ESmax);
P_GTmax = double(P_GTmax);
P_BIOmax = double(P_BIOmax);
P_gridwimax = max(sum(P_gridwi));

if flag_figure == 1
    figure(2)
    y_e1 = [P_PVwi(1, :); P_WTwi(1, :); P_GTwi(1, :); P_BIOwi(1, :); P_gridwi(1, :); P_ESbwi(1, :); -P_ESswi(1, :); -P_ECwi(1, :)]';
    y_e2 = [P_PVwi(2, :); P_WTwi(2, :); P_GTwi(2, :); P_BIOwi(2, :); P_gridwi(2, :); P_ESbwi(2, :); -P_ESswi(2, :); -P_ECwi(2, :)]';
    y_e3 = [P_PVwi(3, :); P_WTwi(3, :); P_GTwi(3, :); P_BIOwi(3, :); P_gridwi(3, :); P_ESbwi(3, :); -P_ESswi(3, :); -P_ECwi(3, :)]';
    subplot(1, 3, 1)
    bar(y_e1, 'stacked')
    hold on
    plot(P_load(1, :), 'k-o', 'LineWidth', 1.5)
    xlabel('时间/h');
    ylabel('功率/kW');
    title('MG1电负荷');

    subplot(1, 3, 2)
    bar(y_e2, 'stacked')
    hold on
    plot(P_load(2, :), 'k-o', 'LineWidth', 1.5)
    xlabel('时间/h');
    ylabel('功率/kW');
    title('MG2电负荷');

    subplot(1, 3, 3)
    bar(y_e3, 'stacked')
    hold on
    plot(P_load(3, :), 'k-o', 'LineWidth', 1.5)
    legend('光伏', '风电', 'GT输出功率', 'BIO输出功率', '从大电网买电', '从储能买电', '向储能卖电', '电制冷机耗电', 'Location','Best');
    xlabel('时间/h');
    ylabel('功率/kW');
    title('MG3电负荷');

    figure(3)
    subplot(1, 3, 1)
    bar(-P_ESswi(1, :));
    hold on
    bar(P_ESbwi(1, :));
    hold on
    legend('MG1向储能电站售电功率', 'MG1从储能电站购电功率', 'Location','Best');
    xlabel('时间/h');
    ylabel('功率/kW');
    title('微网向储能电站购售电功率结果图');
    box off

    subplot(1, 3, 2)
    bar(-P_ESswi(2, :));
    hold on
    bar(P_ESbwi(2, :));
    hold on
    legend('MG2向储能电站售电功率', 'MG2从储能电站购电功率', 'Location','Best');
    xlabel('时间/h');
    ylabel('功率/kW');
    title('微网向储能电站购售电功率结果图');
    box off

    subplot(1, 3, 3)
    bar(-P_ESswi(3, :));
    hold on
    bar(P_ESbwi(3, :));
    hold on
    legend('MG3向储能电站售电功率', 'MG3从储能电站购电功率', 'Location','Best');
    xlabel('时间/h');
    ylabel('功率/kW');
    title('微网向储能电站购售电功率结果图');
    box off

    figure(4)
    subplot(2, 3, 1)
    bar(P_PVwi(1, :));
    hold on
    plot(P_PVmax(1, :))
    subplot(2, 3, 2)
    bar(P_PVwi(2, :));
    hold on
    plot(P_PVmax(2, :))
    subplot(2, 3, 3)
    bar(P_PVwi(3, :));
    hold on
    plot(P_PVmax(3, :))
    subplot(2, 3, 4)
    bar(P_WTwi(1, :));
    hold on
    plot(P_WTmax(1, :))
    subplot(2, 3, 5)
    bar(P_WTwi(2, :));
    hold on
    plot(P_WTmax(2, :))
    subplot(2, 3, 6)
    bar(P_WTwi(3, :));
    hold on
    plot(P_WTmax(3, :))
end
no = 1;