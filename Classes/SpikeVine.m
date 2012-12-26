#import "SpikeVine.h"

@implementation SpikeVine

#define BASE_IMG_WID 34.0
#define BASE_IMG_HEI 27.0
#define CENTER_IMG_WID 56.0
#define CENTER_IMG_HEI 128.0

+(SpikeVine*)init_x:(float)x y:(float)y x2:(float)x2 y2:(float)y2 {
    SpikeVine *n = [SpikeVine node];
    [n cons_x:x y:y x2:x2 y2:y2];
    return n;
}

-(void)cons_x:(float)x y:(float)y x2:(float)x2 y2:(float)y2 {
    [self setPosition:ccp(x,y)];
    dir_vec = [Vec3D init_x:x2-x y:y2-y z:0];
    [self cons_img];
    [self setActive:YES];
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    [super update:player g:g];
    if(!active) {
        return;
    }
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        HitRect player_small_rect = [player get_hit_rect]; //watahack :DDD
        float pwid = player_small_rect.x2-player_small_rect.x1;
        float phei = player_small_rect.y2-player_small_rect.y1;
        player_small_rect.x1+=pwid*0.25;
        player_small_rect.x2-=pwid*0.25;
        player_small_rect.y1+=phei*0.25;
        player_small_rect.y2-=phei*0.25;
        
        SATPoly r_playerhit = [PolyLib hitrect_to_poly:player_small_rect];
        for(int i = 0; i < r_hitbox.length; i++) {
            r_hitbox.pts[i].x += position_.x;
            r_hitbox.pts[i].y += position_.y;
        }
        if ([PolyLib poly_intersect_SAT:r_hitbox b:r_playerhit]) {
            [self hit:player g:g];
        }
        for(int i = 0; i < r_hitbox.length; i++) {
            r_hitbox.pts[i].x -= position_.x;
            r_hitbox.pts[i].y -= position_.y;
        }
    }
    
    return;
}

-(void)hit:(Player *)player g:(GameEngineLayer *)g {
    [player reset_params];
    [self setActive:NO];
    [player add_effect:[HitEffect init_from:[player get_default_params] time:40]];
    [DazedParticle init_effect:g x:player.position.x y:player.position.y+60*(player.current_island != NULL?player.last_ndir:1) time:40];
}

-(CCTexture2D*)get_base_tex {
    return [Resource get_tex:TEX_SPIKE_VINE_BOTTOM];
}

-(CCTexture2D*)get_section_tex {
    return [Resource get_tex:TEX_SPIKE_VINE_SECTION];
}

-(CGSize)get_base_size {
    return CGSizeMake(BASE_IMG_WID, BASE_IMG_HEI);
}

-(CGSize)get_section_size {
    return CGSizeMake(CENTER_IMG_WID, CENTER_IMG_HEI);
}

-(void)cons_img {
    CCTexture2D* tex = [self get_base_tex];
    CGSize s = [self get_base_size];
    float bwid = [tex pixelsWide]; 
    float bhei = [tex pixelsHigh];
    
    Vec3D *normal = [dir_vec crossWith:[Vec3D Z_VEC]];
    [normal normalize];
    [normal scale:s.width/2];
    
    Vec3D *r_dirv = [Vec3D init_x:dir_vec.x y:dir_vec.y z:0];
    [r_dirv normalize];
    [r_dirv scale:-s.height];
    /**        
     (0)   (origin)    (1)  --> normal
     |  r_dirv
     (2)      \ /      (3)
     
     gl rounds texture to nearest 2^n size, use img size constants to properly size
     **/
    
    bottom = [Common init_render_obj:tex npts:4];
    
    bottom.tri_pts[0] = ccp(-normal.x            ,-normal.y);
    bottom.tri_pts[1] = ccp(normal.x             ,normal.y);
    bottom.tri_pts[2] = ccp(-normal.x + r_dirv.x , -normal.y + r_dirv.y);
    bottom.tri_pts[3] = ccp(normal.x + r_dirv.x  ,normal.y + r_dirv.y);
    
    bottom.tex_pts[0] = ccp(0,0);
    bottom.tex_pts[1] = ccp(s.width/bwid,0);
    bottom.tex_pts[2] = ccp(0,s.height/bhei);
    bottom.tex_pts[3] = ccp(s.width/bwid,s.height/bhei);
    
    top = [Common init_render_obj:tex npts:4];
    top.tri_pts[0] = ccp(-normal.x + dir_vec.x - r_dirv.x              , -normal.y + dir_vec.y - r_dirv.y );
    top.tri_pts[1] = ccp(normal.x  + dir_vec.x - r_dirv.x             , normal.y + dir_vec.y - r_dirv.y);
    top.tri_pts[2] = ccp(-normal.x  + dir_vec.x   ,  -normal.y  + dir_vec.y);
    top.tri_pts[3] = ccp(normal.x  + dir_vec.x    , normal.y  + dir_vec.y);
    
    top.tex_pts[2] = ccp(0,0);
    top.tex_pts[3] = ccp(s.width/bwid,0);
    top.tex_pts[0] = ccp(0,s.height/bhei);
    top.tex_pts[1] = ccp(s.width/bwid,s.height/bhei);
    
    
    tex = [self get_section_tex];
    s = [self get_section_size];
    bwid = [tex pixelsWide];
    bhei = [tex pixelsHigh];
    [normal normalize];
    [normal scale:bwid/2];
    
    center = [Common init_render_obj:tex npts:4];
    
    center.tri_pts[0] = ccp(-normal.x            ,-normal.y);
    center.tri_pts[1] = ccp(normal.x             ,normal.y);
    center.tri_pts[2] = ccp(-normal.x + dir_vec.x , -normal.y + dir_vec.y);
    center.tri_pts[3] = ccp(normal.x + dir_vec.x  ,normal.y + dir_vec.y);
    
    float len = [dir_vec length];
    
    center.tex_pts[0] = ccp(0,0);
    center.tex_pts[1] = ccp(s.width/bwid,0);
    center.tex_pts[2] = ccp(0, (len/s.height) * s.height/bhei);
    center.tex_pts[3] = ccp(s.width/bwid,  (len/s.height) * s.height/bhei);
    
    
    r_hitbox = [PolyLib cons_SATPoly_quad:ccp(center.tri_pts[0].x, center.tri_pts[0].y)
                                        b:ccp(center.tri_pts[1].x, center.tri_pts[1].y)
                                        c:ccp(center.tri_pts[3].x, center.tri_pts[3].y)
                                        d:ccp(center.tri_pts[2].x, center.tri_pts[2].y)];
    
    [normal dealloc];
    [r_dirv dealloc];
}

-(void)set_active:(BOOL)t_active {
    active = t_active;
}


-(void)draw {
    [super draw];
    //glColor4ub(0,255,0,100);
    //ccDrawLine(ccp(0,0), ccp(dir_vec.x,dir_vec.y));
    [self draw_o];
}

-(void)draw_o {
    [Common draw_renderobj:top n_vtx:4];
    [Common draw_renderobj:bottom n_vtx:4];
    [Common draw_renderobj:center n_vtx:4];
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND];
}


-(HitRect)get_hit_rect {
    float x_max = -INFINITY;
    float x_min = INFINITY;
    float y_max = -INFINITY;
    float y_min = INFINITY;
    
    CGPoint *l = top.tri_pts;
    for (int i = 0; i < 4; i++) {
        x_min = MIN(x_min,l[i].x);
        x_max = MAX(x_max,l[i].x);
        y_min = MIN(y_min,l[i].y);
        y_max = MAX(y_max,l[i].y);
    }
    
    l = bottom.tri_pts;
    for (int i = 0; i < 4; i++) {
        x_min = MIN(x_min,l[i].x);
        x_max = MAX(x_max,l[i].x);
        y_min = MIN(y_min,l[i].y);
        y_max = MAX(y_max,l[i].y);
    }
    
    return [Common hitrect_cons_x1:x_min+position_.x y1:y_min+position_.y x2:x_max+position_.x y2:y_max+position_.y];
}

-(void)dealloc {
    [super dealloc];
    [dir_vec dealloc];
}

@end
