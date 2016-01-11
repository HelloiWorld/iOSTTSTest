//
//  ViewController.h
//  IOSTTSTest
//
//  Created by P on 14-9-5.
//  Copyright (c) 2014年 Naturalsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVSpeechSynthesis.h>

@interface ViewController : UIViewController<AVSpeechSynthesizerDelegate,UIPickerViewDelegate>


@property (strong,nonatomic) NSArray *languageCodes;
@property (strong,nonatomic) NSDictionary *languageDictionary;

@property (strong,nonatomic) AVSpeechSynthesizer *synthesizer;

@property (strong,nonatomic) IBOutlet UIPickerView *pickLanguage;
@property (strong,nonatomic) IBOutlet UISlider *speedSlider;
@property (strong,nonatomic) IBOutlet UISlider *volumeSlider;
@property (strong,nonatomic) IBOutlet UITextView *textInput;
@property (strong,nonatomic) IBOutlet UIButton *playBtn;
@property (strong,nonatomic) NSString *selectedLanguage;

-(IBAction)hideKeyClick:(id)sender;
-(IBAction)playBtnClick:(id)sender;
-(IBAction)speedChange:(id)sender;
-(IBAction)volumeChange:(id)sender;

@end
