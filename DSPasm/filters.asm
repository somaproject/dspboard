.SECTION/PM pm_code;
fir: // finite-impulse-response filter. 
/* Input: 
	r1 : length of filter
	B0, I0, L0, m0 : inputs for data circular buffer
	b8 : base of filter
	
   Touches: 
   	f0, f4, f8, f12
	M0, M8, L8, B8; 

   Return:
    f8 -- accumulated sum
*/
	f8 = 0;  	// zero accumulator register
	r1 = r1 - 1; // actually need to RMAC one-fewer times 
        lcntr=r1, do macs until lce;                       
macs:   f12=f0*f4, f8=f8+f12, f0=dm(i0,m0), f4=pm(i8,m8);
        rts (db);
        f12=f0*f4, f8=f8+f12;
                   f8=f8+f12;

iir: // cascade biquad implementation of IIR filter
/* This implementation needs a wee bit of explanation, so again see the 
	master design document for DSP code. 
Input
	r1 : length (number of biquad sections)
	f8 : input sample
	b0 : address of buffer for storing intermediates (w[n]s)
	b8 : address of coefficient buffer
	l0, l1, l8 = 0; 

Output:
	f8 : output sample

Touches:
	f2, f3, f4, f8, f12
	i0, b1, i1, i8
*/

b1 = b0; // i1 is used to update the delay line with new values, it lags behind i0;

// set f12 = 0, get a2 coefficient, get w(n-2)
f12=f12 - f12, f2=dm(i0, m1), f4=pm(i8, m8); 

lcntr = r1, do quads until lce;
	// execute quads loop once for each biquad section//
	// within the intermediate buffer, we end up storing w1[n-2], w1[n-1], w2[n-2]... 
	// a2*w(n-2), x(n) or y(n) from previous section + 0, get w[n-1], get b2
		f12=f2*f4, f8=f8+f12, f3=dm(i0, m1) , f4=pm(i8, m8); 

	// a1*w[n-1], x[n]+(a2*w[n-2]), store new w[n-2], get b2
		f12=f3*f4, f8=f8+f12, dm(i1,m1)=f3, f4=pm(i8,m8);

	// b2*w[n-2], new w(n), wget w[n-2] for next section, get b1
		f12=f2*f4, f8=f8+f12, f2=dm(i0, m1), f4=pm(i8,m8);

	//b1*w[n-1], w[n]+(b2*w[n-1]), store new w[n-1], get a2 for next
quads:		f12=f3*f4, f8=f8+f12,  dm(i1,m1)=f8, f4=pm(i8, m8);

rts;


