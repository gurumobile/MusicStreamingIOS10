//
//  LeftView.m
//  MusicStreaming
//
//  Created by Bogdan on 10/24/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "LeftView.h"
#import "FYWebViewController.h"

@interface LeftView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LeftView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:0.97];
        [self initTableView:frame];
    }
    return self;
}

- (void)initTableView:(CGRect)frame {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:self.tableView];
}

#pragma mark -
#pragma mark - UITableView DataSource...

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    
    headerView.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:0.0];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 150;
        case 1:
            return 30;
        case 4:
            return 30;
        default:
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cell0";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"Sign the Lotery";
            break;
        case 1:
            cell.textLabel.text = @"Home";
            break;
        case 2:
            cell.textLabel.text = @"Favorite";
            break;
        case 3:
            cell.textLabel.text = @"Cache";
            break;
        case 4:
            cell.textLabel.text = @"Turn off timer";
            break;
        case 5:
            cell.textLabel.text = @"Feedback";
            break;
        case 6:
            cell.textLabel.text = @"(´・ω・)ﾉLike";
            break;
        default:
            cell.textLabel.text = @"Load error";
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://sandbox.runjs.cn/show/cph8yp2j"]];

            [self.delegate jumpWebVC:[NSURL URLWithString:@"http://sandbox.runjs.cn/show/cph8yp2j"]];
            break;
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://sandbox.runjs.cn/show/ep2rmlww"]];
            break;
        case 2:

            break;
        case 3:
            
            break;
        case 4:
            
            break;
        case 5:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://438239428@qq.com"]];
            break;
        case 6:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/Fyus1201/music"]];
            break;
        default:
            
            break;
    }   
}

@end
