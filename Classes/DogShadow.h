#import "GameObject.h"

@interface DogShadow : GameObject {
    BOOL surfg;
}
+(DogShadow*)cons;
@end

@interface ObjectShadow : GameObject {
    GameObject* tar;
}
+(ObjectShadow*)cons_tar:(GameObject*)o;
@end