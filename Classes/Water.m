#import "Water.h"

#define ANIM_SPEED 0.0025
#define OFFSET_V 10
#define FILL_COLOR 18, 64, 100

@implementation Water

+(Water*)init_x:(float)x y:(float)y width:(float)width height:(float)height {
    Water *w = [Water node];
    w.position = ccp(x,y);
    [w init_body_ofwidth:width height:height];
    
    return w;
}

-(void)init_body_ofwidth:(float)width height:(float)height {
    
    bwidth = width;
    bheight = height;
    body = [self init_drawbody_ofwidth:width];
    
    body_tex_offset = (CGPoint*) malloc(sizeof(CGPoint)*4);
    offset_ct = 0;
    [self update_body_tex_offset];
    
    active = YES;
    
    CCSprite *fillsprite = [CCSprite node];
    fillsprite.anchorPoint = ccp(0,0);
    fillsprite.color = ccc3(FILL_COLOR);
    [fillsprite setTextureRect:CGRectMake(0, 0, bwidth, bheight)];
    [self addChild:fillsprite z:-1];
    
    fishes = [FishGenerator init_ofwidth:bwidth basehei:bheight];
    [self addChild:fishes z:-2];
}

-(GameObjectReturnCode)update:(Player *)player g:(GameEngineLayer *)g {
    [fishes update];
    [self update_body_tex_offset];
    if(!active) {
        return GameObjectReturnCode_NONE;
    }
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        [player reset_params];
        [self setActive:NO];
        [player add_effect:[SplashEffect init_from:[player get_default_params] time:40]];
    }
    
    return GameObjectReturnCode_NONE;
}

-(void)set_active:(BOOL)t_active {
    active = t_active;
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
-(gl_render_obj)init_drawbody_ofwidth:(float)width {
    gl_render_obj o = [Common init_render_obj:[Resource get_tex:TEX_WATER] npts:4];
    
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
    [self draw_renderobj:body n_vtx:4];
}

-(void)draw_renderobj:(gl_render_obj)obj n_vtx:(int)n_vtx {
    glBindTexture(GL_TEXTURE_2D, obj.texture.name);
	glVertexPointer(2, GL_FLOAT, 0, obj.tri_pts); 
	glTexCoordPointer(2, GL_FLOAT, 0, body_tex_offset);
    
	glDrawArrays(GL_TRIANGLES, 0, 3);
    if (n_vtx == 4)glDrawArrays(GL_TRIANGLES, 1, 3);
}

-(void)dealloc {
    free(body.tex_pts);
    free(body.tri_pts);
    free(body_tex_offset);
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}



@end
