/*
 * this is a terrable hack! in this file we use the C preprocessor
 * to get some version information about the compiler we are using
 * we also identify it to make sure we are actually using the right compiler
 * format is as follows
 * \n
 * compilername\n
 * major\n
 * minor\n
 * patch\n
 *
 * note that this file should never actually be compiled, it should
 * only be preprocessed.
 *
 * note also that the preprocessed file ALWAYS begins with a newline,
 * this is so that compilers such as MSVC that output the filename
 * and have no way to turn that off can be handled.
 */

#ifdef __clang__
clang
__clang_major__
__clang_minor__
__clang_patch__
#elif defined(__INTEL_COMPILER)
icc
__INTEL_COMPILER
#elif defined(__GNUC__)
/* we need to do gcc after clang since clang
 * defined the gcc version macros, screw you clang */
gcc
__GNUC__
__GNUC_MINOR__
__GNUC_PATCHLEVEL__
#elif defined(_MSC_VER)
/* note the slightly different
 * syntax we use here, just one version
 * no reason to deal with splitting it in
 * the preprocessor */
vcc
_MSC_VER
#endif
