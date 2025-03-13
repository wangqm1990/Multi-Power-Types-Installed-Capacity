function fun = fun_objective(x)
%% 准备工作
parameter; %输入所有的数据
m1=size(u1, 1);
Pt=zeros(m1,1);
ft=zeros(m1,1);
% 各个决策变量的含义
soc_h = x(1);      % 较高
soc_l = x(2);      % 较低
P_b = x(3);        % 购电
P_s = x(4);        % 售电
P_m = fix(x(5) + 1);        % 最大值
E_b=0.32*P_m*3600 ;     %储能容量
E_bt=zeros(m1+1,1);%实时荷电状态
E_bt(1)=E_b*soc0;
%% 书写约束
% ******************* 不等式约束 ***************************
g=[];
g=[g, P_min - P_m] ; % <=0
g=[g, P_b - P_m] ; % <=0
g=[g, P_s - P_m] ; % <=0
g=[g, soc_l - soc_h] ; % <=0
%   g=[g, soc - soc_max] ; % <=0
%   g=[g, soc_min - soc] ; % <=0


%% 控制策略约束
for t=1:m1
    %死区
    if u1(t)>=dta_fd&&u1(t)<=dta_fu
        ft(t)=u1(t);
        %售电
        if E_bt(t)>E_b*soc_h
            Pt(t)=P_s;
            ft(t)=u1(t)+P_s/Ke;
        end
        %购电
        if E_bt(t)<E_b*soc_l
            Pt(t)=-P_b;
            ft(t)=u1(t)-P_b/(Ke);
        end

        %高于死区
    elseif u1(t)>dta_fu
        ft(t)=u1(t);
        if E_bt(t)<E_b*soc_max&&E_bt(t)>=E_b*soc_min
            Pt(t)=-Ke*u1(t);
            ft(t)=0;
        end


        %低于死区
    elseif u1(t)<dta_fd
        ft(t)=u1(t);
        if E_bt(t)<=E_b*soc_max&&E_bt(t)>E_b*soc_min
            Pt(t)=-Ke*u1(t);
            ft(t)=0;
        end

    end


    g=[g, E_b*soc0 + sum(Pt(1:t)) - E_b*soc_max] ; % <=0
    g=[g, -(E_b*soc0 + sum(Pt(1:t)) - E_b*soc_min)] ; % <=0
    E_bt(t+1)=E_b*soc0+ sum(Pt(1:t));
    g=[g, Pt(t) - P_m] ; % <=0

    %       g=[g, abs(ft(t)) - abs(u1(t))] ; % <=0
end

%% 目标函数
fun =0;
for t=1:m1
    fun=fun+ft(t)^2 ;

end
fun=sqrt(fun/m1);
%**********************罚函数处理*************************

Big=1;
N=length(g);

G=0;
for n=1:N
    G=G+sqrt(max(0, g(n))^2);
end



%*******************加入罚函数后的目标函数******************

fun=fun+Big*G;

end

