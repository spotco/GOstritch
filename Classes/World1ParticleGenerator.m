#import "World1ParticleGenerator.h"
#import "Player.h"
#import "GameEngineLayer.h"

@implementation World1ParticleGenerator

+(World1ParticleGenerator*)init {
    return [World1ParticleGenerator node];
}

-(GameObjectReturnCode)update:(Player *)player g:(GameEngineLayer *)g {
    if (arc4random_uniform(25) == 0) {
        [g add_particle:[WaveParticle init_x:player.position.x+500 y:player.position.y+float_random(100, 300) vx:float_random(-2, -5) vtheta:float_random(0.01, 0.075)]];
    }
    return GameObjectReturnCode_NONE;
}

@end
