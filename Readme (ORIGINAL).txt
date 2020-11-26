SilentPatch 1.1 for GTA SA
Build 29 (4th Anniversary Build)
Last update - 20.05.2018

IMPORTANT NOTE FOR NEW STEAM VERSION USERS:

This ReadMe is prepared for 1.0, 1.01 and 3.0 versions of the game. This version of SilentPatch DOES NOT
PROVIDE THESE FIXES FOR THE NEW STEAM VERSION (7.11 nor 9.12 updates).
When using this ASI, remember to UPGRADE YOUR ASI LOADER TO THE NEWEST VERSION (in the case of my Silent's
ASI Loader, grab a 1.3), as the new Steam EXE renders old ASI loaders UNUSABLE

	"SilentPatch is certifiably awesome."
		- Thomas Williamson, CEO, War Drum Studios

DESCRIPTION

	GTA SA is a great game, but it possesses some issues. This small plugin addresses several of these.
	It focuses mainly on fixing bugs present on PC, but not on PS2 version of the game.

	Fixes featured in this plugin:

	* 14ms frame delay has been removed. As a result, game now locks properly on 30 FPS instead of 25 FPS
	* More precise frame limiter, reducing lag spikes a bit when playing with Frame Limiter on
	* Game timers now tick in a more accurate manner, making them not freeze if framerate exceeds 1000 frames per
	  second; in other words, this fixes occasional freezes on fadeouts if playing with Frame Limiter off
	* Mouse should not lock up randomly when exiting the menu on newer systems anymore
	* Mouse vertical axis sensitivity now matches horizontal axis sensitivity
	* Mouse vertical axis does not lock during camera fadeins now
	* NUM5 is now bindable (like in 1.01)
	* 16:9 resolutions are now selectable (like in 1.01)
	* If the settings file is absent, the game will now default to your desktop resolution instead of 800x600x32
	* DirectPlay dependency has been removed - this should improve compatibility with Windows 8 and newer
	* Path to the GTA San Andreas User Files directory is now obtained differently, increasing compatibility and
	  future-proofing the games more
	* A heap corruption in one place is now fixed (did not affect gameplay but could potentially make the game crash)
	* EAX/NVIDIA splashes are now removed (can be toggled on/off; OFF by default)
	* Subtitle and Radio text sizes can now be toggled between the original release and updated Steam version
	  (defaults to Steam sizes)
	* Area name colour now matches the gang colour of the gang that owns that territory (Los Santos only) (can be
	  toggled on/off; DISABLED by default)
	* Wet road reflections render properly again (just like with Road Reflections Fix)
	* Fixed sun lens flare effect not appearing with AMD/Intel graphics cards
	* Fixed an issue introducing graphical artifacts from ped animations with high RAM usage - so called "streaming
	  memory bug"
	* Fixed a bug causing cheat-spawned melee weapons to be forcibly replaced by other melee weapons upon walking into
	  a pickup
	* Helicopter rotors and plane propellers now work correctly. They now have a blurring effect present in VC and PS2
	  version of SA. This fix can be disabled separately for each vehicle via the INI file
	* Hunter interior does not dissapear when viewed through the glass door panel
	* Dual rear wheels now show up properly (Yosemite, Tanker etc.). This fix can be disabled or forcibly enabled
	  separately for each vehicle via the INI file
	* Weapons are now visible when viewed through a vehicle window
	* Holding a weapon will not cause some objects to be incorrectly lit anymore
	* Blown up vehicles are now correctly coloured and no longer shine (like in 1.01 and Steam versions)
	* Dirty cars are now able to get clean (like in 1.01)
	* Each car has an unique numberplate now
	* Custom numberplates now show up correctly in all cases
	* Custom numberplates are now also allowed on bikes
	* Numberplates are now bilinear filtered, resulting in a smoother look
	* Vehicle lights do not get dark after being being initially lit anymore (like on PS2)
	* Detached vehicle parts will now remain the same colour as the vehicle they came from
	* Detached vehicle parts now render from both sides
	* Some car panels now swing after car's explosion (like they were meant to be but the code forcibly fixed them
	  immediately after damaging)
	* Moonphases now show up correctly, like on PS2 version (only when playing in 32-bit colour mode)
	* Toggling car lights on does not make windows invisible when viewed from inside anymore
	* Illumination value from timecyc.dat now accepts any float value in 0.0-2.0 ranges, not just 0.0, 1.0 and 2.0
	* In addition, if illumination value is absent from the timecycle (like on a stock PC timecycle), the game will
	  now default to 1.0
	* Lights now get casted on vehicles and peds properly - previously, they'd dissapear under some conditions
	* In addition, when playing on Visual FX Quality higher than low, the game will now cast up to 6 lights on each
	  model both indoors and outdoors (on Low details, game's stock behaviour has been kept - allowing up to 4 lights
	  per model outdoors and 6 indoors)
	* Muzzle flash looks better now
	* Muzzle flash will now show up when firing the last bullet from the clip
	* Coronas' don't have a Z test forced all the time now - as a result, sunglare now matches original PS2 version
	* With User Tracks automatic scan enabled, MP3 playback will now work properly if QuickTime is not installed
	* User Tracks now supports the FLAC codec (Only 8/16/24bits, Mono/Stereo and up to 48Khz)
	* PCM WAVE has been expanded to also accept additional profiles (Now 8/16/24bits, Mono/Stereo and up to 48Khz)
	* PCM WAVE files with an ID3-TAG will now also work with the game
	* Temple and Queens are now correctly called on the police scanner
	* Travelling far away from the map will no longer trigger the extra gang territories glitch, nor will it corrupt
	  the Taxi Driver submission
	* Gym glitch ("You have worked out enough..." showing infinitely) has been fixed (can be toggled on/off; ENABLED
	  by default)
	* Saving in Madd Dogg's mansion will no longer trigger the missing basketball glitch (can be toggled on/off;
	  ENABLED by default)
	* Fixed an occasional softlock in Mountain Cloud Boys - the player will not freeze after arriving to the meeting
	  anymore (can be toggled on/off; ENABLED by default)
	* Possible softlock in Sweet's Girl initial cutscene fixed (can be toggled on/off; ENABLED by default)
	* Quadruple Stunt Bonus now works correctly (can be toggled on/off; ENABLED by default)
	* Script sprites now have bilinear filtering applied
	* Car generator counters now work properly for generators with fixed amount of spawns
	* Impound garages now function correctly, allowing the player to recover his last vehicle after it had vanished
	  after a mission start
	* In addition, impound garages will now store player's car when he's busted
	* Streamed entity list has been expanded a bit, so now the game world shouldn't flash when looking down with high
	  Draw Distance settings anymore
	* Mouse rotates an airborne car only with Steer with Mouse option enabled
	* Towtruck tow hitch does not get bugged after it has been fixed anymore
	* Plane doors don't corrupt after the plane has been fixed anymore
	* Fixing a plane will now reset its moving props to an undamaged state
	* Several vehicle components (most notably, Rumpo's front bumper and Bandito's moving prop) will not get glitched
	  after the vehicle has been fixed anymore
	* Weapons and a jetpack now cast proper shadows
	* Crosshair doesn't mess up weapon icon when on a jetpack anymore
	* Free resprays will not carry on a New Game now
	* Fixed ambulance and firetruck dispatch timers - they reset on New Game now
	* Previously present only on PS2, 'Cars drive on water' cheat is now toggleable - its string is SEAROADER
	* Randomizer error causing peds not to spawn in some areas has been fixed
	* Randomizer error causing prostitutes to be quiet during solicit has been fixed
	* Text boxes now can show together with a Mission Passed text
	* Fixed a 1.01 only tiny memory leak which occured every time the player switched a radio station
	* Fixed an occasional crash when Alt+Tabbing back to the game while standing next to a mirror
	* Mirror reflection doesn't break with Anti-Aliasing enabled anymore
	* With Visual FX Quality set to Very High, mirror reflection quality has been bumped
	* Anti-Aliasing option has been altered - instead of listing 1, 2, 3 options (which in fact are 2x/2x/4x MSAA),
	  the game will now show proper MSAA values from 2x up to 16x (depending on max MSAA level supported by the
	  graphics card)
	* Colliding with another car will now damage proper parts on both cars - previously, both cars got damaged the
	  same way
	* Fixed a crash on car explosions - most likely to happen when playing with a multimonitor setup
	* Fixed a crash when entering advanced display options on a dual monitor machine after: starting game on primary
	  monitor in maximum resolution, exiting, starting again in maximum resolution on secondary monitor. Secondary
	  monitor maximum resolution had to be greater than maximum resolution of primary monitor.
	* Fixed an occasional crash occuring when standing next to escalators
	* Slightly reduced stencil shadows memory overhead
	* Fixed an AI issue where enemies became too accurate after the player has been in the car earlier
	* IMGs bigger than 4GB are now handled properly
	* Alt+F4 now works properly
	* Several vehicles now have extra animated components: Phoenix hood scoops, Sweeper brushes, Newsvan antenna,
	  radars on several boats, extra flaps on Stuntplane and Beagle
	* Animated engine components on Bandito, BF Injection and Hotknife will not animate if the engine is off
	* Fixed a crash occuring when the vending machine was continuously used for an extended period of time
	* FILE_FLAG_NO_BUFFERING flag has been removed from IMG reading functions - speeding up streaming
	* Fixed a streaming related deadlock, which could occasionally result in game being stuck on black screen when
	  entering or exiting interiors (this is the issue people used to fix by setting CPU affinity to one core)
	* Metric-to-imperial conversion constants have been replaced with more accurate ones
	* Fixed a glitch where random cars would end up being impounded to garage, replacing player's vehicles
	* Very long loading times will now loop loading screens, as opposed to fading to white
	* Sun reflections on peds and vehicles now change direction depending on time of day, like in III and VC (can be
	  toggled on/off; DISABLED by default)
	* Dancing minigame timings have been improved, now they do not lose accuracy over time depending on PC's uptime
	* Car generators placed in interiors are now placed correctly - this 'unhides' two vehicles in Madd Dogg's
	  mansion, which were always there but they were not visible
	* Bombs in cars stored in garages now save properly
	* Fixed an issue which would cause games to freeze if III/VC/SA were running at the same time
	* Streaming has been greatly improved during Supply Lines mission (or more general, any time when using an RC
	  vehicle) - it now behaves as expected, as opposed to displaying LODs way too quickly
	* Health triangle displaying when aiming at peds is now properly orientated (it's now upside down) for peds player
	  can recruit
	* Setting a BMX on fire will not set CJ on fire anymore
	* Keyboard input latency decreased by one frame
	* Steam version has proper aspect ratios now
	* IMG size checks have been removed from the Steam version
	* Steam version of the game will not reject 1.0/1.01 saves anymore (still, a compatible SCM is needed for the save
	  to work)


INSTALLATION

	As SA doesn't load ASI files by default, you'll need an ASI loader. In case you don't have one (if you
	use any ASI plugin such as CLEO, you can skip this step), you can download an ASI loader created by
	myself from the following link:
	http://www.gtagarage.com/mods/show.php?id=21709

	Rest of the installation is easy as pie. Just extract the archive contents to your SA directory
	and that's all. Make sure you check the INI!

	Alternatively, San Andreas Mod Loader can be used to install this plugin (by the time this mod was created, Mod Loader supports 1.0 ONLY):
	http://gtaforums.com/topic/669520-sarel-mod-loader/


SUPPORTED GAME VERSIONS

	* GTA SA 1.0 (all versions)
	* GTA SA newsteam r2 (9 Dec 2014; partially, see above)


CREDITS

	DK22Pac - 'dark lights' fix, coloured detached components fix, mirrors multisampling fix,
			   help with shaders, technical support
	NTAuthority - moonphases code, DirectPlay dependency removal code, technical support
	aap (The Hero) - PS2 style two-pass, NVC shader bugfixing


SPECIAL THANKS

	People who helped to identify issues, tested the patch or were generally supportive:

	aap
	Ash_735
	Blackbird88
	gamerzworld
	iFarbod
	Inadequate
	LonesomeRider
	mirh
	Nick007J
	Reyks
	spaceeinstein
	Tomasak


CONTACT

	zdanio95@gmail.com - e-mail
	Silent#1222 - Discord

Subscribe to my YouTube channel for more footage from my mods!
https://www.youtube.com/user/CookiePLMonster

Follow my Twitter account to be up to all my mods updates!
http://twitter.com/__silent_