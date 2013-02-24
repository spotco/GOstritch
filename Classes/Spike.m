#import "Spike.h"
#import "Island.h"
#import "GameEngineLayer.h"

@implementation Spike

+(Spike*)init_x:(float)posx y:(float)posy islands:(NSMutableArray*)islands {
    Spike *s = [Spike node];
    s.position = ccp(posx,posy);
    s.active = YES;
    
    CCTexture2D *tex = [Resource get_tex:TEX_SPIKE];
    s.img = [CCSprite spriteWithTexture:tex];
    
    s.img.position = ccp(0,0);
    
    [s attach_toisland:islands];
    [s addChild:s.img];
    return s;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND];
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-10 y1:[self position].y-10 wid:20 hei:20];
}

-(void)set_active:(BOOL)t_active {
    active = t_active;
}

-(void)update:(Player*)player g:(GameEngineLayer *)g {
    [super update:player g:g];
    if(activated) {
        return;
    }
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        [player reset_params];
        player.current_swingvine = NULL;
        activated = YES;
        [player add_effect:[HitEffect cons_from:[player get_default_params] time:40]];
        [DazedParticle cons_effect:g tar:player time:40];
        [AudioManager playsfx:SFX_HIT];
        
        //[DazedParticle init_effect:g x:player.position.x y:player.position.y+60*(player.current_island != NULL?player.last_ndir:1) time:40];
    }
    
    return;
}

-(void)reset {
    [super reset];
    activated = NO;
}

-(void)attach_toisland:(NSMutableArray*)islands {
    Island* i = [self get_connecting_island:islands];
    if (i != NULL) {
        Vec3D *tangent_vec = [i get_tangent_vec];
        [tangent_vec scale:[i ndir]];
        float tar_rad = -[tangent_vec get_angle_in_rad];
        float tar_deg = [Common rad_to_deg:tar_rad];
        img.rotation = tar_deg;
        
        [tangent_vec normalize];
        Vec3D *normal_vec = [[Vec3D Z_VEC] crossWith:tangent_vec];
        [normal_vec scale:15];
        img.position = ccp(normal_vec.x,normal_vec.y);
        
        [tangent_vec dealloc];
        [normal_vec dealloc];
    }
}

@end
