//
//  DMIssuesController.h
//  DevMateIssues
//
//  Copyright 2013-2015 DevMate Inc. All rights reserved.
//

//! TESTING
// to test crash/exception reporting pass special arguments to the main executable:
//      *main_app_executable* [-test_crash [delay_seconds]] [-test_exception [delay_seconds]]
//  - if you pass -test_crash argument, DMIssuesController instance will crash app after delay_seconds (or immediately)
//  only after controller initialization
//  - if you pass -test_exception argument, DMIssuesController instance will throw an exception after delay_seconds (or immediately)
//  only after controller initialization

@protocol DMIssuesControllerDelegate;

@interface DMIssuesController : NSObject

+ (instancetype)sharedController;

@property (assign) id<DMIssuesControllerDelegate> delegate;

//! User name/email to use inside the problem reporter
@property (nonatomic, retain) NSDictionary *defaultUserInfo; // look for keys below

//! Array of NSURL instances. Set it in case you have custom log files. By default log is obtained from ASL (default NSLog behaviour) for non-sandboxed apps.
@property (nonatomic, retain) NSArray *logURLs;

/*! @brief Will show problem reporter for unhandled issues if such exists or make reporter window active if it's already visible.
    @return \p YES if reporter window is visible or will be shown for unhandled issues. \p NO otherwise.
 */
- (BOOL)reportUnhandledProblemsIfExists;

/*! @brief Method to customize UI controller behavior.
    @discussion For correct work even for crash reporter this class and all other resources/classes should be implemented in separate framework.
    @param  controllerClass class that should be a subclass of DMIssuesWindowController.
 */
- (void)setIssuesWindowControllerClass:(Class)controllerClass;

@end

@interface DMIssuesController (com_devmate_Deprecated)
- (void)enableCrashReporting DM_DEPRECATED("Will be automatically enabled right after initialization.");
- (void)enableUncaughtExceptionReporting DM_DEPRECATED("Will be automatically enabled right after initialization.");
@end

@protocol DMIssuesControllerDelegate <NSObject>
@optional

- (void)reporterWillRestartApplication:(DMIssuesController *)controller;

//! In case of NO, new problem will be marked as unhandled.
- (BOOL)shouldReportExceptionProblem:(DMIssuesController *)controller;
- (BOOL)shouldReportCrashProblem:(DMIssuesController *)controller;

//! Additional info that will be attached to standard issue report.
- (NSString *)additionalIssueInfoForController:(DMIssuesController *)controller;

@end

//! Keys for defaulUserInfo dictionary
FOUNDATION_EXPORT NSString *const DMIssuesDefaultUserNameKey; // NSString
FOUNDATION_EXPORT NSString *const DMIssuesDefaultUserEmailKey; // NSString
FOUNDATION_EXPORT NSString *const DMIssuesDefaultCommentKey; // NSString
