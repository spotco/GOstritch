#import "cocos2d.h"

@interface Resource : NSObject

+(void)init_bg1_textures;
+(void)init_bgtest_textures;
+(CCTexture2D*)get_tex:(NSString*)key;
+(void)dealloc_textures;
+(void)init_menu_textures;
+(void)load_tex_from_array:(NSArray*)temp;

#define TEX_GROUND_TEX_1 @"GroundTexture1"
#define TEX_GROUND_TOP_1 @"GroundTop1"
#define TEX_DOG_RUN_1 @"Dog1RunSSheet"
#define TEX_BG_SKY @"BgSky"
#define TEX_BG_LAYER_1 @"BgLayer1"
#define TEX_BG_LAYER_2 @"BgLayer2"
#define TEX_GOLDEN_BONE @"GoldenBone"

#define TEX_GROUND_DETAIL_1 @"GroundDetail1"
#define TEX_GROUND_DETAIL_2 @"GroundDetail2"
#define TEX_GROUND_DETAIL_3 @"GroundDetail3"

@end
