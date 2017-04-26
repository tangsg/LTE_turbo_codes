% /*
% 3GPP Turbo encoder
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
function [xk,zk,zk1] = turbo_enco(x,f1,f2,K)

% a--|+|--|m1|--|m2|--|m3| 

% memory 3

%% interleaver
i = 0:K-1;
p = mod(f1*i+f2*(i.^2),K)+1;
x1 = x(p);
%% initialization
me1=0;me2=0;me3=0;
m1=0;m2=0;m3=0;
xk = [x 0 0 0 0];
zk = zeros(1,length(x)+4);
zk1 = zeros(1,length(x)+4);
%% start encoding
for kk=1:length(x)
    Fk = mod(m2+m3,2);% feedback
    zk(kk) = mod(Fk+x(kk)+m1+m3,2);
    m3=m2;m2 = m1;m1 = mod(Fk+x(kk),2);
    Fk1 = mod(me2+me3,2);% feedback
    zk1(kk) = mod(Fk1+x1(kk)+me1+me3,2);
    me3=me2;me2 = me1;me1 = mod(Fk1+x1(kk),2);

end

%% start terminating the trellis encoder I
Fk=mod(m2+m3,2);
xk(kk+1)=Fk;
zk(kk+1)=mod(m1+m3,2);
 m3=m2;m2 = m1;m1 =0;
 
 Fk=mod(m2+m3,2);
zk1(kk+1)=Fk;
xk(kk+2)=mod(m1+m3,2);
 m3=m2;m2 = m1;m1 =0;
 
 Fk=mod(m2+m3,2);
zk(kk+2)=Fk;
zk1(kk+2)=mod(m1+m3,2);
%% start terminating for encoder II
Fk1=mod(me2+me3,2);
xk(kk+3)=Fk1;
zk(kk+3)=mod(me1+me3,2);
 me3=me2;me2 = me1;me1 =0;
 
 Fk1=mod(me2+me3,2);
zk1(kk+3)=Fk1;
xk(kk+4)=mod(me1+me3,2);
 me3=me2;me2 = me1;me1 =0;
 
 Fk1=mod(me2+me3,2);
zk(kk+4)=Fk1;
zk1(kk+4)=mod(me1+me3,2);
% m3=m2;m2 = m1;m1 =Fk;
end

