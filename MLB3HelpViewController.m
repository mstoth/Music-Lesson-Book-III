//
//  MLB3HelpViewController.m
//  MusicLessonBookIII
//
//  Created by Michael Toth on 7/12/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import "MLB3HelpViewController.h"

@interface MLB3HelpViewController ()

@end

@implementation MLB3HelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *pathForHelp1 = [[NSBundle mainBundle] pathForResource:@"help1" ofType:@"html"];
    NSURL *help1URL = [NSURL fileURLWithPath:pathForHelp1];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:help1URL];
    [self.webView loadRequest:request];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
