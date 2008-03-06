/********************************************************************
 * All config settings for blackfin startup
 *
 */

/* PLL and clock setup values:
 */


// Customize:
// Formulas for clock speeds:
//

// make sure, VCO stays below 600 Mhz
// VCO = VCO_MULTIPLIER * MASTER_CLOCK / MCLK_DIVIDER
//
// where MCLK_DIVIDER = 1 when DF bit = 0,  (default)
//                      2               1
//
// CCLK = VCO / CCLK_DIVIDER
//
// SCLK = VCO / SCLK_DIVIDER
//

#define MASTER_CLOCK   50000000
#define VCO_MULTIPLIER 10
#define CCLK_DIVIDER   1
#define SCLK_DIVIDER   4

// Blackfin environment memory map

#define L1_DATA_SRAM_A 0xff800000

#define FIFOLENGTH 0x100

#ifndef LO
#define LO(con32) ((con32) & 0xFFFF)
#endif
#ifndef HI
#define HI(con32) (((con32) >> 16) & 0xFFFF)
#endif


