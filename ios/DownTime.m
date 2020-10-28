#import "DownTime.h"
#import <HealthKit/HealthKit.h>
#import <BackgroundTasks/BackgroundTasks.h>
#import <CoreMotion/CoreMotion.h>
#import "DownTime+Utils.h"

@implementation DownTime

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

+ (id)sharedInstance {
    static DownTime *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
  if (self = [super init]) {
  }
  return self;
}

// Will be called when this module's first listener is added.
- (void)startObserving {
  self.hasListeners = YES;
  // Set up any upstream listeners or background tasks as necessary
}

// Will be called when this module's last listener is removed, or on dealloc.
- (void)stopObserving {
  self.hasListeners = NO;
  // Remove upstream listeners, stop unnecessary background tasks
}

- (HKHealthStore *)healthStore {
  if (_healthStore == nil) {
    _healthStore = [[HKHealthStore alloc] init];
  }
  return _healthStore;
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"change:downtime-steps",
           @"change:downtime-sleep"
  ];
}

RCT_EXPORT_METHOD(sampleMethod:(NSString *)stringArgument numberParameter:(nonnull NSNumber *)numberArgument callback:(RCTResponseSenderBlock)callback)
{
    // TODO: Implement some actually useful functionality
    callback(@[[NSString stringWithFormat: @"numberArgument: %@ stringArgument: %@", numberArgument, stringArgument]]);
}

// TODO: observe steps change

RCT_EXPORT_METHOD(setupObserverWithCallback:(RCTResponseSenderBlock)callback)
{
  // Steps
  HKSampleType *stepSampleType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
  [self observeSampleTyle:stepSampleType withCallback:callback];
  
  // Sleep
  HKSampleType *sleepSampleType = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
  [self observeSampleTyle:sleepSampleType withCallback:callback];
  
  // Motion
  [self getMotionActivity];
}

RCT_EXPORT_METHOD(handleBackgroundTaskWithCallback:(RCTResponseSenderBlock)callback)
{
  [self sendNotificationWithMessage:@"background task"];
  callback(@[[NSNull null]]);
}

- (void)handleBackgroundTask:(nullable BGTask *)task {
  [self scheduleBackgroundTask];
  
  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
  queue.maxConcurrentOperationCount = 1;
        
  [task setExpirationHandler:^{
    // expiration cleanup
    [queue cancelAllOperations];
  }];
  
  [queue addOperationWithBlock:^{
    [self sendNotificationWithMessage:@"background task"];
  }];
  
  NSOperation *lastOp = queue.operations.lastObject;
  [lastOp setCompletionBlock:^{
    [task setTaskCompletedWithSuccess:!lastOp.isCancelled];
  }];
}

- (void)registerBackgroundHandler {
  // Background task
  if (@available(iOS 13.0, *)) {
    [[BGTaskScheduler sharedScheduler] registerForTaskWithIdentifier:@"io.activelife.downtime" usingQueue:nil launchHandler:^(__kindof BGTask * _Nonnull task) {
      [self handleBackgroundTask: task];
    }];
    
  } else {
    // Fallback on earlier versions
  }
}

- (void)scheduleBackgroundTask {
  if (@available(iOS 13.0, *)) {
    BGTaskRequest *request = [[BGAppRefreshTaskRequest alloc] initWithIdentifier:@"io.activelife.downtime"];
    [request setEarliestBeginDate:[NSDate date]];
    
    NSError *error;
    [[BGTaskScheduler sharedScheduler] submitTaskRequest:request error:&error];
    if (error != nil) {
      NSLog(@"scheduleBackgroundTask: %@", error);
    }
  } else {
    // Fallback on earlier versions
  }
}

- (void)observeSampleTyle:(HKSampleType *)sampleType withCallback:(RCTResponseSenderBlock)callback {
  [self.healthStore enableBackgroundDeliveryForType:sampleType
                                          frequency:HKUpdateFrequencyImmediate
                                     withCompletion:^(BOOL success, NSError * _Nullable error)
   {
    NSLog(@"success %s print some error %@", success ? "true" : "false", [error localizedDescription]);
  }];
  HKObserverQuery *query = [[HKObserverQuery alloc] initWithSampleType:sampleType
                                                             predicate:nil
                                                         updateHandler:^(HKObserverQuery *query, HKObserverQueryCompletionHandler completionHandler, NSError *error)
                            {
    if (error) {
      NSLog(@"*** An error occured while setting up the stepCount observer (C). %@ ***", error.localizedDescription);
      callback(@[RCTMakeError(@"An error occured while setting up the stepCount observer", error, nil)]);
      return;
    }
    
    [self sendNotificationWithMessage:@"Apple Health"];
    
    if (self.hasListeners && self.bridge != nil) {
      [self sendEventWithName:@"change:downtime-steps"
                         body:@{@"name": @"change:steps"}];
    }
    
    // If you have subscribed for background updates you must call the completion handler here.
     completionHandler();
  }];
  [self.healthStore executeQuery:query];
}


- (void)getMotionActivity {
  
  CMMotionActivityManager *manager = [[CMMotionActivityManager alloc] init];
 
  // get status
  if (CMMotionActivityManager.authorizationStatus == CMAuthorizationStatusAuthorized) {
    
  } else {
    
  }
  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
  queue.maxConcurrentOperationCount = 1;
  
  NSDate *start = [NSDate dateWithTimeIntervalSinceNow:-86400];
  NSDate *end = [NSDate date];
  [manager queryActivityStartingFromDate:start
                                  toDate:end
                                 toQueue:queue
                             withHandler:^(NSArray<CMMotionActivity *> * _Nullable activities, NSError * _Nullable error) {
    
    
  }];
  
  
}

@end
