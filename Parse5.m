function xp = Parse5(Data,sampling)

% Data = Data(1:1:end-sampling+1,:);



A = (0:sampling:length(Data)-1);
B = Data(1:sampling:end-sampling+1,1);

d_t_5 = B(2:1:end,1)-B(1:1:end-1,1);
d_t_5 = [0;d_t_5];

for i = 1:1:length(d_t_5)
    if d_t_5(i)<0 
        if i ~= length(d_t_5)
            B(i) = (B(i+1)+B(i-1))/2;
        else 
            B(i) = B(i-1)+(B(i-1)-B(i-2));           
        end 
    end 
end

for i = 1:1:length(B)
Data(1+sampling*(i-1),1)= B(i);
end


for i = 1:1:length(Data(1:1:end-sampling+1,1))/sampling
    for j = 1:1:sampling-1
        Data((i-1)*sampling+j+1,1)=(Data((i)*sampling+1,1)-Data((i-1)*sampling+1,1))/sampling*j+Data((i-1)*sampling+1,1);
    end 
end 

F_Data1 = Data(1:1:end-sampling+1-sampling,1);
F_Data2 = Data(1+sampling:1:end-sampling+1,2:end);

xp = [F_Data1,F_Data2]; % filtfilt for phase correction
%zero phase forward and backwasrds filter.
