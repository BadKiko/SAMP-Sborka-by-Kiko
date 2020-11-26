@ECHO OFF
@COLOR 02
@TITLE Installing GTA NO-INTRO FIX...
@IF EXIST "movies\GTAtitles_res.mpg" GOTO FIXINSTALLED
@IF EXIST "movies\Logo_res.mpg" GOTO FIXINSTALLED
@IF NOT EXIST "movies_new" GOTO ERROR0
@IF NOT EXIST "movies_new\GTAtitles.mpg" GOTO ERROR1
@IF NOT EXIST "movies_new\Logo.mpg" GOTO ERROR2
@IF NOT EXIST "movies" GOTO ERROR3
@IF NOT EXIST "movies\GTAtitles.mpg" GOTO ERROR4
@IF NOT EXIST "movies\Logo.mpg" GOTO ERROR5
@RENAME "movies\GTAtitles.mpg"	"GTAtitles_res.mpg"
@RENAME "movies\Logo.mpg"	"Logo_res.mpg"
@XCOPY "movies_new\*.*" 	"movies\*.*" /S /Y
@DEL "movies_new\GTAtitles.mpg"  /Q
@DEL "movies_new\Logo.mpg"  /Q
@RD "movies_new"
@MSG * GTA NO-INTRO FIX installed.
@DEL "Install_NIF.bat" /Q
@EXIT
:ERROR0
@CLS
@COLOR 04
@ECHO -
@ECHO ------- Folder movies_new not found! -------
@ECHO -
@PAUSE
@EXIT
:ERROR1
@CLS
@COLOR 04
@ECHO -
@ECHO ------- File movies_new\GTAtitles.mpg not found! -------
@ECHO -
@PAUSE
@EXIT
:ERROR2
@CLS
@COLOR 04
@ECHO -
@ECHO ------- File movies_new\Logo.mpg not found! -------
@ECHO -
@PAUSE
@EXIT
:ERROR3
@CLS
@COLOR 04
@ECHO -
@ECHO ------- Folder movies not found! -------
@ECHO -
@PAUSE
@EXIT
:ERROR4
@CLS
@COLOR 04
@ECHO -
@ECHO ------- File movies\GTAtitles.mpg not found! -------
@ECHO -
@PAUSE
@EXIT
:ERROR5
@CLS
@COLOR 04
@ECHO -
@ECHO ------- File movies\Logo.mpg not found! -------
@ECHO -
@PAUSE
@EXIT
:FIXINSTALLED
@CLS
@COLOR 02
@ECHO -
@ECHO ------- GTA NO-INTRO FIX already installed! -------
@ECHO -
@PAUSE