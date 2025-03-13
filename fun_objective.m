function fun = fun_objective(x)
%% ׼������
parameter; %�������е�����
m1=size(u1, 1);
Pt=zeros(m1,1);
ft=zeros(m1,1);
% �������߱����ĺ���
soc_h = x(1);      % �ϸ�
soc_l = x(2);      % �ϵ�
P_b = x(3);        % ����
P_s = x(4);        % �۵�
P_m = fix(x(5) + 1);        % ���ֵ
E_b=0.32*P_m*3600 ;     %��������
E_bt=zeros(m1+1,1);%ʵʱ�ɵ�״̬
E_bt(1)=E_b*soc0;
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


        %��������
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

%% Ŀ�꺯��
fun =0;
for t=1:m1
    fun=fun+ft(t)^2 ;

end
fun=sqrt(fun/m1);
%**********************����������*************************

Big=1;
N=length(g);

G=0;
for n=1:N
    G=G+sqrt(max(0, g(n))^2);
end



%*******************���뷣�������Ŀ�꺯��******************

fun=fun+Big*G;

end

