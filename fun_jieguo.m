function [fun, g, Pt, ft, Q_soc] = fun_jieguo(x)
%% 准备工作
parameter; %输入所有的数据
m1 = size(u1, 1);
Pt = zeros(m1, 1);
ft = zeros(m1, 1);
fa1 = zeros(m1, 1);
fa2 = zeros(m1, 1);
% 各个决策变量的含义
soc_h = x(1);      % 较高
soc_l = x(2);      % 较低
P_b = x(3);        % 购电
P_s = x(4);        % 售电
P_m = fix(x(5) + 1);        % 最大值
E_b = 0.32*P_m*3600 ;     %容量
E_bt = zeros(m1 + 1, 1);%实时状态
E_bt(1) = E_b*soc0;

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
        if E_bt(t)==E_b*soc_max
            fa1(t)=Ke*u1(t);
        end

        %低于死区
    elseif u1(t)<dta_fd
        ft(t)=u1(t);
        if E_bt(t)<=E_b*soc_max&&E_bt(t)>E_b*soc_min
            Pt(t)=-Ke*u1(t);
            ft(t)=0;
        end
        if E_bt(t)==E_b*soc_min
            fa2(t)=-Ke*u1(t);

        end
    end

    g=[g, E_b*soc0 + sum(Pt(1:t)) - E_b*soc_max] ; % <=0
    g=[g, -(E_b*soc0 + sum(Pt(1:t)) - E_b*soc_min)] ; % <=0
    E_bt(t+1)=E_b*soc0+ sum(Pt(1:t));
    g=[g, Pt(t) - P_m] ; % <=0

    %       g=[g, abs(ft(t)) - abs(u1(t))] ; % <=0
end

%% 目标函数
%% 1) 考虑孤网的特征，提出反映一次调频效果的评价指标为
fun =0;
for t=1:m1
    fun=fun+ft(t)^2 ;

end
fun=sqrt(fun/m1);
%% 2) 反映荷电状态 QSOC保持效果的评价指标为
Q_soc=0;
for t=1:m1
    Q_soc=Q_soc+((E_bt(t+1)/E_b-soc_ref)^2) ;

end
Q_soc=sqrt(Q_soc/m1);
% %% 3)成本现值
% %% 投资成本
% c_inv=0;
% for t=1:n_
%     c_inv=c_inv+cbat*E_b*(1+r)^(-Ke*T_lcc/(n_+1)) ;
% end
% c_inv=c_inv+cpcs*P_m;
% %% 运行维护成本
% %放电量
% fang=zeros(m1,1);
% for t=1:m1
%     if Pt(t)>0
%     fang(t)=Pt(t) ;
%     end
% end
% %年放电量
% sum_fang=sum( fang(t))*48*365;
% co=0;
% for t=1:T_lcc
%    co=co+ceo*sum_fang*((1+r)^(-t)) ;
% end
% co=co+cpo*P_m*((1+r)^T_lcc-1)/(r*(1+r)^T_lcc) ;
% %% 报废处理成本
% cscr=0;
% for t=1:(n_+1)
%     cscr=cscr+ces*E_b*(1+r)^(-t*T_lcc*(n_+1)) ;
% end
% cscr=cscr+cps*P_m*(1+r)^(-T_lcc);
% %% 缺电惩罚
%
%
% %成本现值
% clcc=c_inv+co+cscr;

end

