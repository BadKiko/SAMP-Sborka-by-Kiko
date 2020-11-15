extern TwBar *twBar_MainMenu;
extern TwBar *twBar_NewCheats;
extern TwBar *twBar_AutoPilot;
extern TwBar *twBar_CarOperations;
extern TwBar *twBar_Aimbot;
extern TwBar *twBar_Bots;
extern TwBar *twBar_RakNet;
extern TwBar *twBar_Interface;

void runNewMenu ();
void initializeBarsMenu ();
DWORD WINAPI threadMenuUpdate (PVOID);
void toggleATBCursor (bool bToggle);
