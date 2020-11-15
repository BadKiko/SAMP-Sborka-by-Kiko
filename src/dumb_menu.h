struct menu;

#define MENU_SCROLL_SPEED		15	/* auto-scroll speed (scrolls per second) */
#define MENU_SCROLL_DELAY		200 /* delay in milliseconds before auto-scrolling */
#define MENU_INCDEC_SPEED		20	/* auto-scroll speed (scrolls per second) */
#define MENU_INCDEC_DELAY		400 /* delay in milliseconds before auto-scrolling */

#define MENU_SCROLL_TIME		MSEC_TO_TIME( 1000 / MENU_SCROLL_SPEED )
#define MENU_OP_ENABLED			0	/* query if menu item is enabled */
#define MENU_OP_SELECT			1	/* menu item selected notification (enter) */
#define MENU_OP_DEC				2	/* menu item value decrease notification */
#define MENU_OP_INC				3	/* menu item value increase notification */

#define MENU_COLOR_DEFAULT		D3DCOLOR_XRGB( 223, 223, 223 )
#define MENU_COLOR_SEPARATOR	D3DCOLOR_XRGB( 157, 157, 157 )

struct menu_item
{
	struct menu *submenu;
	struct menu *menu;
	const char	*name;
	int			id;
	D3DCOLOR	color;
	void		*data;
};

typedef int ( *menu_callback ) (int op, struct menu_item *);

struct menu
{
	struct menu			*parent;
	int					id;
	int					count;
	int					pos;
	int					top_pos;
	struct menu_item	*item;
	menu_callback		callback;
};

void				menu_run ( void );
void				menu_maybe_init ( void );
void				menu_items_free ( struct menu *menu );
void				menu_free_all ( void );

extern struct menu	*menu_active;

void TriggerPlayerWarpMenu(int ID);