%% 0 程序的所有参数
%% 频率偏差
% [u1]=xlsread('f', 'Sheet1', 'B1:B1800');
data = readtimetable('F:\实验室文件\论文发表\利用可再生能源平衡电网频率：降碳政策下沼气发电在风电和光伏整合中的作用\原版频率数据\FrequencyData\同地区不同季节\春.csv');
u1 = data.f50_DE_KA(1:1:end, :)/1000;
%% 蓄电池
soc_min=0.1;%最小荷电状态
soc_max=0.9;%最大荷电状态
dta_fu=0.033;%上死区
dta_fd=-0.033;%下死区
Ke=10;%下垂控制系数
P_min=5.5;%最大出力极小值
P_max=11;%最大出力极大值
soc0=0.5;%初始荷电状态
S_b=250;%容量基值
soc_ref=0.5;
T_life=2.5;%储能等效循环寿命
T_lcc=20;%全寿命周期
n_=T_lcc/T_life;%置换次数
cbat=384;
r=0.06;
cpcs=230;
cpo=10;%单位功率运维成本
ceo=10;%容量运维成本
cps=1;
ces=1;
% bta=