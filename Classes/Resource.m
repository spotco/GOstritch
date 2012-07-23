
#import "Resource.h"

@implementation Resource



static NSMutableDictionary* textures = nil;

+(void)init_menu_textures:(NSArray *)pic_names{
    textures = [NSMutableDictionary dictionary];
    NSArray *temp = pic_names;
    [Resource load_tex_from_array:temp];
}

+(void)init_bg1_textures {
    textures = [NSMutableDictionary dictionary];
    NSArray *temp = [[NSArray alloc] initWithObjects:
                     
                     @"coincount.png", TEX_UI_COINCOUNT,
                     @"pauseicon.png", TEX_UI_PAUSEICON,
                     @"pausescreen.png", TEX_UI_PAUSEMENU,
                     
                     @"BG1_island_fill.png", TEX_GROUND_TEX_1,
                     @"BG1_top_fill.png", TEX_GROUND_TOP_1,
                     @"BG1_island_top_edge.png", TEX_TOP_EDGE,
                     
                     @"BG1_sky.png", TEX_BG_SKY,
                     @"BG1_layer_1.png", TEX_BG_LAYER_1,
                     @"BG1_layer_2.png", TEX_BG_LAYER_2,
                     @"BG1_layer_3.png", TEX_BG_LAYER_3,
                     @"BG1_island_border.png", TEX_ISLAND_BORDER,
                     @"BG1_cloud.png", TEX_CLOUD,
                                          
                     @"BG1_detail_1.png", TEX_GROUND_DETAIL_1,
                     @"BG1_detail_2.png", TEX_GROUND_DETAIL_2,
                     @"BG1_detail_3.png", TEX_GROUND_DETAIL_3,
                     
                     @"dog1ss.png", TEX_DOG_RUN_1,
                     @"goldenbone.png", TEX_GOLDEN_BONE,
                     @"dogcape.png", TEX_DOG_CAPE,
                     @"dogrocket.png", TEX_DOG_ROCKET,
                     @"spikes.png", TEX_SPIKE,
                     
                     @"checkpoint1.png",TEX_CHECKPOINT_1,
                     @"checkerfloor.png",TEX_CHECKERFLOOR,
                     @"checkpoint2.png",TEX_CHECKPOINT_2,
                     
                     nil];
    [Resource load_tex_from_array:temp];
    [temp dealloc];
}

+(void)load_tex_from_array:(NSArray*)temp {
    ccTexParams texParams = { GL_NEAREST, GL_NEAREST, GL_REPEAT, GL_REPEAT };
    for(int i = 0; i < [temp count]-1; i+=2) {
        NSLog(@"LOADING: %@->%@\n",[temp objectAtIndex:i], [temp objectAtIndex:(i+1)]);
        CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage:[temp objectAtIndex:i]];
        [textures setObject:tex forKey:[temp objectAtIndex:(i+1)]];
        [tex setTexParameters: &texParams];
    }
}

+(CCTexture2D*)get_tex:(NSString*)key {
    CCTexture2D* ret = [textures objectForKey:key];
    if (!ret) {
        NSLog(@"Failed to get texture %@",key);
    }
    return ret;
}

+(void)dealloc_textures {
    for (NSString* key in [textures keyEnumerator]) {
        [[CCTextureCache sharedTextureCache] removeTexture:[textures objectForKey:key]];
    }
    [textures dealloc];
}



@end
