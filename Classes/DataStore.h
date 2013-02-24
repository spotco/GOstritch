#import <Foundation/Foundation.h>

@interface DataStore : NSObject

#define STO_test1_INT @"test1"
#define STO_test2_FLT @"test2"
#define STO_test3_STR @"test3"

#define STO_totalbones_INT @"totalbones"
#define STO_maxbones_INT @"maxbones"

+(void)cons;
+(BOOL)isset_key:(NSString*)key;
+(void)reset_key:(NSString*)key;
+(void)set_key:(NSString*)key int_value:(int)val;
+(int)get_int_for_key:(NSString*)key;
+(void)set_key:(NSString*)key flt_value:(float)val;
+(float)get_flt_for_key:(NSString*)key;
+(void)set_key:(NSString*)key str_value:(NSString*)val;
+(NSString*)get_str_for_key:(NSString*)key;
+(void)reset_all;

@end
