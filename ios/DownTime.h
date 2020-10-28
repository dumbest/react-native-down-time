#import <React/RCTBridgeModule.h>
#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import <React/RCTUtils.h>

#if __has_include("RCTEventEmitter.h")
#import "RCTEventEmitter.h"
#else
#import <React/RCTEventEmitter.h>
#endif

@interface DownTime : RCTEventEmitter <RCTBridgeModule>

@property BOOL hasListeners;
@property (nonatomic) HKHealthStore *healthStore;

+ (id)sharedInstance;
- (void)registerBackgroundHandler;
- (void)scheduleBackgroundTask;

@end
