//
//  Task.h
//  TODO List App
//
//  Created by Anas Salah on 17/04/2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Task : NSObject<NSCoding, NSSecureCoding>

@property NSString *name;
@property NSString *des;
@property NSString *periority;
@property NSString *status;
@property NSString *date;

-(void) encodeWithCoder:(NSCoder *)encoder;

- (BOOL)isEqualToTask:(Task *)otherTask;

@end

NS_ASSUME_NONNULL_END
