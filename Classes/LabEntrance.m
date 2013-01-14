#import "LabEntrance.h"
#import "GameEngineLayer.h"

static const float ENTR_HEI = 3000;

@implementation LabEntranceFG

+(LabEntranceFG*)cons_pt:(CGPoint)pt base:(LabEntrance*)base {
    return [[LabEntranceFG node] init_pt:pt base:base];
}
-(id)init_pt:(CGPoint)pt base:(LabEntrance*)tbase {
    [self setPosition:pt];
    base = tbase;
    front_body = [Common init_render_obj:[Resource get_tex:TEX_LAB_ENTRANCE_FORE] npts:4];
    //23
    //01
    
    float tex_wid = front_body.texture.pixelsWide;
    float hei = ENTR_HEI;
    
    front_body.tri_pts[0] = ccp(-tex_wid/2,0);
    front_body.tri_pts[1] = ccp(tex_wid/2,0);
    front_body.tri_pts[2] = ccp(-tex_wid/2,hei);
    front_body.tri_pts[3] = ccp(tex_wid/2,hei);
    
    front_body.tex_pts[2] = ccp(0,0);
    front_body.tex_pts[3] = ccp(1,0);
    front_body.tex_pts[0] = ccp(0,hei/front_body.texture.pixelsHigh);
    front_body.tex_pts[1] = ccp(1,hei/front_body.texture.pixelsHigh);
    return self;
}
-(void)check_should_render:(GameEngineLayer *)g {
    do_render = [base get_do_render];
}
-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_ABOVE_FG_ORD];
}
-(void)draw {
    [super draw];
    [Common draw_renderobj:front_body n_vtx:4];
}
@end

@implementation LabEntrance

+(LabEntrance*)cons_pt:(CGPoint)pt {
    return [[LabEntrance node] init_pt:pt];
}

-(id)init_pt:(CGPoint)pt {
    active = YES;
    [self setPosition:pt];
    back_body = [Common init_render_obj:[Resource get_tex:TEX_LAB_ENTRANCE_BACK] npts:4];
    //23
    //01 then flip horiz
    
    float tex_wid = back_body.texture.pixelsWide;
    float hei = ENTR_HEI;
    
    back_body.tri_pts[0] = ccp(-tex_wid/2,0);
    back_body.tri_pts[1] = ccp(tex_wid/2,0);
    back_body.tri_pts[2] = ccp(-tex_wid/2,hei);
    back_body.tri_pts[3] = ccp(tex_wid/2,hei);
    
    back_body.tex_pts[2] = ccp(0,0);
    back_body.tex_pts[3] = ccp(1,0);
    back_body.tex_pts[0] = ccp(0,hei/back_body.texture.pixelsHigh);
    back_body.tex_pts[1] = ccp(1,hei/back_body.texture.pixelsHigh);

    
    ceil_edge = [Common init_render_obj:[Resource get_tex:TEX_LAB_ENTRANCE_CEIL] npts:4];
    
    float ceil_hei = 50;
    float ceil_leftoffset = -40;
    float ceil_wid = ceil_edge.texture.pixelsWide;
    float ceil_edge_hei = ceil_edge.texture.pixelsHigh;
    
    ceil_edge.tri_pts[0] = ccp(ceil_leftoffset,ceil_hei);
    ceil_edge.tri_pts[1] = ccp(ceil_leftoffset+ceil_wid,ceil_hei);
    ceil_edge.tri_pts[2] = ccp(ceil_leftoffset,ceil_hei+ceil_edge_hei);
    ceil_edge.tri_pts[3] = ccp(ceil_leftoffset+ceil_wid,ceil_hei+ceil_edge_hei);
    
    ceil_edge.tex_pts[2] = ccp(0,0);
    ceil_edge.tex_pts[3] = ccp(1,0);
    ceil_edge.tex_pts[0] = ccp(0,1);
    ceil_edge.tex_pts[1] = ccp(1,1);
    
    ceil_body = [Common init_render_obj:[Resource get_tex:TEX_LAB_ENTRANCE_CEIL_REPEAT] npts:4];
    ceil_body.tri_pts[0] =  ccp(ceil_leftoffset,         ceil_hei+ceil_edge_hei);
    ceil_body.tri_pts[1]  = ccp(ceil_leftoffset+ceil_wid,ceil_hei+ceil_edge_hei);
    ceil_body.tri_pts[2] =  ccp(ceil_leftoffset,         ceil_hei+ceil_edge_hei+ENTR_HEI);
    ceil_body.tri_pts[3]  = ccp(ceil_leftoffset+ceil_wid,ceil_hei+ceil_edge_hei+ENTR_HEI);
    
    ceil_body.tex_pts[2] = ccp(0,0);
    ceil_body.tex_pts[3] = ccp(1,0);
    ceil_body.tex_pts[0] = ccp(0,ceil_body.tri_pts[2].y/ceil_body.texture.pixelsHigh);
    ceil_body.tex_pts[1] = ccp(1,ceil_body.tri_pts[3].y/ceil_body.texture.pixelsHigh);
    
    return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (afg_area == NULL) [self add_afg_area:g];
    if (!activated && [Common hitrect_touch:[player get_hit_rect] b:[self get_hit_rect]]) {
        activated = YES;
        [self entrance_event];
    }
}

-(void)entrance_event {
    [GEventDispatcher push_event:[GEvent init_type:GEventType_ENTER_LABAREA]];
}

-(void)reset {
    [super reset];
    activated = NO;
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:position_.x y1:position_.y wid:50 hei:ENTR_HEI];
}

-(BOOL)get_do_render {
    return do_render;
}

-(void)add_afg_area:(GameEngineLayer*)g {
    afg_area = [LabEntranceFG cons_pt:ccp(position_.x+50,position_.y-1000) base:self];
    [g add_gameobject:afg_area];
}

-(void)draw {
    [super draw];
    [Common draw_renderobj:back_body n_vtx:4];
    [Common draw_renderobj:ceil_edge n_vtx:4];
    [Common draw_renderobj:ceil_body n_vtx:4];
}

@end
