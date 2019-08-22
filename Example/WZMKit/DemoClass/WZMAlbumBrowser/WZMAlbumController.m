//
//  WZMAlbumController.m
//  WZMKit_Example
//
//  Created by WangZhaomeng on 2019/8/12.
//  Copyright © 2019 wangzhaomeng. All rights reserved.
//

#import "WZMAlbumController.h"
#import <Photos/Photos.h>
#import "WZMAlbumNavigationController.h"
#import "WZMAlbumView.h"
#import "WZMAlbumHelper.h"

@interface WZMAlbumController ()<UIAlertViewDelegate,WZMAlbumViewDelegate>

@property (nonatomic, strong) WZMAlbumConfig *config;
@property (nonatomic, strong) WZMAlbumView *albumView;

@end

@implementation WZMAlbumController

- (instancetype)initWithConfig:(WZMAlbumConfig *)config {
    self = [super init];
    if (self) {
        self.config = config;
        self.title = @"选择素材";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(leftItemClick)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick)];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.albumView = [[WZMAlbumView alloc] initWithFrame:WZMRectBottomArea() config:self.config];
    self.albumView.delegate = self;
    [self.view addSubview:self.albumView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkAlbumAuthorization];
}

- (void)leftItemClick {
    if ([self.navigationController isKindOfClass:[WZMAlbumNavigationController class]]) {
        WZMAlbumNavigationController *picker = (WZMAlbumNavigationController *)self.navigationController;
        if ([picker.pickerDelegate respondsToSelector:@selector(albumNavigationControllerDidCancel:)]) {
            [picker.pickerDelegate albumNavigationControllerDidCancel:picker];
        }
        if (self.config.autoDismiss) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else {
        if ([self.pickerDelegate respondsToSelector:@selector(albumControllerDidCancel:)]) {
            [self.pickerDelegate albumControllerDidCancel:self];
        }
        if (self.config.autoDismiss) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)rightItemClick {
    if (self.albumView.selectedPhotos.count < self.config.minCount) {
        NSString *msg = [NSString stringWithFormat:@"请至少选择%@张照片",@(self.config.minCount)];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [WZMViewHandle wzm_showProgressMessage:@"处理中..."];
    self.navigationController.view.userInteractionEnabled = NO;
    [self photosWithModels:self.albumView.selectedPhotos completion:^(NSArray *photos) {
        [WZMViewHandle wzm_dismiss];
        self.navigationController.view.userInteractionEnabled = YES;
        if ([self.navigationController isKindOfClass:[WZMAlbumNavigationController class]]) {
            WZMAlbumNavigationController *picker = (WZMAlbumNavigationController *)self.navigationController;
            if ([picker.pickerDelegate respondsToSelector:@selector(albumNavigationController:didSelectedPhotos:)]) {
                [picker.pickerDelegate albumNavigationController:picker didSelectedPhotos:photos];
            }
            if (self.config.autoDismiss) {
                [picker dismissViewControllerAnimated:YES completion:nil];
            }
        }
        else {
            if ([self.pickerDelegate respondsToSelector:@selector(albumController:didSelectedPhotos:)]) {
                [self.pickerDelegate albumController:self didSelectedPhotos:photos];
            }
            if (self.config.autoDismiss) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
}

//代理
- (void)albumViewDidSelectedFinish:(WZMAlbumView *)albumView {
    [self rightItemClick];
}

- (void)albumViewWillShowPreview:(WZMAlbumView *)albumView atIndexPath:(NSIndexPath *)indexPath {
    WZMAlbumModel *model = [albumView.allPhotos objectAtIndex:indexPath.row];
    NSLog(@"%@",model);
}

//相册权限
- (void)checkAlbumAuthorization {
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized){//用户之前已经授权
        [self.albumView reloadData];
    }
    else if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied){//用户之前已经拒绝授权
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请前往“设置-隐私-照片”打开应用的相册访问权限" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
    else{//弹窗授权时监听
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized){//允许
                    [self.albumView reloadData];
                }
                else {//拒绝
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }
            });
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

///获取图片(UIImage)或视频(路径)
- (void)photosWithModels:(NSArray<WZMAlbumModel *> *)models completion:(void(^)(NSArray *photos))completion {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    [self photosWithModels:models index:0 array:array completion:completion];
}

- (void)photosWithModels:(NSArray<WZMAlbumModel *> *)models index:(NSInteger)index array:(NSMutableArray *)array completion:(void(^)(NSArray *photos))completion {
    if (index < models.count) {
        WZMAlbumModel *model = [models objectAtIndex:index];
        [self photoWithModel:model completion:^(id obj) {
            if (obj) {
                [array addObject:obj];
            }
            [self photosWithModels:models index:(index+1) array:array completion:completion];
        }];
    }
    else {
        if (completion) {
            completion([array copy]);
        }
    }
}

- (void)photoWithModel:(WZMAlbumModel *)model completion:(void(^)(id obj))completion {
    [WZMAlbumHelper wzm_getOriginalWithAsset:model.asset completion:^(id obj) {
        if (completion) {
            completion(obj);
        }
    }];
}

- (void)dealloc {
    WZMLog(@"%@释放了",NSStringFromClass(self.class));
}

@end