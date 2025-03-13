function [ bestPosition, fitValue ] = ...
    PSOFUN( CostFun,nVar,VarMin,VarMax,MaxIt,nPop )
% Copyright (c) 2015, Yarpiz (www.yarpiz.com)
% All rights reserved. Please read the "license.txt" for license terms.
%
% Project Code: YPEA102
% Project Title: Implementation of Particle Swarm Optimization in MATLAB

%
% Developer: S. Mostapha Kalami Heris (Member of Yarpiz Team)
%
% Contact Info: sm.kalami@gmail.com, info@yarpiz.com
%
%% PSO ����
CostFunction=@(x) CostFun(x);        % �ɱ�����
w=1;            % ����Ȩ��
wdamp=0.99;     % �������������
c1=1.5;         % �ֲ�ѧϰϵ��
c2=2.0;         % ȫ��ѧϰϵ��
VarSize=[1 nVar];   % ���߱��������С
% �ٶ�����
VelMax=0.1*(VarMax-VarMin);
VelMin=-VelMax;

%% ��ʼ��

empty_particle.Position=[];
empty_particle.Cost=[];
empty_particle.Velocity=[];
empty_particle.Best.Position=[];
empty_particle.Best.Cost=[];

particle=repmat(empty_particle,nPop,1);

GlobalBest.Cost=inf;

for i=1:nPop

    % ��ʼ��λ��
    particle(i).Position=unifrnd(VarMin,VarMax,VarSize);

    % ��ʼ���ٶ�
    particle(i).Velocity=zeros(VarSize);

    % ����
    particle(i).Cost=CostFunction(particle(i).Position);

    % ���¾ֲ����
    particle(i).Best.Position=particle(i).Position;
    particle(i).Best.Cost=particle(i).Cost;

    % ����ȫ�����
    if particle(i).Best.Cost<GlobalBest.Cost

        GlobalBest=particle(i).Best;

    end

end

BestCost=zeros(MaxIt,1);

%% PSO ��ѭ��

% for it=1:MaxIt
It = 1;
it = 1;
while It ~= 31 && It <= MaxIt

    for i=1:nPop

        % �����ٶ�
        particle(i).Velocity = w*particle(i).Velocity ...
            +c1*rand(VarSize).*(particle(i).Best.Position-particle(i).Position) ...
            +c2*rand(VarSize).*(GlobalBest.Position-particle(i).Position);

        % ʩ���ٶ�����
        particle(i).Velocity = max(particle(i).Velocity,VelMin);
        particle(i).Velocity = min(particle(i).Velocity,VelMax);

        % ����λ��
        particle(i).Position = particle(i).Position + particle(i).Velocity;

        % �ٶȾ���ЧӦ
        IsOutside=(particle(i).Position<VarMin | particle(i).Position>VarMax);
        particle(i).Velocity(IsOutside)=-particle(i).Velocity(IsOutside);

        % ʩ��λ������
        particle(i).Position = max(particle(i).Position,VarMin);
        particle(i).Position = min(particle(i).Position,VarMax);

        % ����
        particle(i).Cost = CostFunction(particle(i).Position);

        % ���¾ֲ����
        if particle(i).Cost<particle(i).Best.Cost

            particle(i).Best.Position=particle(i).Position;
            particle(i).Best.Cost=particle(i).Cost;

            % ����ȫ�����
            if particle(i).Best.Cost<GlobalBest.Cost

                GlobalBest=particle(i).Best;

            end

        end

    end

    BestCost(it)=GlobalBest.Cost;
    It = It + 1;
    if it > 1 && BestCost(it) ~= BestCost(it - 1)
        It = 1;
    end
    subplot(2, 2, 1)
    disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
    w=w*wdamp;
    plot(BestCost(1:it),'r','LineWidth',2);
    xlabel('��������');
    ylabel('��Ӧ��');
    drawnow

    it = it + 1;
end

bestPosition = GlobalBest.Position;
fitValue = GlobalBest.Cost;
disp(['Iteration ' num2str(it - 1) ': Best Cost = ' num2str(BestCost(it - 1))]);


end

