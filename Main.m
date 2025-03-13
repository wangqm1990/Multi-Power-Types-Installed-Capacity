%% ���ܵ�Ƶ
% ����Ⱥ�㷨��

%%  �����������£�
% ���߱�����% �ϸ�, �ϵ�, ���磬�۵磬���ֵ
% x=[soc_h, soc_l, P_b��P_s��P_m];

clc;
clear;
close all;

%% �㷨����
parameter;

nVar = 5;              % ���߱�������
VarMin = [ones(1, 2)*soc_min, zeros(1, 3)]; % ��������
VarMax = [ones(1, 2)*soc_max, ones(1, 3)*P_max]; % ��������
MaxIt = 30000;      % ����������
nPop = 10;        % ��Ⱥ����

%% ����
[bestPosition, fitValue] = PSOFUN( @fun_objective, nVar, VarMin, VarMax, MaxIt, nPop );
x = bestPosition;

[fun, g, Pt, ft, Q_soc] = fun_jieguo(x);

%% �������߱����ĺ���
soc_h = x(1);    % �ϸ�
soc_l = x(2);   % �ϵ�
P_b = x(3);     % ����
P_s = x(4);    % �۵�
P_m = fix(x(5) + 1);        % ���ֵ
E_b = 0.32*P_m;    %��������
Q_soc;
J1 = fun;
Qsoc_high = soc_h;
Qsoc_low = soc_l;
P_buy = P_b;
P_sell = P_s;
P_rated = P_m;
Qsoc_rms = Q_soc;
E_rated = E_b;
%% ��ͼ
subplot(2, 2, 3)
plot(u1, 'k')
title('�Ż�ǰƵ��ƫ��')
xlabel('ʱ��/s')
ylabel('Ƶ��ƫ��/Hz')
legend('Ƶ��ƫ��')

subplot(2, 2, 4)
plot(ft, 'k')
title('�Ż���Ƶ��ƫ��')
xlabel('ʱ��/s')
ylabel('Ƶ��ƫ��/Hz')
legend('Ƶ��ƫ��')

subplot(2, 2, 2)
plot(-Pt, 'k', 'LineWidth', 2)
title('����')
xlabel('ʱ��/s')
ylabel('����/MW')
legend('���ܳ���')