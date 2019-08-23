//
//  UrlViewController.h
//  TextToVoice
//
//  Created by FUCK on 2017/12/27.
//  Copyright © 2017年 YHMFK. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UrlViewController : UIViewController
/**
 *  定义了一个changeColor的Block。这个changeColor必须带一个参数，这个参数的类型必须为id类型的
 *  无返回值
 *  param id
 */
typedef  void(^changeString)(NSString * stirng);
/**
 *  用上面定义的changeColor声明一个Block,声明的这个Block必须遵守声明的要求。
 */
@property (nonatomic, copy) changeString comebackString;

@property (nonatomic ,strong)NSString * urlString;
@end
