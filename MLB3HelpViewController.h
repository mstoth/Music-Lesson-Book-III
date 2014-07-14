//
//  MLB3HelpViewController.h
//  MusicLessonBookIII
//
//  Created by Michael Toth on 7/12/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLB3HelpViewController : UIViewController {
    UITapGestureRecognizer *tapper;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
