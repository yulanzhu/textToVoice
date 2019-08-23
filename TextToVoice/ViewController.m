//
//  ViewController.m
//  TextToVoice
//
//  Created by FUCK on 2017/12/26.
//  Copyright © 2017年 YHMFK. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UrlViewController.h"
@interface ViewController ()<AVSpeechSynthesizerDelegate , UITextViewDelegate>{
    AVSpeechSynthesizer * av;
    AVSpeechUtterance * utterance;
}
@property (nonatomic , strong)UITextView * languageTextView;
@property (nonatomic , strong)UITextField * urlTextFiled;
@property (nonatomic , strong)UIButton * btn1;
@property (nonatomic , strong)UIButton * btn2;
@property (nonatomic , strong)UIButton * btn3;
@property (nonatomic , strong)UIButton * btn4;
@property (nonatomic , strong)UIButton * searchBtn;
@property (nonatomic , strong)UISlider * voiceSlider;
@property (nonatomic , strong)UIButton * setSpeedBtn;
@property (nonatomic , strong)UISegmentedControl * langageSwich;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //处理中断事件的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterreption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    //
    [self setSpeech];
    //
    [self setUI];
}
- (void)setSpeech {
    //初始化对象
    av= [[AVSpeechSynthesizer alloc]init];
    av.delegate=self;//挂上代理
}
- (void)setUI {
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 22, self.view.frame.size.width - 20, 200)];
    [self.view addSubview:imageView];
    imageView.userInteractionEnabled = YES;
    imageView.layer.cornerRadius = 10;
    imageView.layer.masksToBounds = YES;
    imageView.image = [UIImage imageNamed:@"texfileBG.jpg"];
    
    self.languageTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    [imageView addSubview:self.languageTextView];
    self.languageTextView.backgroundColor = [UIColor clearColor];
    self.languageTextView.layer.cornerRadius = 10;
    self.languageTextView.layer.masksToBounds = YES;
    self.languageTextView.textColor = [UIColor redColor];
    self.languageTextView.font = [UIFont systemFontOfSize:25];
    self.languageTextView.text = @"hello every body";
    self.languageTextView.delegate = self;
    //
    for (int i = 0 ; i < 4; i++) {
        CGFloat with = (self.view.frame.size.width - 20 - 5 * 3)/4;
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(10 + 5 * i + with * i, imageView.frame.origin.y + imageView.frame.size.height + 10, with, 30)];
        [self.view addSubview:btn];
        btn.backgroundColor=[UIColor clearColor];
        [btn setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor]forState:UIControlStateSelected];
        btn.layer.borderWidth = 1.5;
        btn.layer.cornerRadius = btn.frame.size.height/2;
        btn.layer.masksToBounds = YES;
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn addTarget:self action:@selector(startYHMFK:)forControlEvents:UIControlEventTouchUpInside];
        switch (i) {
            case 0:
                self.btn1 =btn;
                [btn setTitle:@"开 始 播 放" forState:UIControlStateNormal];
                btn.tag = 1000 + i;
                break;
            case 1:
                self.btn2 =btn;
                [btn setTitle:@"暂 停 播 放" forState:UIControlStateNormal];
                btn.tag = 1000 + i;
                break;
            case 2:
                self.btn3 =btn;
                [btn setTitle:@"继 续 播 放" forState:UIControlStateNormal];
                btn.tag = 1000 + i;
                break;
            case 3:
                self.btn4 =btn;
                [btn setTitle:@"关 闭 播 放" forState:UIControlStateNormal];
                btn.tag = 1000 + i;
                break;
            default:
                break;
        }
    }
    //设置textFiled
    [self setTextFildYHMFK];
    //设置语速
    [self setVoiceSpeed];
}
- (void)setVoiceSpeed{
    self.voiceSlider = [[UISlider alloc]initWithFrame:CGRectMake(10, self.urlTextFiled.frame.origin.y + self.urlTextFiled.frame.size.height + 20, self.btn3.frame.origin.x + self.btn3.frame.size.width - 10, 20)];
    [self.view addSubview:self.voiceSlider];
    self.voiceSlider.value = 0.5;
    self.voiceSlider.minimumValue = 0;
    self.voiceSlider.maximumValue = 1;
    //
    self.setSpeedBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.voiceSlider.frame.size.width + self.voiceSlider.frame.origin.x + 5, self.voiceSlider.frame.origin.y - 5,self.searchBtn.frame.size.width, 30)];
    [self.view addSubview:self.setSpeedBtn];
    self.setSpeedBtn.backgroundColor=[UIColor clearColor];
    [self.setSpeedBtn setTitle:@"设 置 语 速" forState:UIControlStateNormal];
    [self.setSpeedBtn setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    [self.setSpeedBtn setTitleColor:[UIColor redColor]forState:UIControlStateHighlighted];
    self.setSpeedBtn.layer.borderWidth = 1.5;
    self.setSpeedBtn.layer.cornerRadius = self.searchBtn.frame.size.height/2;
    self.setSpeedBtn.layer.masksToBounds = YES;
    self.setSpeedBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.setSpeedBtn addTarget:self action:@selector(setSpeedBtnClick:)forControlEvents:UIControlEventTouchUpInside];
}
- (void)setSpeedBtnClick : (UIButton *)btn {
    if([av isSpeaking]) {//正在讲
        [av stopSpeakingAtBoundary:AVSpeechBoundaryWord];//感觉效果一样，对应代理>>>取消
    }
    if (self.languageTextView.text.length == 0){
        [self setLanguage:@"没有输入文字你他么让我说个屁啊" rate:self.voiceSlider.value];
    }else{
        [self setLanguage:self.languageTextView.text rate:self.voiceSlider.value];
    }
    [av speakUtterance:utterance];//开始
}
- (void) setTextFildYHMFK {
    self.urlTextFiled = [[UITextField alloc]initWithFrame:CGRectMake(10, self.btn2.frame.size.height + self.btn2.frame.origin.y + 10, self.btn2.frame.origin.x + self.btn2.frame.size.width - 10, 30)];
    [self.view addSubview:self.urlTextFiled];
    self.urlTextFiled.placeholder = @"  请输入网址";
    self.urlTextFiled.layer.borderWidth = 1.5;
    self.urlTextFiled.layer.cornerRadius = self.urlTextFiled.frame.size.height/2;
    self.urlTextFiled.layer.masksToBounds = YES;
    //
    self.searchBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.urlTextFiled.frame.size.width + self.urlTextFiled.frame.origin.x + 5, self.urlTextFiled.frame.origin.y,self.btn3.frame.size.width, 30)];
    [self.view addSubview:self.searchBtn];
    self.searchBtn.backgroundColor=[UIColor clearColor];
    [self.searchBtn setTitle:@"搜 索" forState:UIControlStateNormal];
    [self.searchBtn setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    [self.searchBtn setTitleColor:[UIColor redColor]forState:UIControlStateHighlighted];
    self.searchBtn.layer.borderWidth = 1.5;
    self.searchBtn.layer.cornerRadius = self.searchBtn.frame.size.height/2;
    self.searchBtn.layer.masksToBounds = YES;
    self.searchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.searchBtn addTarget:self action:@selector(searchBtnClick:)forControlEvents:UIControlEventTouchUpInside];
    //
    self.langageSwich = [[UISegmentedControl alloc]initWithFrame:CGRectMake(self.searchBtn.frame.size.width + self.searchBtn.frame.origin.x + 5, self.urlTextFiled.frame.origin.y,self.btn3.frame.size.width, 30)];
    [self.langageSwich insertSegmentWithTitle:@"中文" atIndex:0 animated:NO];
    [self.langageSwich insertSegmentWithTitle:@"阿语" atIndex:1 animated:NO];
    [self.view addSubview:self.langageSwich];
    self.langageSwich.layer.borderWidth = 1.5;
    self.langageSwich.layer.cornerRadius = self.langageSwich.frame.size.height/2;
    self.langageSwich.layer.masksToBounds = YES;
    self.langageSwich.tintColor = [UIColor blackColor];
    self.langageSwich.selectedSegmentIndex = 0;
    
}
- (void)searchBtnClick: (UIButton *)btn {
    
    
    if(self.urlTextFiled.text.length == 0) {//没有输入网址
        if([av isSpeaking]) {//正在讲
            [av stopSpeakingAtBoundary:AVSpeechBoundaryWord];//感觉效果一样，对应代理>>>取消
        }
        [self setLanguage:@"没有输入网址你他么让我搜个屁啊" rate:self.voiceSlider.value];
        [av speakUtterance:utterance];//开始
    }else{//有输入网址
        UrlViewController * urlCon = [[UrlViewController alloc]init];
        urlCon.urlString = self.urlTextFiled.text;
        [self.navigationController pushViewController:urlCon animated:YES];
        urlCon.comebackString = ^(NSString * textString){
            //
            self.languageTextView.text = textString;
            self.btn1.selected = YES;
            //
            if([av isSpeaking]) {//正在讲
                [av stopSpeakingAtBoundary:AVSpeechBoundaryWord];//感觉效果一样，对应代理>>>取消
            }
            [self setLanguage:textString rate:self.voiceSlider.value];
            [av speakUtterance:utterance];//开始
        };
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;

}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;

}
- (void)startYHMFK: (UIButton *)btn {
    switch (btn.tag) {
        case 1000://开始
            self.btn1.selected = YES;
            self.btn2.selected = NO;
            self.btn3.selected = NO;
            self.btn4.selected = NO;
            if(![av isSpeaking]) {//没有正在讲
                if (self.languageTextView.text.length == 0){
                    [self setLanguage:@"没有输入文字你他么让我说个屁啊" rate:self.voiceSlider.value];
                }else{
                    [self setLanguage:self.languageTextView.text rate:self.voiceSlider.value];
                }
                [av speakUtterance:utterance];//开始
            }
            break;
        case 1001://暂停
            self.btn1.selected = NO;
            if(![av isSpeaking]) {//没有正在讲
                self.btn2.selected = NO;
            }else{
                self.btn2.selected = YES;
            }
            self.btn3.selected = NO;
            self.btn4.selected = NO;
            [av pauseSpeakingAtBoundary:AVSpeechBoundaryWord];//暂停
            break;
        case 1002://继续
            self.btn1.selected = NO;
            self.btn2.selected = NO;
            if(![av isSpeaking]) {//没有正在讲
                self.btn3.selected = NO;
            }else{
                self.btn3.selected = YES;
            }
            self.btn4.selected = NO;
            if([av isPaused]) {
                //如果暂停则恢复，会从暂停的地方继续
                [av continueSpeaking];
            }
            break;
        case 1003://关闭
            self.btn1.selected = NO;
            self.btn2.selected = NO;
            self.btn3.selected = NO;
            if(![av isSpeaking]) {//没有正在讲
                self.btn4.selected = NO;
            }else{
                self.btn4.selected = YES;
            }
            [av stopSpeakingAtBoundary:AVSpeechBoundaryWord];//感觉效果一样，对应代理>>>取消
            break;
        default:
            break;
    }
}
//处理中断事件
-(void)handleInterreption:(NSNotification *)sender{
    if([av isSpeaking]) {//没有正在讲
        //进行暂停播放
        self.btn1.selected = NO;
        self.btn2.selected = YES;
        self.btn3.selected = NO;
        self.btn4.selected = NO;
        [av pauseSpeakingAtBoundary:AVSpeechBoundaryWord];//暂停
    }else{
        //进行继续播放
        self.btn1.selected = NO;
        self.btn2.selected = NO;
        self.btn3.selected = YES;
        self.btn4.selected = NO;
        if([av isPaused]) {
            //如果暂停则恢复，会从暂停的地方继续
            [av continueSpeaking];
        }
    }
}
- (void)setLanguage:(NSString *)String rate:(CGFloat)rateFK{
    NSLog(@"%f",self.voiceSlider.value);
    NSLog(@"%f",rateFK);
    utterance = [[AVSpeechUtterance alloc]initWithString:String];//需要转换的文字
    utterance.rate = rateFK;// 设置语速，范围0-1，注意0最慢，1最快；AVSpeechUtteranceMinimumSpeechRate最慢，AVSpeechUtteranceMaximumSpeechRate最快
    
    if (self.langageSwich.selectedSegmentIndex == 0) {
        AVSpeechSynthesisVoice*voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];//设置发音，这是中文普通话  阿语ar-SA
        utterance.voice= voice;
    }else if (self.langageSwich.selectedSegmentIndex == 0){
        AVSpeechSynthesisVoice*voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"ar-SA"];//设置发音，这是中文普通话  阿语ar-SA
        utterance.voice= voice;
    }
    
}

#pragma MARK - 代理
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didStartSpeechUtterance:(AVSpeechUtterance*)utterance{
    NSLog(@"---开始播放");
}
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance*)utterance{
    NSLog(@"---完成播放");
    self.btn1.selected = NO;
    self.btn2.selected = NO;
    self.btn3.selected = NO;
    self.btn4.selected = NO;
}
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance*)utterance{
    NSLog(@"---播放中止");
}
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance*)utterance{
    NSLog(@"---恢复播放");
}
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance*)utterance{
    NSLog(@"---播放取消");
}
//textViewDelegate
- (void)textViewDidChangeSelection:(UITextView *)textView{
    NSLog(@"%lu",(unsigned long)self.languageTextView.selectedRange.length);
    NSLog(@"%lu",(unsigned long)self.languageTextView.selectedRange.location);
    NSString * tempString1 = self.languageTextView.text;
    NSLog(@"%@",[tempString1 substringFromIndex:self.languageTextView.selectedRange.location]);
    NSString * tempString2 = [tempString1 substringFromIndex:self.languageTextView.selectedRange.location];
    if([av isSpeaking]) {//正在讲
        [av stopSpeakingAtBoundary:AVSpeechBoundaryWord];//感觉效果一样，对应代理>>>取消
    }
    //
    if (self.languageTextView.text.length == 0){
        [self setLanguage:@"没有输入文字你他么让我说个屁啊" rate:self.voiceSlider.value];
    }else{
        [self setLanguage:tempString2 rate:self.voiceSlider.value];
    }
    [av speakUtterance:utterance];//开始
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
