function [fun, g, Pt, ft, Q_soc] = fun_jieguo(x)
%% ׼������
parameter; %�������е�����
m1 = size(u1, 1);
Pt = zeros(m1, 1);
ft = zeros(m1, 1);
fa1 = zeros(m1, 1);
fa2 = zeros(m1, 1);
% �������߱����ĺ���
soc_h = x(1);      % �ϸ�
soc_l = x(2);      % �ϵ�
P_b = x(3);        % ����
P_s = x(4);        % �۵�
P_m = fix(x(5) + 1);        % ���ֵ
E_b = 0.32*P_m*3600 ;     %��������
E_bt = zeros(m1 + 1, 1);%ʵʱ�ɵ�״̬
E_bt(1) = E_b*soc0;

%% ��дԼ��
% ******************* ����ʽԼ�� ***************************
g=[];
g=[g, P_min - P_m] ; % <=0
g=[g, P_b - P_m] ; % <=0
g=[g, P_s - P_m] ; % <=0
g=[g, soc_l - soc_h] ; % <=0
%   g=[g, soc - soc_max] ; % <=0
%   g=[g, soc_min - soc] ; % <=0

%% ���Ʋ���Լ��
for t=1:m1
    %����
    if u1(t)>=dta_fd&&u1(t)<=dta_fu
        ft(t)=u1(t);
        %�۵�
        if E_bt(t)>E_b*soc_h
            Pt(t)=P_s;
            ft(t)=u1(t)+P_s/Ke;
        end
        %����
        if E_bt(t)<E_b*soc_l
            Pt(t)=-P_b;
            ft(t)=u1(t)-P_b/(Ke);
        end

        %��������
    elseif u1(t)>dta_fu
        ft(t)=u1(t);
        if E_bt(t)<E_b*soc_max&&E_bt(t)>=E_b*soc_min
            Pt(t)=-Ke*u1(t);
            ft(t)=0;
        end
        if E_bt(t)==E_b*soc_max
            fa1(t)=Ke*u1(t);
        end

        %��������
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

%% Ŀ�꺯��
%% 1) ���ǹ����������������ӳһ�ε�ƵЧ��������ָ��Ϊ
fun =0;
for t=1:m1
    fun=fun+ft(t)^2 ;

end
fun=sqrt(fun/m1);
%% 2) ��ӳ�ɵ�״̬ QSOC����Ч��������ָ��Ϊ
Q_soc=0;
for t=1:m1
    Q_soc=Q_soc+((E_bt(t+1)/E_b-soc_ref)^2) ;

end
Q_soc=sqrt(Q_soc/m1);
% %% 3)�ɱ���ֵ
% %% Ͷ�ʳɱ�
% c_inv=0;
% for t=1:n_
%     c_inv=c_inv+cbat*E_b*(1+r)^(-Ke*T_lcc/(n_+1)) ;
% end
% c_inv=c_inv+cpcs*P_m;
% %% ����ά���ɱ�
% %�ŵ���
% fang=zeros(m1,1);
% for t=1:m1
%     if Pt(t)>0
%     fang(t)=Pt(t) ;
%     end
% end
% %��ŵ���
% sum_fang=sum( fang(t))*48*365;
% co=0;
% for t=1:T_lcc
%    co=co+ceo*sum_fang*((1+r)^(-t)) ;
% end
% co=co+cpo*P_m*((1+r)^T_lcc-1)/(r*(1+r)^T_lcc) ;
% %% ���ϴ���ɱ�
% cscr=0;
% for t=1:(n_+1)
%     cscr=cscr+ces*E_b*(1+r)^(-t*T_lcc*(n_+1)) ;
% end
% cscr=cscr+cps*P_m*(1+r)^(-T_lcc);
% %% ȱ��ͷ�
%
%
% %�ɱ���ֵ
% clcc=c_inv+co+cscr;

end

