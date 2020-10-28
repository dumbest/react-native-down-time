//
//  DownTime+Utils.m
//  AppAuth
//
//  Created by Thanakrit Weekhamchai on 27/10/20.
//

#import "DownTime+Utils.h"
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import <UIKit/UIKit.h>

@implementation DownTime (Utils)

- (void)sendNotificationWithMessage:(NSString *)message {
  CGFloat brightness = [UIScreen mainScreen].brightness;
  
  UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
  content.title = [NSString localizedUserNotificationStringForKey:@"Screen is on?" arguments:nil];
  content.body = [NSString localizedUserNotificationStringForKey:[NSString stringWithFormat:@"Screen brightness: %.2f %@", brightness, message]
              arguments:nil];
  content.sound = [UNNotificationSound defaultSound];

  // Deliver the notification in five seconds.
  UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1
                                                                                                  repeats:NO];
  UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
                                                                        content:content
                                                                        trigger:trigger];

  // Schedule the notification.
  UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
  [center addNotificationRequest:request withCompletionHandler:nil];
}

@end
