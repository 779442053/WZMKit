//
//  WZMSqliteManager.h
//  WZMFoundation
//
//  Created by Mr.Wang on 16/12/30.
//  Copyright © 2016年 MaoChao Network Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WZMSqliteManager : NSObject

+ (instancetype)manager;
- (BOOL)createTableName:(NSString *)tableName modelClass:(Class)modelClass;
- (BOOL)insertModel:(id)model tableName:(NSString *)tableName;
- (BOOL)deleteModel:(id)model tableName:(NSString *)tableName primkey:(NSString *)primkey;
- (BOOL)updateModel:(id)model tableName:(NSString *)tableName primkey:(NSString *)primkey;

- (long)insertColumns:(NSArray *)columnNames tableName:(NSString *)tableName;
- (long)deleteColumns:(NSArray *)columnNames tableName:(NSString *)tableName;

- (long)execute:(NSString *)sql;
- (BOOL)deleteDataBase:(NSError **)error;
- (BOOL)deleteTableName:(NSString *)tableName;
- (NSMutableArray *)selectWithSql:(NSString *)sql;

@end
