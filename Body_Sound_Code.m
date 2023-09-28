clc
clear all
close all

M_Folders = "Body_Sound";

%% Reading the Data
Data_I = readmatrix(sprintf('%s/IMU.csv',M_Folders));
Data_I = Parse5(Data_I,340);
t_I = Data_I(:,1)/4000;
AccX = Data_I(:,2);
AccY = Data_I(:,3);
AccZ = Data_I(:,4);
F_AccZ = myfilt(AccZ-AccZ(1), 100, [0.1 0.9], 'bandpass')+AccZ(1);


Data_M = readmatrix(sprintf('%s/Microphone.csv',M_Folders));
Data_M = Parse5(Data_M,510);
t_M = Data_M(:,1)/4000;

ti = (t_M(1):1/1000:t_M(end))';

Mic1_M = interp1(t_M,Data_M(:,2),ti); % ambient-facing microphone
Mic2_M = interp1(t_M,Data_M(:,3),ti); % Body-facing microphone

Mic1_M = myfilt(Mic1_M, 1000, [10 450], 'bandpass');
Mic2_M = myfilt(Mic2_M, 1000, [10 450], 'bandpass');

%% Sound Separation

L  = 10;
N  = 200;
fls = dsp.RLSFilter(15, 'ForgettingFactor', 0.995);
%  
[~,e1_1] = fls(-Mic1_M,Mic2_M);
[~,e1_2] = fls(Mic2_M,Mic1_M);
[~,NC1] = fls(e1_2,e1_1);

figure(2)

subplot(3,1,1)
plot(t_I,F_AccZ)
xlabel('time(s)')
ylabel('Accel.(g)')
title('low-pass filtered Accel.(g)')

subplot(3,1,2)
plot(ti,[Mic2_M,Mic1_M])
xlabel('time(s)')
ylabel('Raw data of Mic (ADC)')
title('Raw data of Mic (ADC)')


subplot(3,1,3)
plot(ti,NC1)
xlabel('time(s)')
ylabel('Sound seperated Mic data')
title('Sound seperated Mic data')

%% Bandpass filtering to seperate cardiac and respiratory sound

Cardiac_Sound = myfilt(NC1, 1000, [10 150], 'bandpass'); % cardiac sound 
Resp_Sound= myfilt(NC1, 1000, [150 450], 'bandpass');  %respiratory sound 

figure(2), 
subplot(2,1,1)
plot(ti,Cardiac_Sound)
xlabel('time(s)')
ylabel('Cardiac Sound')
title('Cardiac Sound')

subplot(2,1,2)
plot(ti,Resp_Sound)
xlabel('time(s)')
ylabel('Respiratory sound')
title('Respiratory sound')

%% Spectrogram and STFT 

w = 0.05 ; 
fs = 1000;
win = round(fs*w); ov = round(fs*w*0.9); nfft = round(fs*0.5);


[S_M,F_M,T_M,P_M] = spectrogram(Mic2_M,win,ov,nfft,fs); % body-facing Mic Raw sound
[S_N,F_N,T_N,P_N] = spectrogram(NC1,win,ov,nfft,fs); % body sound
[S_C,F_C,T_C,P_C] = spectrogram(Cardiac_Sound,win,ov,nfft,fs); % cardiac sound 
[S_R,F_R,T_R,P_R] = spectrogram(Resp_Sound,win,ov,nfft,fs); % respiratory sound

T_M = T_M+ti(1);
T_N = T_N+ti(1);
T_C = T_C+ti(1);
T_R = T_R+ti(1);

figure(3)
subplot(5,1,1)
plot(t_I,F_AccZ)
xlim([t_I(1) t_I(end)])
xlabel('time(s)')
ylabel('Accel.(g)')
title('low-pass filtered Accel.(g)')

subplot(5,1,2)
surf(T_M,F_M,10*log10(P_M),'edgecolor','none'); axis tight;
view(0,90);  caxis([0 40]);  colorbar;
colormap(inferno)
xlim([t_I(1) t_I(end)])
xlabel('time(s)')
ylabel('Freq.(Hz)')
title('Raw sound')

subplot(5,1,3)
surf(T_N,F_N,10*log10(P_N),'edgecolor','none'); axis tight;
view(0,90);  caxis([5 40]);  colorbar;
colormap(inferno)
xlim([t_I(1) t_I(end)])
xlabel('time(s)')
ylabel('Freq.(Hz)')
title('Body sound')

subplot(5,1,4)
surf(T_R,F_R,10*log10(P_R),'edgecolor','none'); axis tight;
view(0,90);  caxis([5 40]);  colorbar;
colormap(inferno)
xlim([t_I(1) t_I(end)])
xlabel('time(s)')
ylabel('Freq.(Hz)')
title('Respiratory sound')


subplot(5,1,5)
surf(T_C,F_C,10*log10(P_C),'edgecolor','none'); axis tight;
view(0,90);  caxis([10 50]);  colorbar;
colormap(inferno)
xlim([t_I(1) t_I(end)])
xlabel('time(s)')
ylabel('Freq.(Hz)')
title('Cardiac sound')


%% Sound Intensity
 I_Cardiac = sum(P_C(10:50,:));
 I_Resp = sum(P_R(75:end,:));

 figure (4), 
subplot(3,1,1)
plot(t_I,F_AccZ)
xlim([t_I(1) t_I(end)])
xlabel('time(s)')
ylabel('Accel.(g)')
title('low-pass filtered Accel.(g)')

subplot(3,1,2)
plot(T_R,(I_Resp))
xlim([t_I(1) t_I(end)])
xlabel('time(s)')
ylabel('Intensity')
title('Respiratory Sound')

subplot(3,1,3)
plot(T_C,(I_Cardiac))
xlim([t_I(1) t_I(end)])
xlabel('time(s)')
ylabel('Intensity')
title('Caridac Sound')

