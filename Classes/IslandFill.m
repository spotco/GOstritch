#import "IslandFill.h"

@implementation IslandFill

+(IslandFill*)init_x:(float)x y:(float)y width:(float)width height:(float)height {
    IslandFill* n = [IslandFill node];
    [n initialize_x:x y:y width:width height:height];
    return n;
}

-(CCTexture2D*)get_tex {
    return [Resource get_tex:TEX_GROUND_TEX_1];
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD];
}

@end
