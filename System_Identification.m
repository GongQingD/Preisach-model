%% Preisach正模型
data1=importdata('data7.mat');%data1

data=100; %%数据量
u_u=zeros(data,1);%单调上升阶段的系统输入
u_d=zeros(data,1);%单调下降阶段的系统输入
y_test_u=zeros(data,1);%单调上升阶段的系统输出
y_test_d=zeros(data,1);%单调下降阶段的系统输出
for i=2:101%赋值
    u_u(i-1,1)=data1(1,i);
    u_d(i-1,1)=data1(1,99+i);
    y_test_u(i-1,1)=data1(2,i);
    y_test_d(i-1,1)=data1(2,99+i);
end
%  w=ow*ou
ow_u=tril(ones(data));
ou_u=zeros(data,data);

ow_d=tril(ones(data));
ou_d=zeros(data,data);
for i=1:data         %%给ou赋值
    for j=1:data
        if j < i || j==i
            if i==1
                ou_u(i,j)=u_u(1,1);
                ou_d(i,j)=u_d(1,1);
            else
                ou_u(i,j)=(u_u(i,1)-u_u(i-1,1))/i;
                ou_d(i,j)=(u_d(i,1)-u_d(i-1,1))/i;
            end
        end
    end
end
%求preisach函数v(data*1)
v_u=inv(ou_u)*inv(ow_u)*y_test_u;
v_d=inv(ou_d)*inv(ow_d)*y_test_d;

%画preisach函数的三维图像
%data*data的Preisach函数（用来画图）
ov_u=zeros(data,data);
ov_d=zeros(data,data);
for i=1:data
    for j=1:data
        if j < i || j==i
            ov_u(i,j)=v_u(i,1)/i;  
            ov_d(i,j)=v_d(i,1)/i; 
        end
    end
end
figure(1)
mesh(ov_u);
colorbar
%% 用新的数据进行系统辨识，画出系统辨识结果与原系统输出（50Hz 0-100v）
%%系统输入
u_u=zeros(data,1);
u_d=zeros(data,1);
%%数据导入
data2=importdata('data10.mat');%data2

for i=2:101
    u_u(i-1,1)=data2(1,i);
    u_d(i-1,1)=data2(1,i+100);
end

%输入矩阵ou
ou_u=zeros(data,data);
ou_d=zeros(data,data);

for i=1:data         %%给ou赋值
    for j=1:data
        if j < i || j==i
            if i==1
                ou_u(i,j)=u_u(1,1);
                ou_d(i,j)=u_d(1,1);
            else
                ou_u(i,j)=(u_u(i,1)-u_u(i-1,1))/i;
                ou_d(i,j)=(u_d(i,1)-u_d(i-1,1))/i;
            end
        end
    end
end

%%辨识结果
y_test_u=ow_u*ou_u*v_u;
y_test_d=ow_d*ou_d*v_d;
y_test=zeros(data*2,1);
%%对辨识结果作拼接（上升段和下降段拼起来）
for i=1:200
    if i<101
        y_test(i,1)=y_test_u(i,1);
    else
        y_test(i,1)=y_test_d(i-100,1);
    end
end

%%画图
figure(2)
plot(data2(1,2:201),data2(2,2:201));
hold on 
plot(data2(1,2:201),y_test);
y1=zeros(data*2,1);
for i=1:200
    y1(i,1)=data2(2,i+1)-y_test(i,1);
end
figure(3)
plot(data2(1,2:201),y1);
%% 需要进行插值的数据的系统辨识
%%导入数据
data3=importdata('data8.mat');%data3
data=100;%%数据量（与输入信号的频率相关）

%%系统输入
%单调上升
x_test_u=data3(1,1:51);%%插值前的数据
y_test_u=data3(2,1:51);
%单调下降
x_test_d=data3(1,51:101);%%插值前的数据
y_test_d=data3(2,51:101);

%%插值后的数据
%单调上升
u_u=1:1:100;
y_u=interp1(x_test_u,y_test_u,u_u,'spline');
%单调下降
u_d=100:-1:1;
y_d=interp1(x_test_d,y_test_d,u_d,'spline');

%%输入矩阵ou
ou_u=zeros(data,data);
ou_d=zeros(data,data);

for i=1:data         %%给ou赋值
    for j=1:data
        if j < i || j==i
            if i==1
                ou_u(i,j)=u_u(1,1);
                ou_d(i,j)=u_d(1,1);
            else
                ou_u(i,j)=(u_u(1,i)-u_u(1,i-1))/i;
                ou_d(i,j)=(u_d(1,i)-u_d(1,i-1))/i;
            end
        end
    end
end

%%y_test，系统辨识后的数据；y插值后的数据
y_test_u=ow_u*ou_u*v_u;
y_test_d=ow_d*ou_d*v_d;
y_test=zeros(data*2,1);
y=zeros(data*2,1);
%将上升段和下降段拼接起来
for i=1:200
    if i<101
        y_test(i,1)=y_test_u(i,1);
        y(i,1)=y_u(1,i);
    else
        y_test(i,1)=y_test_d(i-100,1);
        y(i,1)=y_d(1,i-100);
    end
end
%%画图
figure(2)
x=zeros(200,1);
for i=1:100
    x(i,1)=i;
end
for i=1:100
    x(i+100,1)=100-i;
end

plot(x,y_test);%%辨识的数据
hold on 
plot(x,y);%%插值后的数据

%误差
y1=zeros(data*2,1);
for i=1:200
    y1(i,1)=y(i,1)-y_test(i,1);
end
figure(3)
plot(x,y1);
%% 对数据集内所有数据做辨识（多个迟滞环）
%%%%数据导入
data2=importdata('data10.mat');%data2
data=100;
%%读取输入
u_u=zeros(data,6);
u_d=zeros(data,6);
for tag=1:6
    for i=2:101
        u_u(i-1,tag)=data2(1,i+(tag-1)*200);
        u_d(i-1,tag)=data2(1,(i+data-1)+(tag-1)*200);
    end
end
%%读取输出
y_u=zeros(data,6);
y_d=zeros(data,6);
for tag=1:6
    for i=2:101
        y_u(i-1,tag)=data2(2,i+(tag-1)*200);
        y_d(i-1,tag)=data2(2,(i+data-1)+(tag-1)*200);
    end
end

%%辨识结果
y_test=zeros(data*2,6);
for tag=1:6
    %输入矩阵ou
    ou_u=zeros(data,data);
    ou_d=zeros(data,data);
    for i=1:data         %%给ou赋值
        for j=1:data
            if j < i || j==i
                if i==1
                    ou_u(i,j)=u_u(1,tag);
                    ou_d(i,j)=u_d(1,tag);
                else
                    ou_u(i,j)=(u_u(i,tag)-u_u(i-1,tag))/i;
                    ou_d(i,j)=(u_d(i,tag)-u_d(i-1,tag))/i;
                end
            end
        end
    end
    
    %%辨识结果
    y_test_u=ow_u*ou_u*v_u;
    y_test_d=ow_d*ou_d*v_d;
    
    %%对辨识结果作拼接（上升段和下降段拼起来）
    for i=1:200
        if i<101
            y_test(i,tag)=y_test_u(i,1);%%y_test在for前面就定义了
        else
            y_test(i,tag)=y_test_d(i-100,1);
        end
    end
end

%%画图
plot(data2(1,:),data2(2,:));%%原数据
hold on
x=zeros(200,1);
for i=1:100
    x(i,1)=i;
end
for i=1:100
    x(i+100,1)=100-i;
end
plot(x,y_test(:,1));







