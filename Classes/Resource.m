
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
    [textures retain];
    NSArray *temp = [[NSArray alloc] initWithObjects:
                     
                     @"coincount.png", TEX_UI_COINCOUNT,
                     @"pauseicon.png", TEX_UI_PAUSEICON,
                     
                     @"BG1_island_fill.png", TEX_GROUND_TEX_1,
                     @"BG1_top_fill.png", TEX_GROUND_TOP_1,
                     @"BG1_island_top_edge.png", TEX_TOP_EDGE,
                     @"BG1_bridge_edge.png",TEX_BRIDGE_EDGE,
                     @"BG1_bridge_section.png",TEX_BRIDGE_SECTION,
                     
                     @"BG_cave_top_fill.png", TEX_CAVE_TOP_TEX,
                     @"BG_cave_top_edge.png", TEX_CAVE_CORNER_TEX,
                     @"BG_cave_wall.png", TEX_CAVEWALL,
                     @"BG_cave_rock_wall_base.png", TEX_CAVE_ROCKWALL_BASE,
                     @"BG_cave_rock_wall_section.png", TEX_CAVE_ROCKWALL_SECTION,
                     @"BG_cave_rock.png", TEX_CAVE_ROCKPARTICLE,
                     @"BG_cave_spike.png", TEX_CAVE_SPIKE,
                     
                     @"BG1_sky.png", TEX_BG_SKY,
                     @"BG1_layer_1.png", TEX_BG_LAYER_1,
                     @"BG1_layer_2.png", TEX_BG_LAYER_2,
                     @"BG1_layer_3.png", TEX_BG_LAYER_3,
                     @"BG1_island_border.png", TEX_ISLAND_BORDER,
                     @"BG1_cloud.png", TEX_CLOUD,
                     @"water.png", TEX_WATER,
                     @"fish_ss.png", TEX_FISH_SS,
                     @"bird_ss.png", TEX_BIRD_SS,
                     @"superjump_ss.png", TEX_JUMPPAD,
                     @"speedup_ss.png", TEX_SPEEDUP,
                     @"startbanner_pole.png",TEX_STARTBANNER_POLE,
                     @"startbanner_banner.png",TEX_STARTBANNER_BANNER,
                     @"spike_vine_bottom.png", TEX_SPIKE_VINE_BOTTOM,
                     @"spike_vine_section.png", TEX_SPIKE_VINE_SECTION,
                                          
                     @"BG1_detail_1.png", TEX_GROUND_DETAIL_1,
                     @"BG1_detail_2.png", TEX_GROUND_DETAIL_2,
                     @"BG1_detail_3.png", TEX_GROUND_DETAIL_3,
                     @"BG1_detail_4.png", TEX_GROUND_DETAIL_4,
                     @"BG1_detail_5.png", TEX_GROUND_DETAIL_5,
                     @"BG1_detail_6.png", TEX_GROUND_DETAIL_6,
                     @"BG1_detail_7.png", TEX_GROUND_DETAIL_7,                     
                     
                     @"dog1ss.png", TEX_DOG_RUN_1,
                     @"splash_ss.png", TEX_DOG_SPLASH,
                     
                     @"goldenbone.png", TEX_GOLDEN_BONE,
                     @"dogcape.png", TEX_DOG_CAPE,
                     @"dogrocket.png", TEX_DOG_ROCKET,
                     @"spikes.png", TEX_SPIKE,
                     
                     @"checkpoint1.png",TEX_CHECKPOINT_1,
                     @"checkerfloor.png",TEX_CHECKERFLOOR,
                     @"checkpoint2.png",TEX_CHECKPOINT_2,
                     
                     @"grey_particle.png",TEX_GREY_PARTICLE,
                     
                     @"pause_menu_back.png", TEX_UI_PAUSEMENU_BACK,
                     @"pause_menu_play.png", TEX_UI_PAUSEMENU_PLAY,
                     @"pause_menu_return.png", TEX_UI_PAUSEMENU_RETURN,
                     
                     @"GO.png", TEX_UI_STARTGAME_GO,
                     @"READY.png", TEX_UI_STARTGAME_READY,
                     
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

+(CCTexture2D*)get_aa_tex:(NSString*)key {
    CCTexture2D* tex = [Resource get_tex:key];
    [tex setAntiAliasTexParameters];
    return tex;
}

+(void)dealloc_textures {
    [textures removeAllObjects];
    [textures release];
    [[CCTextureCache sharedTextureCache] removeAllTextures];    
}



@end
