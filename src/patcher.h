#define PATCHER_CHUNKS_MAX	16

struct patch_chunk
{
	uint32_t	len;			/* length of data @ ptr */
	void		*ptr;			/* ptr to data */
	uint8_t		*data_cmp;		/* compare data against this */
	uint8_t		*data_rep;		/* replacement data @ ptr, if NULL NOPs are used */
	uint8_t		*data_orig;		/* original data @ ptr */
	int			is_volatile;
};

struct patch_set
{
	const char			*name;
	int					initialized;
	int					installed;
	struct patch_chunk	chunk[PATCHER_CHUNKS_MAX];
	int					failed; /* set if patcher_installed() failed to initialize; reset on patcher_remove() */
	int					has_volatile;

	/* these don't really belong here... but oh well. */
	int					ini_auto;	/* automatically enable patch; only used by the ini parser */
	int					ini_hotkey; /* hotkey for this patch; only used by the ini parser */
};

char	*dumb_hex_dump ( void *data, uint32_t len );
int		patcher_install ( struct patch_set *set );
int		patcher_remove ( struct patch_set *set );
int		is_patch_installed ( struct patch_set *patch );
void	patcher_free ( struct patch_set *set );
int		GTAPatchIDFinder ( DWORD patchChunk0Ptr );
