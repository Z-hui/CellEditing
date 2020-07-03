//
//  CustomTableViewCell.m
//  CellEditing
//
//  Created by DoZhui on 2020/6/30.
//  Copyright © 2020 DoZhui. All rights reserved.
//

#import "CustomTableViewCell.h"
#import "UITableViewCell+Editing.h"

@implementation CustomTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
         reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zh_replaceSystemMutiSelectImage:[UIImage imageNamed:@"icon_select"]  normalImage:[UIImage imageNamed:@"icon_noSelect"]];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
