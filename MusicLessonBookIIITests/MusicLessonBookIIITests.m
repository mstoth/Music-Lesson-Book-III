
//
//  MusicLessonBookIIITests.m
//  MusicLessonBookIIITests
//
//  Created by Michael Toth on 4/7/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MLB3Store.h"
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "MLB3LessonDetailViewController.h"
//#import "OCMock.h"
//#import "OCMockObject.h"
//#import "OCMMacroState.h"
#import <SenTestingKit/SenTestingKit.h>

@interface MusicLessonBookIIITests : XCTestCase {
    MLB3LessonDetailViewController *dvc;
}
@end

@implementation MusicLessonBookIIITests

- (void)setUp
{
    [super setUp];
    dvc = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"LessonDetail"];
    id<UIApplicationDelegate> del = [[UIApplication sharedApplication] delegate];
    UIWindow *w = [del window];
    UINavigationController *rvc = (UINavigationController *)[w rootViewController];
    //UINavigationController *nc = [rvc navigationController];
    [rvc pushViewController:dvc animated:YES];

    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    dvc = nil;
    [super tearDown];
}

- (void)testForRecorder
{
    BOOL hasRecordFunction = [dvc canPerformAction:@selector(record:) withSender:self];
    XCTAssertTrue(hasRecordFunction,@"Can try to record");
}

- (void)testForButtonChange
{

    UIButton *button = [[UIButton alloc] initWithCoder:nil];
    [button setTitle:@"Record" forState:UIControlStateNormal];
    [dvc record:button];
    XCTAssertEqualObjects(button.titleLabel.text, @"Stop", @"Record button says stop.");
// change back
    
    [dvc record:button];
    
    XCTAssertEqualObjects(button.titleLabel.text, @"Play", @"Record button should say Play after making a recording.");
    
    // file should exist
    NSURL *recordingURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"recording.mp3"];
    NSString *recordingString = [recordingURL path];
    NSFileManager *fm = [NSFileManager defaultManager];
    XCTAssertTrue([fm fileExistsAtPath:recordingString],@"recording.mp3 should exist.");
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



@end
