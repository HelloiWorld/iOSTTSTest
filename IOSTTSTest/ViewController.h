//
//  ViewController.h
//  IOSTTSTest
//
//  Created by P on 14-9-5.
//  Copyright (c) 2014年 Naturalsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController<AVSpeechSynthesizerDelegate,UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIPickerView *pickLanguage;
@property (weak, nonatomic) IBOutlet UISlider *speedSlider;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UISlider *pitchSlider;
@property (weak, nonatomic) IBOutlet UILabel *speedSliderValue;
@property (weak, nonatomic) IBOutlet UILabel *volumeSliderValue;
@property (weak, nonatomic) IBOutlet UILabel *pitchSliderValue;

@property (strong,nonatomic) IBOutlet UITextView *textInput;
@property (strong,nonatomic) IBOutlet UIButton *playBtn;

- (IBAction)playBtnClick:(id)sender;
- (IBAction)stopBtnClick:(id)sender;
- (IBAction)speedChange:(id)sender;
- (IBAction)volumeChange:(id)sender;
- (IBAction)pitchChange:(id)sender;

@end
