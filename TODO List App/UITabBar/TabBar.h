//
//  TabBar.h
//  TODO List App
//
//  Created by Anas Salah on 17/04/2024.
//

#import <UIKit/UIKit.h>

@protocol TabBarDelegate <NSObject>

- (void)filterButtonTappedInTabBar;

@end
NS_ASSUME_NONNULL_BEGIN

@interface TabBar : UITabBarController

@property (nonatomic, weak) id<TabBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
