[harm_coef, envelope, one_sec_index] = instrumentPropertyScan('pianoC.mp3');
fs = one_sec_index; 
audio_array = beatGene(envelope, one_sec_index, harm_coef, 1046, fs);
sound(audio_array, fs);
disp(size(audio_array));
% DEBUG


% Plots
figure(1);
% subplot(2,1,1); plot(envelope);
subplot(2,1,2); plot(audio_array);
