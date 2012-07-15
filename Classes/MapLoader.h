#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "LineIsland.h"
#import "Island.h"
#import "Map.h"

#import "Coin.h"
#import "GroundDetail.h"
#import "DogCape.h"
#import "DogRocket.h"

@interface MapLoader : NSObject

+(Map *) load_map: (NSString *)map_file_name oftype:(NSString *) map_file_type;
+(NSArray *) load_themes_info;

@end
