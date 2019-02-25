clear;
clc;

[y, Fs] = audioread('./sound_material/piano/piano_47.mp3');

ylen = length(y);
Nfft = 2^nextpow2(ylen(1)); %matlab �±��1��ʼ
Y = fft(y, Nfft);
f = Fs/2*linspace(0,1,Nfft/2+1);


subplot(1,2,1);
plot (y);
title('raw sound of 47 piano');
xlabel('time(ms)')

subplot(1,2,2);
plot(f, 2*abs(Y(1:Nfft/2+1)));
title('freq after fft');
xlabel('freq(Hz)');
ylabel('|Y(f)|');

sound (y, Fs);