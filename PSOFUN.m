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
%% PSO 参数
CostFunction=@(x) CostFun(x);        % 成本函数
w=1;            % 惯性权重
wdamp=0.99;     % 惯性质量阻尼比
c1=1.5;         % 局部学习系数
c2=2.0;         % 全局学习系数
VarSize=[1 nVar];   % 决策变量矩阵大小
% 速度限制
VelMax=0.1*(VarMax-VarMin);
VelMin=-VelMax;

%% 初始化

empty_particle.Position=[];
empty_particle.Cost=[];
empty_particle.Velocity=[];
empty_particle.Best.Position=[];
empty_particle.Best.Cost=[];

particle=repmat(empty_particle,nPop,1);

GlobalBest.Cost=inf;

for i=1:nPop

    % 初始化位置
    particle(i).Position=unifrnd(VarMin,VarMax,VarSize);

    % 初始化速度
    particle(i).Velocity=zeros(VarSize);

    % 评价
    particle(i).Cost=CostFunction(particle(i).Position);

    % 更新局部最佳
    particle(i).Best.Position=particle(i).Position;
    particle(i).Best.Cost=particle(i).Cost;

    % 更新全局最佳
    if particle(i).Best.Cost<GlobalBest.Cost

        GlobalBest=particle(i).Best;

    end

end

BestCost=zeros(MaxIt,1);

%% PSO 主循环

% for it=1:MaxIt
It = 1;
it = 1;
while It ~= 31 && It <= MaxIt

    for i=1:nPop

        % 更新速度
        particle(i).Velocity = w*particle(i).Velocity ...
            +c1*rand(VarSize).*(particle(i).Best.Position-particle(i).Position) ...
            +c2*rand(VarSize).*(GlobalBest.Position-particle(i).Position);

        % 施加速度限制
        particle(i).Velocity = max(particle(i).Velocity,VelMin);
        particle(i).Velocity = min(particle(i).Velocity,VelMax);

        % 更新位置
        particle(i).Position = particle(i).Position + particle(i).Velocity;

        % 速度镜像效应
        IsOutside=(particle(i).Position<VarMin | particle(i).Position>VarMax);
        particle(i).Velocity(IsOutside)=-particle(i).Velocity(IsOutside);

        % 施加位置限制
        particle(i).Position = max(particle(i).Position,VarMin);
        particle(i).Position = min(particle(i).Position,VarMax);

        % 评价
        particle(i).Cost = CostFunction(particle(i).Position);

        % 更新局部最佳
        if particle(i).Cost<particle(i).Best.Cost

            particle(i).Best.Position=particle(i).Position;
            particle(i).Best.Cost=particle(i).Cost;

            % 更新全局最佳
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
    xlabel('迭代次数');
    ylabel('适应度');
    drawnow

    it = it + 1;
end

bestPosition = GlobalBest.Position;
fitValue = GlobalBest.Cost;
disp(['Iteration ' num2str(it - 1) ': Best Cost = ' num2str(BestCost(it - 1))]);


end

