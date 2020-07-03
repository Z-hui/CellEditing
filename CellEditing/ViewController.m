//
//  ViewController.m
//  CellEditing
//
//  Created by DoZhui on 2020/6/30.
//  Copyright © 2020 DoZhui. All rights reserved.
//

#import "ViewController.h"
#import "CustomTableViewCell.h"
#import "UITableViewCell+Editing.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"切换编辑状态" style:(UIBarButtonItemStyleDone) target:self action:@selector(editingAction)];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:(UIBarButtonItemStyleDone) target:self action:@selector(sureAction)];

    // Do any additional setup after loading the view.
}

- (void)editingAction {
    if ([self.tableView isEditing]) {
        
        [self.tableView setEditing:NO];
    }else {
        [self.tableView setEditing:YES];
    }
}

- (void)sureAction {
    //获取选中的indexPath
    NSArray <NSIndexPath *>* array = [self.tableView indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in array) {
        NSLog(@"选中的row:%ld",indexPath.row);
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 80;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomTableViewCell"];
    if (!cell) {
        cell = [[CustomTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"CustomTableViewCell"];
    }
    
    /**
     如果你有某些cell是不想支持多选的
     1.实现- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath 对制定的indexPath返回nil；
     2.设置zh_isCanSelect为NO，此属性使用后其他不隐藏indexPath要设置为YES，分类内部无法判断重用
     */
    if (indexPath.row == 3) {
        cell.zh_isCanSelect = NO;
    }else {
        cell.zh_isCanSelect = YES;
    }
    
    /**
     如果你有某些cell是想自定义多虚啊图标位置的
     1.设置zh_selectImageViewFrame，此属性使用后其他不隐藏indexPath要设置为CGRectZero，分类内部无法判断重用
     */
    if (indexPath.row == 5) {
        cell.zh_selectImageViewFrame = CGRectMake(13, 10, 23, 23);
    }else {
        cell.zh_selectImageViewFrame = CGRectZero;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Index:%ld",indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
