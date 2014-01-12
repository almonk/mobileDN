//
//  CommentCell.m
//  MobileDN
//
//  Created by Alasdair Monk on 31/12/2013.
//  Copyright (c) 2013 Alasdair Monk. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    float indentPoints = self.indentationLevel * self.indentationWidth;
    

    
    self.contentView.frame = CGRectMake(
                                indentPoints,
                                self.contentView.frame.origin.y,
                                self.contentView.frame.size.width - indentPoints,
                                self.contentView.frame.size.height
                                );

 
}

@end
