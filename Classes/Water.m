#import "Water.h"
#import "AudioManager.h" 

#define ANIM_SPEED 0.0025
#define OFFSET_V 10
#define FILL_COLOR 18, 64, 100

@implementation Water

+(Water*)cons_x:(float)x y:(float)y width:(float)width height:(float)height {
    Water *w = [Water node];
    w.position = ccp(x,y);
    [w cons_body_ofwidth:width height:height];
    
    return w;
}

-(void)cons_body_ofwidth:(float)width height:(float)height {
    
    bwidth = width;
    bheight = height;
    body = [self cons_drawbody_ofwidth:width];
    offset_ct = 0;
    [self update_body_tex_offset];
    
    active = YES;
    activated = NO;
    
    CCSprite *fillsprite = [CCSprite node];
    fillsprite.anchorPoint = ccp(0,0);
    fillsprite.color = ccc3(FILL_COLOR);
    [fillsprite setTextureRect:CGRectMake(0, 0, bwidth, bheight)];
    [self addChild:fillsprite z:-1];
    
    fishes = [FishGenerator cons_ofwidth:bwidth basehei:bheight];
    [self addChild:fishes z:-2];
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    [super update:player g:g];
    [fishes update];
    [self update_body_tex_offset];
    if(activated) {
        return;
    }
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        [player reset_params];
        activated = YES;
        [player add_effect:[SplashEffect cons_from:[player get_default_params] time:40]];
        [AudioManager playsfx:SFX_SPLASH];
        
    } else if ([player get_current_params].noclip &&
               [player get_current_params].noclip < 2 &&
               [Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect_ignore_noclip]]) {
        activated = YES;
        [player add_effect_suppress_current_end_effect:[SplashEffect cons_from:[player get_default_params] time:40]];
        
    }
    
    return;
}

-(void)reset {
    [super reset];
    activated = NO;
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:self.position.x 
                                y1:self.position.y
                               wid:bwidth 
                               hei:bheight];
}

-(void)update_body_tex_offset {
    body_tex_offset[0] = ccp(body.tex_pts[0].x+offset_ct, body.tex_pts[0].y);
    body_tex_offset[1] = ccp(body.tex_pts[1].x+offset_ct, body.tex_pts[1].y);
    body_tex_offset[2] = ccp(body.tex_pts[2].x+offset_ct, body.tex_pts[2].y);
    body_tex_offset[3] = ccp(body.tex_pts[3].x+offset_ct, body.tex_pts[3].y);
    offset_ct = offset_ct >= 1 ? ANIM_SPEED : offset_ct + ANIM_SPEED;
}

/*0 1
  2 3*/
-(GLRenderObject*)cons_drawbody_ofwidth:(float)width {
    GLRenderObject* o = [Common cons_render_obj:[Resource get_tex:TEX_WATER] npts:4];
    
    int twid = o.texture.pixelsWide;
    int thei = o.texture.pixelsHigh;
    
    o.tri_pts[0] = ccp(0,bheight - thei + OFFSET_V);
    o.tri_pts[1] = ccp(width,bheight -thei + OFFSET_V);
    o.tri_pts[2] = ccp(0,bheight + OFFSET_V);
    o.tri_pts[3] = ccp(width,bheight + OFFSET_V);
    
    o.tex_pts[0] = ccp(0,1);
    o.tex_pts[1] = ccp(o.tri_pts[1].x/twid,1);
    o.tex_pts[2] = ccp(0,0);
    o.tex_pts[3] = ccp(o.tri_pts[3].x/twid,0);
    
    return o;

}

-(void) draw {
    [super draw];
    if (do_render) {
        [self draw_renderobj:body n_vtx:4];
    }
}

-(void)draw_renderobj:(GLRenderObject*)obj n_vtx:(int)n_vtx {
    glBindTexture(GL_TEXTURE_2D, obj.texture.name);
	glVertexPointer(2, GL_FLOAT, 0, obj.tri_pts); 
	glTexCoordPointer(2, GL_FLOAT, 0, body_tex_offset);
    
	glDrawArrays(GL_TRIANGLES, 0, 3);
    if (n_vtx == 4)glDrawArrays(GL_TRIANGLES, 1, 3);
}

-(void)dealloc {
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}



@end
