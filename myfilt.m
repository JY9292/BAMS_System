function xp = myfilt(x, fs, fcut, type)
% x: raw data
% fs: sampling rate
% fcut: cutoff frequency, can be a vector when the type is 'bandpass'
% type: type of the filter
%     'low': lowpass
%     'high': highpass
%     'bandpass': band-pass 
%     'stop': band-stop
    
% Copyright (c) 2019, Xiaoyue Ni

if size(x,1)==1
    x = x'; % correct vector dimension for 'flipud'
end
% use forth order cutoff as default
% design frequency response: zero, pole, gain representation of butterworth filter
% other representation is also available, e.g. a,b transfer function ones
% please refer Mathwork documentation for further details:
% https://www.mathworks.com/help/signal/ref/butter.html
[z, p, g] = butter(3, fcut/(fs/2), type); 

% to optimize the stability of the filter
[sos,g] = zp2sos(z, p, g);
f = dfilt.df2sos(sos,g);

xp = f.filter(x); % filter
xp = flipud(f.filter(flipud(xp))); % filtfilt for phase correction
%zero phase forward and backwasrds filter.
