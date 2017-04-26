% /*
% Turbo decoder based on BCJR
%     Copyright (C) 2017  sreekanth
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
% 
%  * Author: sreekanth dama
%  * Contact: sreekanth@iith.ac.in
%  **/

function [z, Lezero2,Lezero1]= turbo_decoder_max_log_map(x,y1,y2,f1,f2,K,ite,SNR,norm)


%% random initialization
ref = [0 0;1 1;1 0;0 1;0 1;1 0;1 1;0 0; ...
       1 1;0 0;0 1;1 0;1 0;0 1;0 0;1 1];
      
      reff = (1-2*ref);
      %% interleaver data
      p1 = 0:K-1;
      p2 = mod(f1*p1+f2*(p1.^2),K);
      p3(p2+1) = p1;
      %p3 = mod(f3*p1+f4*(p1.^2),K);
      x1 = x(p2+1);
      
      % calculating LLRs for both decoders
      Lro1 = zeros(16,K);Lro2 = zeros(16,K);Lrsp1 = zeros(16,K);Lrsp2 = zeros(16,K);
      for kk = 1:K
              Lro1(:,kk) = (reff(:,2).*kron(y1(kk),ones(16,1)));
              Lro2(:,kk) = (reff(:,2).*kron(y2(kk),ones(16,1)));
              Lrsp1(:,kk) = (reff(:,1).*kron(x(kk),ones(16,1)));
              Lrsp2(:,kk) = (reff(:,1).*kron(x1(kk),ones(16,1)));
      end
      

      
      %% serial decoding
      % some initialization
      n=1/2;
      Lezero2=zeros(1,K);at = zeros(1,K+1);%Lezero1=zeros(1,K);
      Lr1 = -inf*ones(16,K);Lr2 = -inf*ones(16,K);Lezero11=zeros(1,K);Lezero22=zeros(1,K);Lezero1=zeros(1,K);
   for iter=1:ite   
      %% Decoder I
      
      Lr11 = (SNR*(Lro1+Lrsp1)/n+kron(Lezero2,reff(:,1))/norm);
      for kk = 1:K
              Lr1(:,kk) = Lr11(:,kk);
      end
      alpha = (zeros(8,K+1));alpha(1,1)=0;
   beta = (zeros(8,K+1));%beta(endstate1,K+1)=0;
      % alpha  forward metric
      for ii = 1:K
      for jj = 1:4
                    % state 1-4
          bm1 = (Lr1(2*jj-1,ii))+alpha(2*jj-1,ii);
          bm2 = (Lr1(2*jj,ii))+alpha(2*jj,ii);
          alpha(jj,ii+1) =max([bm1,bm2]);
                    % state 5-8
          bm1 = (Lr1(8+2*jj-1,ii))+alpha(2*jj-1,ii);
          bm2 = (Lr1(8+2*jj,ii))+alpha(2*jj,ii);
          alpha(4+jj,ii+1) = max([bm1,bm2]);
      end
 %      at = sum(alpha(:,ii+1));
 %      alpha(:,ii+1)=alpha(:,ii+1)/at;
      end
 %      at(1)=1;
      
      % beta backward metric
      for ii = K:-1:1
      for jj = 1:8
                    % state 1-32
          bm1 = (Lr1(jj,ii))+beta(ceil(jj/2),ii+1);
          bm2 = (Lr1(8+jj,ii))+beta(4+ceil(jj/2),ii+1);
          beta(jj,ii) = max([bm1,bm2]);
      end
%        bt = (sum((beta(:,ii))));
%       beta(:,ii)=beta(:,ii)/bt;
      end
      out1 = zeros(16,K);out2 = zeros(16,K);
      for ii = 1:K
          for jj = 1:8
              out1(jj,ii) = ref(jj,1)*(alpha(jj,ii)+beta(ceil(jj/2),ii+1)+(Lro1(jj,ii)*SNR/n));
              out1(8+jj,ii) = ref(8+jj,1)*(alpha(jj,ii)+beta(4+ceil(jj/2),ii+1)+(Lro1(8+jj,ii)*SNR/n));
              out2(jj,ii) = ref(8+jj,1)*(alpha(jj,ii)+beta(ceil(jj/2),ii+1)+(Lro1(jj,ii)*SNR/n));
              out2(8+jj,ii) = ref(jj,1)*(alpha(jj,ii)+beta(4+ceil(jj/2),ii+1)+(Lro1(8+jj,ii)*SNR/n));
          end
            Lezero11(ii) = max(out2(:,ii))-max(out1(:,ii)); % LLR of 0
      end
      
      % interleave the extrensic
      Lezero1=Lezero11(p2+1);
      %% Decoder II
      
      Lr22 = (SNR*(Lro2+Lrsp2)/n+kron(Lezero1,reff(:,1))/norm);
      for kk = 1:K
              Lr2(:,kk) = Lr22(:,kk);
      end
     alpha = (zeros(8,K+1));alpha(1,1)=0;
   beta = (zeros(8,K+1));%beta(endstate2,K+1)=0;
      % alpha  forward metric
      for ii = 1:K
      for jj = 1:4
                    % state 1-4
          bm1 = (Lr2(2*jj-1,ii))+alpha(2*jj-1,ii);
          bm2 = (Lr2(2*jj,ii))+alpha(2*jj,ii);
          alpha(jj,ii+1)=max([bm1,bm2]);
                    % state 5-8
          bm1 = (Lr2(8+2*jj-1,ii))+alpha(2*jj-1,ii);
          bm2 = (Lr2(8+2*jj,ii))+alpha(2*jj,ii);
          alpha(4+jj,ii+1) = max([bm1,bm2]);
      end
%       at = sum(alpha(:,ii+1));
%       alpha(:,ii+1)=alpha(:,ii+1)/at;
      end
%       at(1)=1;
      
      % beta backward metric
      for ii = K:-1:1
      for jj = 1:8
                    % state 1-32
          bm1 = (Lr2(jj,ii))+beta(ceil(jj/2),ii+1);
          bm2 = (Lr2(8+jj,ii))+beta(4+ceil(jj/2),ii+1);
          beta(jj,ii) = max([bm1,bm2]);
      end
%       bt = (sum((beta(:,ii))));
%       beta(:,ii)=beta(:,ii)/bt;
      end
      for ii = 1:K
          for jj = 1:8
              out1(jj,ii) = ref(jj,1)*(alpha(jj,ii)+beta(ceil(jj/2),ii+1)+(Lro2(jj,ii)*SNR/n));
              out1(8+jj,ii) = ref(8+jj,1)*(alpha(jj,ii)+beta(4+ceil(jj/2),ii+1)+(Lro2(8+jj,ii)*SNR/n));
              out2(jj,ii) = ref(8+jj,1)*(alpha(jj,ii)+beta(ceil(jj/2),ii+1)+(Lro2(jj,ii)*SNR/n));
              out2(8+jj,ii) = ref(jj,1)*(alpha(jj,ii)+beta(4+ceil(jj/2),ii+1)+(Lro2(8+jj,ii)*SNR/n));
          end
            Lezero22(ii) = max(out2(:,ii))-max(out1(:,ii)); % LLR of 0
      end
      % de interleave the extrensic info
      Lezero2=Lezero22(p3+1);
   end
    z = (Lezero2+Lezero1(p3+1)+2*SNR*x(1:K))<0;
Lezero1 = Lezero1(p3+1);
end

