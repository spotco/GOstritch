#import <Foundation/Foundation.h>
#import "Common.h"

@interface FileCache : NSObject

+(CGRect)get_cgrect_from_plist:(NSString*)file idname:(NSString*)idname;

@end
