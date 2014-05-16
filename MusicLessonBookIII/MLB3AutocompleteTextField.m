//
//  MLB3AutocompleteTextField.m
//  MusicLessonBookIII
//
//  Created by Michael Toth on 5/15/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import "MLB3AutocompleteTextField.h"

@implementation MLB3AutocompleteTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (BOOL)resignFirstResponder
{
    if (!self.autocompleteDisabled)
    {
        self.autocompleteLabel.hidden = YES;
        
        if ([self commitAutocompleteText]) {
            // Only notify if committing autocomplete actually changed the text.
            
            
            // This is necessary because committing the autocomplete text changes the text field's text, but for some reason UITextField doesn't post the UITextFieldTextDidChangeNotification notification on its own
            [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification
                                                                object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MLB3AutocompleteTextFieldCommitted" object:self];
        }
    }
    
    return [super resignFirstResponder];
}

@end
