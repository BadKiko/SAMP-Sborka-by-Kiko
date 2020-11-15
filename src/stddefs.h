// this is pretty std stuff
#define snprintf	_snprintf
#define vsnprintf	_vsnprintf
#define isfinite	_finite

// User-defined warnings - MTA
#define __STR2__( x )	#x
#define __STR1__( x )	__STR2__( x )
#define __LOC__			__FILE__ "("__STR1__( __LINE__ ) ") : warning C0000 *La Pirula Project*: "
