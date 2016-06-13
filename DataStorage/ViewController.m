//
//  ViewController.m
//  DataStorage
//
//  Created by Jason on 16/5/11.
//  Copyright © 2016年 Jason. All rights reserved.
//

#import "ViewController.h"

#import "FMDatabase.h"

@interface ViewController ()
{
    FMDatabase * _dataBase;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self showPath];
//    [self saveData];
    [self createData];
}
//利用沙河进行存储
- (void)showPath{
    //沙盒目录
//    Documents
//    Library
//          Caches
//          Preferences
//    tmp
    NSString * path = [[NSBundle mainBundle] bundlePath];
    NSLog(@"%@",path);
    
    NSString *path2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSArray * array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"array : %@",array);
    NSLog(@"%@", path2);
    
    NSString *path3 = NSHomeDirectory();//主目录
    NSLog(@"NSHomeDirectory:%@",path3);
//
//    NSString *fileDirectory = [path2 stringByAppendingPathComponent:@"" ];
//    NSLog(@"--%@",fileDirectory);
    
    NSString *path4 = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSLog(@"%@", path4);
    
}

/**
 *  存储数据
 */
- (void)saveData{
//    plist文件
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *fileName = [path stringByAppendingPathComponent:@"123.plist"];
    NSArray *array = @[@"123", @"456", @"789"];
    [array writeToFile:fileName atomically:YES];
    NSArray *result = [NSArray arrayWithContentsOfFile:fileName];
    NSLog(@"%@", result);
    
//    Preference
    
    //1.获得NSUserDefaults文件
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //2.向文件中写入内容
    [userDefaults setObject:@"AAA" forKey:@"a"];
    [userDefaults setBool:YES forKey:@"sex"];
    [userDefaults setInteger:21 forKey:@"age"];
    //2.1立即同步
    [userDefaults synchronize];
    //3.读取文件
    NSString *name = [userDefaults objectForKey:@"a"];
    BOOL sex = [userDefaults boolForKey:@"sex"];
    NSInteger age = [userDefaults integerForKey:@"age"];
    NSLog(@"%@, %d, %ld", name, sex, age);
    
//    NSPreferencePanesDirectory
    NSArray * Aww = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSLog(@"%@",Aww);
    NSString * str = Aww.firstObject;
    NSString * fileName2 = [str stringByAppendingPathComponent:@"DataStorage.plist"];
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:fileName2];
   NSString *name2 = [dict objectForKey:@"a"];
    NSLog(@"%@", name2);
    NSFileManager * filemanager = [NSFileManager defaultManager];
    
    
    
    NSString *peth= str; // 要列出来的目录
    
    NSFileManager *myFileManager=[NSFileManager defaultManager];
    
    NSDirectoryEnumerator *myDirectoryEnumerator;
    
    myDirectoryEnumerator=[myFileManager enumeratorAtPath:peth];
    
    //列举目录内容，可以遍历子目录
    
    NSLog(@"用enumeratorAtPath:显示目录%@的内容：",path);
    
    while((path=[myDirectoryEnumerator nextObject])!=nil)
        
    {
        
        NSLog(@"%@",path);
        
    }
    
    NSArray * arra6 = [myFileManager contentsOfDirectoryAtPath:path error:nil];
    NSLog(@"----%@",arra6);
    
    
}

//创建数据库
- (void)createData{
//     NSString * path = @"/Users/Jason/Desktop/未命名文件夹/Cache.db";
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Cache.db"];

    //生成dataBase
    _dataBase = [[FMDatabase alloc] initWithPath:path];
    BOOL ret = [_dataBase open];
    if (ret == NO) {
        NSLog(@"开启数据库失败，请检查路径");
    }else{
        NSLog(@"创建数据库成功");
    }
    [self createTables];
}
//创建表单
- (void)createTables
{
    @synchronized(self){
        NSString * sql = @"CREATE TABLE IF NOT EXISTS MyTable(ID INTEGER PRIMARY KEY AUTOINCREMENT, Name VARCHAR(128),Age INTEGER ,Score INGETER DEFAULT 0);";
        BOOL ret = [_dataBase executeUpdate:sql];
        if (ret == NO) {
            NSLog(@"创建表单错误!");
        }else{
            NSLog(@"创建表单成功");
        }
    }
    [self insertContent];
}
//增
- (void)insertContent{
     NSString * sql=@"DELETE FROM MyTable WHERE Age == 18 or Score >= 90; ";
    [_dataBase executeUpdate:sql];
    
   sql=@"INSERT INTO MyTable (Name ,Age, Score) VALUES('张三',18,99);";
    [_dataBase executeUpdate:sql];
     sql=@"INSERT INTO MyTable (Name,Age,Score) VALUES(?,?,?);";
    //调用，用真正的值，替换通配符，无论列的类型是什么，都用字符串进行替换
    [_dataBase executeUpdate:sql,@"李四",@"19",@"96"];
    [self updateContent];
    [self selectContent];
}
//查
- (void)selectContent{
    NSString * sql=@"SELECT Age FROM MyTable WHERE Age >= ?;";
    FMResultSet * set=[_dataBase executeQuery:sql,@"3"];
    //set表示集合
    while ([set next]) {
        //遍历集合中的每条记录
        //循环第一，得到第一条记录，循环第二次，得到第二条记录
        //取出对应列的数据
        NSInteger ID=[set intForColumn:@"ID"];
        NSInteger age=[set intForColumn:@"Age"];
        NSInteger score=[set intForColumn:@"Score"];
        NSString * name=[set stringForColumn:@"Name"];
        NSLog(@"ID: %ld 姓名：%@ 年龄：%ld 成绩：%ld",ID ,name,(long)age,(long)score);
    }
    
}
//改
-(void)updateContent{
    NSString * sql =@"Update MyTable set Age = 1111 WHERE Age >= ?;";
    [_dataBase executeUpdate:sql,@"3"];
    [self delete];
}
//删除数据库
- (void)delete{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Cache.db"];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    
    //文件名
    NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"Cache.db"];
    
    NSLog(@"文件是否存在: %@",[fileManager fileExistsAtPath:path]?@"YES":@"NO");
    
     BOOL blHave=[fileManager fileExistsAtPath:uniquePath];
    if (blHave) {
        NSLog(@"有");
        
    }else{
        NSLog(@"没有");
    }
    BOOL res=[fileManager removeItemAtPath:uniquePath error:nil];
    
}
















- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
