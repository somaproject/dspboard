#define SXSIZE 300 
#define SHSIZE 256
#define SYSIZE 256
#define COXSIZE 1024
#define COHSIZE 256
#define COYSIZE 1024
#define OUTSPIKELEN 300
#define OUTCONTLEN 200	


// definitions for DSP memory regions
#define FPGA_SAMPLES 0x0000
#define FPGA_EVENTWR 0x4000
#define FPGA_EVENTRD 0x6000
#define FPGA_OUTDATA 0x2000
#define FPGA_ACQBOARD 0x8000

.extern SH12; 
.extern SH34; 
.extern COH; 
.extern SY1; 
.extern SY2; 
.extern SY3;
.extern COY; 

.extern TIMESTAMP; 
.extern MYID; 
.extern SAMPLING;

.extern NEWSAMPTMP; 
.extern SPIKELEN;
.extern POSTTRIGLEN; 
.extern NOTRIGGERLEN;
.extern NOTRIGGER;


.extern CURRENTPOS;
.extern SX12; 
.extern SX34; 

.extern SGAIN;
.extern SFID;
.extern SHFID;
.extern STHRESH;
.extern SHLEN; 

.extern CODOWNSAMPLE;
.extern COX;
.extern COGAIN;
.extern COCHAN;
.extern COFID;
.extern COHFID;
.extern COHLEN;
.extern CONTLEN;
.extern CONTCNT;
.extern PENDINGOUTSPIKE;
.extern PENDINGOUTCONT;
.extern CMDID;
.extern CMDIDPENDING;
.extern NEWSTAT;
.extern	LINKSTAT;
.extern CMDPENDING; 
.extern EVENTIN;
.extern EVENTDONE;
.extern EVENTOUT;

.extern OUTSPIKE;
.extern NEWSAMPLES;
.extern INSTATUS; 
.extern OUTCONT; 
	

// functions/subroutines
.extern lock_ppdma;
.extern unlock_ppdma;
