//
//  MLB3StudentTableViewCell.m
//  MusicLessonBookIII
//
//  Created by Michael Toth on 5/2/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import "MLB3StudentTableViewCell.h"

@implementation MLB3StudentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
