ranges = [0 31 62 125 250 500 1000 2000 4000 8000 16000 20000];  % 12 ����������Ƶ��

%%%%%%%%%%%% Options list %%%%%%%%%%%%%%
pause = 0;
exit = 0;
isSpectrumDomain = 0;

audioName = 'Soaring.mp3';

changed = 1;
filterCoefs = [2 2 2 1 1 1 1 1 1 1]; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Ƶ��Χ��Լ�ǲ����ʵ�һ��

File = dsp.AudioFileReader(audioName);
File.SamplesPerFrame = 1000;  % This parameter determines the frequency of ploting 

SPF = File.SamplesPerFrame;
Fs = File.SampleRate;
mult = ceil(Fs / SPF);
usedFs = mult * SPF; % Approximately Fs (46000)

Out = audioDeviceWriter('SampleRate', File.SampleRate); % Speaker
Spectrum = dsp.SpectrumAnalyzer('SampleRate',Fs, 'PlotAsTwoSidedSpectrum', false,'FrequencyScale', 'Log', 'SpectrumType', 'RMS');

% Initialization
spectCoefs = ones([usedFs 1]);


x = step(File);

tic
while (toc < 2 || any(x(:,1))) && ~exit % (toc < 2) avoids stopping at the begining
    if (~pause)        % 
        newX = x;
        
        % ��չ��ƵƬ��
        for i = 1:(mult-1)
            newX = [newX; x];
        end
        newX = newX';
        
        % ����GUI�ĵ����������Lazy���£�������£�
        if (changed)
            changed = 0;
            
            % �����˲�������
            filterCoefs = [filterCoefs(1) filterCoefs filterCoefs(end)];  % ����������
            spectCoefs = [];                                              % ���ݾ���������������Ƶ�װ���
            for i = 1:(length(filterCoefs)-2)
                spectCoefs = [spectCoefs linspace(filterCoefs(i), filterCoefs(i+1), ceil(usedFs/2*(ranges(i+1)-ranges(i))/20000))]; % half the size of newX
            end
            spectCoefs = [spectCoefs filterCoefs(end) * ones([1 round(usedFs/2)-length(spectCoefs)])];
            if mod(usedFs, 2)
                spectCoefs = [spectCoefs 0 fliplr(specCoefs)];
            else
                spectCoefs = [spectCoefs fliplr(spectCoefs)];
            end
            
            timeCoefs = real(ifft(spectCoefs))*10;
        end
        
        % ����������
        if (isSpectrumDomain) 
            newX(1,:) = fft(newX(1,:)) .* spectCoefs;
            newX(2,:) = fft(newX(2,:)) .* spectCoefs;
        else
            newX = [newX(1,1:SPF); newX(2,1:SPF)];
             temp = conv(timeCoefs, newX(1,:));
             plot(1:length(timeCoefs), timeCoefs);
             newX(1,:) = temp(1:SPF);
             temp = conv(timeCoefs, newX(2,:));
             newX(2,:) = temp(1:SPF);
        end 
        
        % ����任����ȡ��ƵƬ�β��Ҳ���
        newX(1,:) = ifft(newX(1,:));
        newX(2,:) = ifft(newX(2,:));
        newX = real(newX(:,1:SPF)');
        step(Spectrum, [newX(:,1) x(:,1)]);
        step(Out, newX);
        x = step(File);
    end
end
