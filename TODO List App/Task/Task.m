//
//  Task.m
//  TODO List App
//
//  Created by Anas Salah on 17/04/2024.
//

#import "Task.h"

@implementation Task

- (void)encodeWithCoder:(nonnull NSCoder *)encoder {
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_des forKey:@"des"];
    [encoder encodeObject:_periority forKey:@"periority"];
    [encoder encodeObject:_status forKey:@"status"];
    [encoder encodeObject:_date forKey:@"date"];
}

-(id) initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _name = [decoder decodeObjectOfClass:[NSString class] forKey:@"name"];
        _des = [decoder decodeObjectOfClass:[NSString class] forKey:@"des"];
        _periority = [decoder decodeObjectOfClass:[NSString class] forKey:@"periority"];
        _status = [decoder decodeObjectOfClass:[NSString class] forKey:@"status"];
        _date = [decoder decodeObjectOfClass:[NSString class] forKey:@"date"];
    }
    return self;
}

- (BOOL)isEqualToTask:(Task *)otherTask {
    if (self == otherTask) {
        return YES;
    }
    if (![otherTask isKindOfClass:[Task class]]) {
        return NO;
    }
    return [self.name isEqualToString:otherTask.name] &&
           [self.des isEqualToString:otherTask.des] &&
           [self.date isEqualToString:otherTask.date] &&
           [self.status isEqualToString:otherTask.status] &&
           [self.periority isEqualToString:otherTask.periority];
}

+(BOOL)supportsSecureCoding {
    return YES;
}

@end
