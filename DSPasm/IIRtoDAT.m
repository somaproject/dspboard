function output=IIRtoDAT(SOS, G, filename)
%function IIRtoDAT(SOS, G, filename)
% takes a second-order structure SOS and gain factor G from the matlab
% filter design tools and writes the resulting single-precision hex
% to file filename. 
%     SOS is an L by 6 matrix with the following structure:
%          SOS = [ b01 b11 b21  1 a11 a21 
%                  b02 b12 b22  1 a12 a22
%                  ...
%                  b0L b1L b2L  1 a1L a2L ]
%   
%      Each row of the SOS matrix describes a 2nd order transfer function:
%                    b0k +  b1k z^-1 +  b2k  z^-2
%          Hk(z) =  ----------------------------
%                     1 +  a1k z^-1 +  a2k  z^-2
%      where k is the row index.
% 
% we want to normalize b1n and b2n by b0n, and we also need to be
% concerned with the gain. For more info help zp2sos.

[orders, coeffs] = size(SOS);
output = zeros(orders*4+1,1);
output(1) = G;


for i = 0:(orders-1)
  output(2+i*4) = -SOS(i+1, 6);
  output(3+i*4) = -SOS(i+1, 5);
  output(4+i*4) = SOS(i+1, 3);
  output(5+i*4) = SOS(i+1, 2);  
end;
output

FIRtoDAT(output, filename);

