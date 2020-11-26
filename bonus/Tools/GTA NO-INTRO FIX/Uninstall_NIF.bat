@ECHO OFF
@COLOR 02
@TITLE Uninstalling GTA NO-INTRO FIX...
@IF NOT EXIST "movies" GOTO ERROR0
@IF NOT EXIST "movies\GTAtitles_res.mpg" GOTO ERROR1
@IF NOT EXIST "movies\Logo_res.mpg" GOTO ERROR2
@IF NOT EXIST "movies\GTAtitles.mpg" GOTO ERROR3
@IF NOT EXIST "movies\Logo.mpg" GOTO ERROR4
@DEL "movies\GTAtitles.mpg" /Q
@DEL "movies\Logo.mpg" /Q
@RENAME "movies\GTAtitles_res.mpg"	"GTAtitles.mpg"
@RENAME "movies\Logo_res.mpg"		"Logo.mpg"
@MSG * GTA NO-INTRO FIX removed.
@DEL "Uninstall_NIF.bat" /Q
@EXIT
:ERROR0
@CLS
@COLOR 04
@ECHO -
@ECHO ------- Folder movies not found! -------
@ECHO -
@PAUSE
@EXIT
:ERROR1
@CLS
@COLOR 04
@ECHO -
@ECHO ------- File movies\GTAtitles_res.mpg not found! -------
@ECHO -
@PAUSE
@EXIT
:ERROR2
@CLS
@COLOR 04
@ECHO -
@ECHO ------- File movies\Logo_res.mpg not found! -------
@ECHO -
@PAUSE
@EXIT
:ERROR3
@CLS
@COLOR 04
@ECHO -
@ECHO ------- File movies\GTAtitles.mpg not found! -------
@ECHO -
@PAUSE
@EXIT
:ERROR4
@CLS
@COLOR 04
@ECHO -
@ECHO ------- File movies\Logo.mpg not found! -------
@ECHO -
@PAUSE