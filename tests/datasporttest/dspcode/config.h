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

#if defined(BOARD_EZKIT_BF533) || defined(BOARD_EZKIT_BF537)

#define MASTER_CLOCK   27000000
#define SCLK_DIVIDER   4
#define VCO_MULTIPLIER 16
#define CCLK_DIVIDER   1

#elif defined(BOARD_STAMP_BF533)

#define MASTER_CLOCK   11000000
#define SCLK_DIVIDER   4
#define VCO_MULTIPLIER 16
#define CCLK_DIVIDER   1

#elif defined(BOARD_EZKIT_BF561)

#define MASTER_CLOCK   30000000
#define SCLK_DIVIDER   4
#define VCO_MULTIPLIER 12
#define CCLK_DIVIDER   1


#endif

// Blackfin environment memory map

#define L1_DATA_SRAM_A 0xff800000

#define FIFOLENGTH 0x100

#ifndef LO
#define LO(con32) ((con32) & 0xFFFF)
#endif
#ifndef HI
#define HI(con32) (((con32) >> 16) & 0xFFFF)
#endif


