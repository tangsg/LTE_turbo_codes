%%test
clear all
N=504;
x = rand(1,N)>0.5;
 x = x+0;
% Turbo encoding
K=504;f1=55;f2=84;% 55 420
%K=512;f1=31;f2=64;
%K=6144;f1=263;f2=480;
[xk,zk,zk1]=turbo_enco(x,f1,f2,K);
z = turbo_decoder_max_log_map(-2*xk+1,-2*zk+1,-2*zk1+1,f1,f2,K,1,1,4);

length(find(x-z))