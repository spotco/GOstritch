
#import "Resource.h"

@implementation Resource

static NSMutableDictionary* textures = nil;

+(void)init_menu_textures:(NSArray *)pic_names{
    textures = [NSMutableDictionary dictionary];
    NSArray *temp = pic_names;
    [Resource load_tex_from_array:temp];
}

+(void)init_textures {
    textures = [NSMutableDictionary dictionary];
    NSArray *temp = [[NSArray alloc] initWithObjects:
                     @"fg_tex.png", @"level1_island1_tex",
                     @"fg_top.png", @"level1_island1_top",
                     @"dog1runss.png", @"char1_run1_ss",
                     
                     @"bgsky.png",@"bg_sky",
                     @"bg_layer_1.png",@"bg_layer_1",
                     @"bg_layer_2.png",@"bg_layer_2",
                     @"goldenbone.png",@"golden_bone",
                     nil];
    [Resource load_tex_from_array:temp];

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
    for (NSString* key in textures) {
        [[CCTextureCache sharedTextureCache] removeTexture:[textures objectForKey:key]];
    }
    [textures dealloc];
}



@end
