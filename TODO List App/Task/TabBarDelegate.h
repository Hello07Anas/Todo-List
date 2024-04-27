//
//  TabBarDelegate.h
//  TODO List App
//
//  Created by Anas Salah on 18/04/2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TabBarDelegate <NSObject>

- (void)didTapFilterButtonWithPriority:(NSInteger)priority;

@end

NS_ASSUME_NONNULL_END
