function FIRtoDAT(h, filename)
% function FIRtoDAT(h, filename)
% takes a finite-impulse response vector and outputs a file
% for import by the soma DSP code, in single float hex

i = length(h);
fid=fopen(filename, 'w'); 
for j = 1:i
 [test, str] = system(sprintf('./singletohex %0.10f', h(j)));
 fprintf(fid, '0x%s\r\n', str);
 
end

fclose(fid); 

