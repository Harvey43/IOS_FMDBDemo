//
//  showDataCell.m
//  Fmdb_demo
//
//  Created by Dhui on 2019/4/8.
//  Copyright © 2019年 Dhui. All rights reserved.
//

#import "showDataCell.h"

@implementation showDataCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initData:(NSDictionary *)dic{
    UILabel *lblID = [self viewWithTag:101];
    lblID.text = [[dic objectForKey:@"ID"] stringValue];
    
    UILabel *lblName = [self viewWithTag:102];
    lblName.text = [dic objectForKey:@"name"];
    
    UILabel *lblAge = [self viewWithTag:103];
    lblAge.text = [dic objectForKey:@"age"];
}
@end
