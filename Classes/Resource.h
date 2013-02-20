#import "cocos2d.h"

@interface Resource : NSObject

+(void)init_textures;
+(CCTexture2D*)get_tex:(NSString*)key;
+(CCTexture2D*)get_aa_tex:(NSString*)key;
+(void)dealloc_textures;
+(void)init_menu_textures:(NSArray *)pic_names;
+(void)load_tex_from_array:(NSArray*)temp;

#define TEX_GROUND_TEX_1 @"GroundTexture1"
#define TEX_GROUND_TOP_1 @"GroundTop1"
#define TEX_GROUND_CORNER_TEX_1 @"ground_1_corner"
#define TEX_BRIDGE_EDGE @"BridgeEdge"
#define TEX_BRIDGE_SECTION @"BridgeSection"
#define TEX_TOP_EDGE @"GroundTopEdge"

#define TEX_LAB_ALARM @"labalarm"
#define TEX_LAB_BG @"labbg"
#define TEX_LAB_GROUND_1 @"labground1"
#define TEX_LAB_GROUND_TOP @"labgroundtop"
#define TEX_LAB_GROUND_TOP_EDGE @"labgroundtopedge"
#define TEX_LAB_GROUND_CORNER @"labgroundcorner"
#define TEX_LAB_PIPE_1 @"labpipe1"
#define TEX_LAB_PIPE_2 @"labpipe2"
#define TEX_LAB_ENTRANCE_BACK @"labentranceback"
#define TEX_LAB_ENTRANCE_FORE @"labentrancefore"
#define TEX_LAB_ENTRANCE_CEIL @"labentranceceil"
#define TEX_LAB_ENTRANCE_CEIL_REPEAT @"labentranceceilrepeat"
#define TEX_LAB_WALL @"labwall"

#define TEX_CAVE_TOP_TEX @"CaveTopTex"
#define TEX_CAVE_CORNER_TEX @"CaveCornerTex"
#define TEX_CAVEWALL @"CaveWall"
#define TEX_CAVE_ROCKWALL_BASE @"RockWallBase"
#define TEX_CAVE_ROCKWALL_SECTION @"RockWallSection"
#define TEX_CAVE_ROCKPARTICLE @"RockParticle"
#define TEX_CAVE_SPIKE @"CaveSpike"

#define TEX_DOG_RUN_1 @"dog1ss"
#define TEX_DOG_RUN_2 @"dog2ss"
#define TEX_DOG_RUN_3 @"dog3ss"
#define TEX_DOG_RUN_4 @"dog4ss"
#define TEX_DOG_RUN_5 @"dog5ss"
#define TEX_DOG_RUN_6 @"dog6ss"
#define TEX_DOG_RUN_7 @"dog7ss"
#define TEX_DOG_SPLASH @"splash_ss"
#define TEX_DOG_SHADOW @"dogshadow"

#define TEX_ISLAND_BORDER @"IslandBorder"
#define TEX_CLOUD @"CloudTex"
#define TEX_BG_SKY @"BgSky"
#define TEX_BG_LAYER_1 @"BgLayer1"
#define TEX_BG_LAYER_2 @"BgLayer2"
#define TEX_BG_LAYER_3 @"BgLayer3"
#define TEX_GOLDEN_BONE @"GoldenBone"
#define TEX_STARCOIN @"StarCoin"
#define TEX_DOG_CAPE @"DogCape"
#define TEX_DOG_ROCKET @"DogRocket"
#define TEX_SPIKE @"Spike"
#define TEX_WATER @"Water"
#define TEX_FISH_SS @"fish_ss"
#define TEX_BIRD_SS @"bird_ss"
#define TEX_JUMPPAD @"superjump_ss"
#define TEX_SPEEDUP @"speedup_ss"
#define TEX_STARTBANNER_POLE @"StartBannerPole"
#define TEX_STARTBANNER_BANNER @"StartBannerBanner"
#define TEX_SPIKE_VINE_BOTTOM @"SpikeVineRight"
#define TEX_SPIKE_VINE_SECTION @"SpikeVineSection"

#define TEX_ENEMY_ROBOT @"robot_default"
#define TEX_ENEMY_LAUNCHER @"launcher_default"
#define TEX_ENEMY_ROCKET @"rocket"
#define TEX_ENEMY_COPTER @"copter_default"
#define TEX_ROBOT_PARTICLE @"robot_particle"
#define TEX_EXPLOSION @"explosion_default"
#define TEX_ENEMY_BOMB @"bomb"

#define TEX_SWINGVINE_BASE @"SwingVineBase"
#define TEX_SWINGVINE_TEX @"SwingVineTex"

#define TEX_ELECTRIC_BODY @"electricbody"
#define TEX_ELECTRIC_BASE @"electricbase"

#define TEX_CHECKPOINT_1 @"CheckPointPre"
#define TEX_CHECKPOINT_2 @"CheckPointPost"
#define TEX_CHECKERFLOOR @"CheckerFloor"

#define TEX_GROUND_DETAIL_1 @"GroundDetail1"
#define TEX_GROUND_DETAIL_2 @"GroundDetail2"
#define TEX_GROUND_DETAIL_3 @"GroundDetail3"
#define TEX_GROUND_DETAIL_4 @"GroundDetail4"
#define TEX_GROUND_DETAIL_5 @"GroundDetail5"
#define TEX_GROUND_DETAIL_6 @"GroundDetail6"
#define TEX_GROUND_DETAIL_7 @"GroundDetail7"
#define TEX_GROUND_DETAIL_8 @"GroundDetail8"
#define TEX_GROUND_DETAIL_9 @"GroundDetail9"

#define TEX_GREY_PARTICLE @"GreyParticle"
#define TEX_SMOKE_PARTICLE @"smokeparticle"
#define TEX_CANNONFIRE_PARTICLE @"cannonfire_default"
#define TEX_CANNONTRAIL @"cannontrail_default"

#define TEX_UI_BONE_ICON @"UIBoneIcon"
#define TEX_UI_LIVES_ICON @"UILivesIcon"
#define TEX_UI_TIME_ICON @"UITimeIcon"
#define TEX_UI_ENEMY_ALERT @"UIEnemyAlert"

#define TEX_UI_PAUSEICON @"UIPauseIcon"
#define TEX_UI_PAUSEMENU_RETURN @"PauseMenuReturn"
#define TEX_UI_PAUSEMENU_PLAY @"PauseMenuPlay"
#define TEX_UI_PAUSEMENU_BACK @"PauseMenuBack"
#define TEX_UI_STARTGAME_GO @"UIStartGameGo"
#define TEX_UI_STARTGAME_READY @"UIStartGameReady"

#define TEX_UI_GAMEOVER_TITLE @"UIgameovertitle"
#define TEX_UI_GAMEOVER_INFO @"UIgameoverinfo"
#define TEX_UI_GAMEOVER_LOGO @"UIgameoverlogo"

#define TEX_MENU_TEX_SELECTDOT_SMALL @"menuselectdotsmall"
#define TEX_MENU_TEX_BACKBUTTON @"menubackbutton"
#define TEX_MENU_BG @"menubgimg"
#define TEX_MENU_BUTTON_MENU @"menubuttonmenu"
#define TEX_MENU_BUTTON_PLAYAGAIN @"menubuttonplayagain"
#define TEX_MENU_CURRENT_CHARACTER @"menucurrentcharacter"
#define TEX_MENU_DOG_MODE_TITLE @"menudogmodetitle"
#define TEX_MENU_GRAY_OVERLAY @"menugrayoverlay"
#define TEX_MENU_LOGO @"menulogo"
#define TEX_MENU_PLAYBUTTON @"menuplaybutton"
#define TEX_MENU_SETTINGS_BUTTON @"menusettingsbutton"
#define TEX_MENU_STATS_TITLE @"menustatstitle"
#define TEX_MENU_STATS_BUTTON @"menystatsbutton"
#define TEX_MENU_SETTINGS_TITLE @"menusettingstitle"



@end
