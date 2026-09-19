/* bitstreams.h
 *
 * Just includes the three generated bitstream arrays.
 * No struct, no table -- the arrays are used directly by name.
 *
 * Generate the three files below with bin_to_carray_simple.py first.
 */

#ifndef BITSTREAMS_H
#define BITSTREAMS_H

#include "sigf_bitstream.h"   /* sigf_bin[], SIGF_BIN_SIZE  -- Sig5  */
#include "sige_bitstream.h"   /* sige_bin[], SIGE_BIN_SIZE  -- Sig8  */
#include "sigt_bitstream.h"   /* sigt_bin[], SIGT_BIN_SIZE  -- Sig10 */

#endif