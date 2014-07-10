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
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testForRecorder
{
    BOOL hasRecordFunction = [dvc canPerformAction:@selector(record:) withSender:self];
    XCTAssertTrue(hasRecordFunction,@"Can try to record");
}

@end
