clear all
%coder -build max_log_map.prj;
%matlabpool 24;
iterations = [12];
ttt=10;
%Ebnodb =[0.75:.25:2];%
%Ebnodb =[6:2:8];%
Ebnodb =[0:.1:1 1.5:0.5:3];%[0 0.5 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.25 2.5 2.75 3];
Norm =1;
Ecnodb =Ebnodb-10*log10(3); %[1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.25 2.5 2.75 3 3.5 4 4.5 5];
N=6144; %4000 12 hours  2*E7
%512,31,64 -->479 64 223 320
% 6144 263 480 --> 2231 2784 || 5303 5856
ppp=zeros(length(iterations),length(Ecnodb));
ppp_fer=zeros(length(iterations),length(Ecnodb));
tic
for iter=1:length(iterations)
%tic
iter
it = iterations(iter);
for SNR=1:length(Ecnodb)
%x = [1 0 1 0 1 1 1 0 0 0];
SNR
ppp(iter,SNR)=0;
for kkk=1:ttt
 
 x = rand(1,N)>0.5;
 x = x+0;
% Turbo encoding
K=6144;f1=263;f2=480;f3=2231;f4=2784;
[xk,zk,zk1]=turbo_enco(x,f1,f2,K);

% add noise

data = reshape([xk;zk;zk1],1,[]);
mod_code = (1-2*data);
% mod_code = QPSK_mod(data).';
tx = mod_code+((10^(-Ecnodb(SNR)/20))*(randn(1,length(mod_code))+1i*randn(1,length(mod_code))))/sqrt(2);
% rx = demod_QPSK_soft(tx);
rx = real(tx);
rxx = reshape(rx,3,[]);
rx1 = rxx(1,:);rx2 = rxx(2,:);rx3 = rxx(3,:);
[z lezero2 lezero1]= turbo_decoder_max_log_map(rx1,rx2,rx3,f1,f2,K,it,10^(Ecnodb(SNR)/10),2);
errr = length(find(x-z));
ppp(iter,SNR)=ppp(iter,SNR)+errr;
ppp_fer(iter,SNR)=ppp_fer(iter,SNR)+ceil(errr/N);
end
end
ppp_fer(iter,:) = ppp_fer(iter,:)/(ttt);
ppp(iter,:) = ppp(iter,:)/(N*ttt);
%toc
end
toc
time_taken=toc;
%save maxlog_1000
semilogy(Ebnodb,ppp(1,:),0:1:10,erfc(10.^((0:1:10)/20))/2);%,Ebnodb,ppp(2,:));%,Ebnodb,ppp(3,:));%,Ebnodb,ppp(4,:),Ebnodb,ppp(5,:),Ebnodb,erfc(10.^(Ebnodb/20))/2);
%semilogy(Ebnodb,ppp(1,:));
hold all
%semilogy(Ebnodb,ppp_fer(1,:),Ebnodb,ppp_fer(2,:),Ebnodb,ppp_fer(3,:),Ebnodb,ppp_fer(4,:),Ebnodb,ppp_fer(5,:),Ebnodb,erfc(10.^(Ebnodb/20))/2);
% semilogy(Ebnodb,ppp_fer(1,:),Ebnodb,ppp_fer(2,:),Ebnodb,ppp_fer(3,:),Ebnodb,erfc(10.^(Ebnodb/20))/2);
% grid on
H = legend('1/3 turbo','uncoded theory');%,'iter 10','iter 20','uncoded');
% hold on

% semilogy(Ebnodb,ppp(1,:),Ebnodb,ppp(2,:),Ebnodb,ppp(3,:),Ebnodb,ppp(4,:),Ebnodb,ppp(5,:),Ebnodb,ppp(6,:),Ebnodb,erfc(10.^(Ebnodb/20))/2);
%  H = legend('iter 1','iter 2','iter 3','iter 5','iter 10','iter 18','uncoded');
% %grid on
% hold on
% H = legend('iter 1');






%% Trash

% first encoder
% y1 = turbo_enco(x);
% %interleaver
% i = 0:N-1;
% f1=3;f2=10;
% p = mod(f1*i+f2*(i.^2),N)+1;
% x1 = x(p);
% 
% % second encoder
% y2 = turbo_enco(x1);
% 
% code = reshape([x;y1;y2],1,[]);
% %% viterbi decoding
% z = turbo_viterbi(1-2*y1);
% 
% length(find(z-x))


%% Turbo decoder

%z1 = turbo_decoder(x,y1,y2);
