//
//  ViewController.m
//  Fmdb_demo
//
//  Created by Dhui on 2019/4/8.
//  Copyright © 2019年 Dhui. All rights reserved.
//

#import "ViewController.h"
#import "FMDB.h"
#import "showDataCell.h"

@interface ViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSString *insertName;
    NSString *insertAge;
    
    int updateId;
    NSString *updateName;
    NSString *updateAge;
    
    NSMutableArray *dataAry;
    __weak IBOutlet UITableView *tbView;
}
@property(nonatomic,strong)FMDatabase *db;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dataAry = [[NSMutableArray alloc] init];//初始化数组
    [self testCreatSqlite];
    tbView.tableFooterView = [UIView new];
    // Do any additional setup after loading the view, typically from a nib.
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark- textfieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    switch (textField.tag) {
        case 302:{
            insertName = str;
        }
            break;
        case 303:{
            insertAge = str;
        }
            break;
        case 305:{
            updateName = str;
        }
            break;
        case 306:{
            updateAge = str;
        }
            break;
        default:
            break;
    }
    return YES;
}

#pragma mark- UitableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    showDataCell *cell = [tableView dequeueReusableCellWithIdentifier:@"showDataCell"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"showDataCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell initData:dataAry[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = dataAry[indexPath.row];
    
    updateId = [[dic objectForKey:@"ID"] intValue];
    
    UITextField *textFieldName = [self.view viewWithTag:305];
    updateName = [dic objectForKey:@"name"];
    textFieldName.text = [dic objectForKey:@"name"];
    
    UITextField *textFieldAge = [self.view viewWithTag:306];
    updateAge = [dic objectForKey:@"age"];
    textFieldAge.text = [dic objectForKey:@"age"];
}

//先要设Cell可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

//定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}
//进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *dic = dataAry[indexPath.row];
        updateId = [[dic objectForKey:@"ID"] intValue];
        
        [self delete];
    }
}

#pragma mark- Action
- (IBAction)insertAction:(id)sender {
    [self insert];
}
- (IBAction)updateAction:(id)sender {
    [self update];
    
}

#pragma mark- FMDB

- (NSString *)getFileName{
    //1.获得数据库文件的路径
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [doc stringByAppendingPathComponent:@"student.sqlite"];
    return fileName;
}

- (void)testCreatSqlite{
    //2.获得数据库
    FMDatabase *db=[FMDatabase databaseWithPath:[self getFileName]];
    
    //打开数据库
    if ([db open]) {
        //4.创表
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_student (id integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, age text NOT NULL);"];
        if (result) {
            NSLog(@"创表成功");
        }else
        {
            NSLog(@"创表失败");
        }
        [db close];
    }
    self.db = db;
}
//插入数据
-(void)insert{
    //打开数据库
    if ([self.db open]) {
        BOOL res = [self.db executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?, ?);", insertName, insertAge];
        if (!res) {
            NSLog(@"数据插入失败");
        } else {
            NSLog(@"数据插入成功");
            [self query];
        }
        [self.db close];
    }
    
}

//更新数据
- (void)update{
    //打开数据库
    if ([self.db open]) {
        BOOL res = [self.db executeUpdate:@"update t_student set name = ? , age = ? where id = ? " , updateName,updateAge,@(updateId)];
        if (!res) {
            NSLog(@"数据修改失败");
        } else {
            NSLog(@"数据修改成功");
            [self query];
        }
        [self.db close];
    }
}

//删除数据
-(void)delete
{
    //打开数据库
    if ([self.db open]) {
        BOOL res = [self.db executeUpdate:@"DELETE FROM t_student where id = ?",@(updateId)];;
        if (!res) {
            NSLog(@"数据删除失败");
        } else {
            NSLog(@"数据删除成功");
            [self query];
        }
        [self.db close];
    }
    //    [self.db executeUpdate:@"DROP TABLE IF EXISTS t_student;"];
    //    [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_student (id integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, age integer NOT NULL);"];
}

//查询
- (void)query
{
    [dataAry removeAllObjects];
    
    //打开数据库
    if ([self.db open]) {
        // 1.执行查询语句
        FMResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM t_student"];
        
        // 2.遍历结果
        while ([resultSet next]) {
            int ID = [resultSet intForColumn:@"id"];
            NSString *name = [resultSet stringForColumn:@"name"];
            NSString *age = [resultSet stringForColumn:@"age"];
            
            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@(ID),@"ID",name,@"name",age,@"age", nil];
            [dataAry addObject:dic];
        }
        
        [self.db close];
    }
    [tbView reloadData];
}

@end

