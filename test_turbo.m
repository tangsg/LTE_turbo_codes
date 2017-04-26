% /*
% Decoder usage
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