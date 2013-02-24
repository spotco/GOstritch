#import "MainMenuPage.h"

@implementation MainMenuPageInteractiveItem
-(void)touch_down_at:(CGPoint)pt {}
-(void)touch_move_at:(CGPoint)pt {}
-(void)touch_up_at:(CGPoint)pt {}
@end

@implementation MainMenuPage
@synthesize interactive_items;

-(id)init {
    interactive_items = [[NSMutableArray alloc] init];
    return [super init];
}

-(void)cons_starting_at:(CGPoint)tstart {
    [self setPosition:tstart];
    [self setAnchorPoint:ccp(0,0)];
}

-(void)touch_down_at:(CGPoint)pt {
    for (MainMenuPageInteractiveItem *i in interactive_items) {
        [i touch_down_at:pt];
    }
    
    for (CCNode* n in self.interactive_items) {
        if (CGRectContainsPoint([n boundingBoxInPixels], pt)) {
            [GEventDispatcher push_event:[GEvent cons_type:GEventType_MENU_CANCELDRAG]];
            break;
        }
    }
}

-(void)touch_move_at:(CGPoint)pt {
    for (MainMenuPageInteractiveItem *i in interactive_items) {
        [i touch_move_at:pt];
    }
}

-(void)touch_up_at:(CGPoint)pt {
    for (MainMenuPageInteractiveItem *i in interactive_items) {
        [i touch_up_at:pt];
    }
}

-(void)add_interactive_item:(MainMenuPageInteractiveItem *)i {
    [interactive_items addObject:i];
    [self addChild:i];
}

-(void)dealloc {
    [interactive_items removeAllObjects];
    [interactive_items release];
    [super dealloc];
}
@end


@implementation MainMenuPageZoomButton
@synthesize pressed;

#define DEFAULTZOOM 1.1

+(MainMenuPageZoomButton*)cons_texture:(CCTexture2D *)tex at:(CGPoint)pos fn:(CallBack*)fn {
    return [[MainMenuPageZoomButton node] cons_texture:tex at:pos fn:fn];
}

+(MainMenuPageZoomButton*)cons_spr:(CCNode*)spr at:(CGPoint)pos fn:(CallBack*)fn {
    return [[MainMenuPageZoomButton node] cons_spr:spr at:pos fn:fn];
}


-(void)setScale:(float)scale {
    [super setScale:scale];
    for (CCNode* n in children_) {
        [n setScale:scale];
    }
}

-(MainMenuPageZoomButton*)cons_spr:(CCNode*)spr at:(CGPoint)pos fn:(CallBack*)fn {
    img = spr;
    zoom = DEFAULTZOOM;
    n_bbox = img.boundingBoxInPixels;
    [self addChild:img];
    cb = fn;
    [self setPosition:pos];
    return self;
}

-(MainMenuPageZoomButton*)cons_texture:(CCTexture2D *)tex at:(CGPoint)pos fn:(CallBack*)fn {
    return [self cons_spr:[CCSprite spriteWithTexture:tex] at:pos fn:fn];
}

-(void)touch_down_at:(CGPoint)pt {
    if (CGRectContainsPoint([self get_hitbox], pt)) {
        pressed = YES;
        [self setScale:zoom];
    } else {
        pressed = NO;
        [self setScale:1.0];
    }
}

-(void)touch_move_at:(CGPoint)pt {
    if (!CGRectContainsPoint([self get_hitbox], pt)) {
        pressed = NO;
        [self setScale:1.0];
    }
}

-(void)touch_up_at:(CGPoint)pt {
    if (pressed && CGRectContainsPoint([self get_hitbox], pt)) {
        [Common run_callback:cb];
    }
    pressed = NO;
    [self setScale:1.0];
}

-(CGRect)get_hitbox {
    return CGRectMake(
        position_.x-n_bbox.size.width/2, 
        position_.y-n_bbox.size.height/2, 
        n_bbox.size.width, 
        n_bbox.size.height);
}

-(CGRect)boundingBoxInPixels {
    return [self get_hitbox];
}

-(MainMenuPageZoomButton*)set_zoom:(float)tzoom {
    zoom = tzoom;
    return self;
}

@end
