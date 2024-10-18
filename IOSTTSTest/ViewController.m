//
//  ViewController.m
//  IOSTTSTest
//
//  Created by P on 14-9-5.
//  Copyright (c) 2014年 Naturalsoft. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;

@property (strong, nonatomic) NSArray *voiceArray;
@property (strong, nonatomic) NSDictionary *languageDictionary;
@property (strong, nonatomic) NSArray *languageCodes;
@property (strong, nonatomic) NSString *selectedLanguage;

@end

@implementation ViewController

-(AVSpeechSynthesizer *)synthesizer{
    if (!_synthesizer) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
        _synthesizer.delegate = self;
    }
    return _synthesizer;
}

-(NSArray *)voiceArray{
    if (!_voiceArray) {
        NSArray *voices = [AVSpeechSynthesisVoice speechVoices];
        // 过滤出语言代码包含 "en" 的音色
        NSPredicate *englishPredicate = [NSPredicate predicateWithFormat:@"SELF.language BEGINSWITH 'en'"];
        NSArray *englishVoices = [voices filteredArrayUsingPredicate:englishPredicate];
        // 打印出支持英语的发音人信息
        for (AVSpeechSynthesisVoice *voice in englishVoices) {
            NSLog(@"Voice Identifier: %@, Language: %@, Name: %@", voice.identifier, voice.language, voice.name);
        }
        _voiceArray = englishVoices;
    }
    return _voiceArray;
}

-(NSDictionary *)languageDictionary{
    if (!_languageDictionary) {
        NSLocale *currentLocale = [NSLocale autoupdatingCurrentLocale];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        for (AVSpeechSynthesisVoice *voice in self.voiceArray) {
            NSString *localeName = [currentLocale displayNameForKey:NSLocaleIdentifier value:voice.language];
            dictionary[voice.language] = [NSString stringWithFormat:@"%@ %@", localeName, voice.name];
        }
        _languageDictionary = dictionary;
    }
    return _languageDictionary;
}

-(NSArray *)languageCodes{
    if (!_languageCodes) {
        _languageCodes = [self.languageDictionary keysSortedByValueUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    return _languageCodes;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"%@", self.languageDictionary);
    NSLog(@"%@", self.languageCodes);
    [self.pickLanguage selectRow:0 inComponent:0 animated:NO];
    [self pickerView:self.pickLanguage didSelectRow:0 inComponent:0];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)segmentValueChanged:(UISegmentedControl *)sender {
    NSLocale *currentLocale = [NSLocale autoupdatingCurrentLocale];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (sender.selectedSegmentIndex == 0) {
        for (AVSpeechSynthesisVoice *voice in self.voiceArray) {
            NSString *localeName = [currentLocale displayNameForKey:NSLocaleIdentifier value:voice.language];
            dictionary[voice.language] = [NSString stringWithFormat:@"%@ %@", localeName, voice.name];
        }
    } else {
        for (AVSpeechSynthesisVoice *voice in self.voiceArray) {
            NSString *localeName = [currentLocale displayNameForKey:NSLocaleIdentifier value:voice.language];
            dictionary[voice.identifier] = [NSString stringWithFormat:@"%@ %@", localeName, voice.name];
        }
    }
    self.languageDictionary = dictionary;
    self.languageCodes = [self.languageDictionary keysSortedByValueUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self.pickLanguage reloadAllComponents];
    [self.pickLanguage selectRow:0 inComponent:0 animated:YES];
    [self pickerView:self.pickLanguage didSelectRow:0 inComponent:0];
}

-(IBAction)playBtnClick:(id)sender{
    if ([[self.playBtn titleForState:UIControlStateNormal] isEqualToString:@"Play"]) {
        if (self.synthesizer.isPaused) {
            [self.synthesizer continueSpeaking];
        } else {
            [self ttsStart];
        }
    } else {
        [self.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
}

- (IBAction)stopBtnClick:(id)sender {
    [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.languageCodes count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *languageCode = self.languageCodes[self.languageCodes.count - row - 1];
    NSString *languageName = self.languageDictionary[languageCode];
    return languageName;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSString *languageCode = self.languageCodes[self.languageCodes.count - row - 1];
    NSString *languageName = self.languageDictionary[languageCode];
    self.selectedLanguage = languageCode;
    NSLog(@"selected language name: %@", languageName);
}

-(IBAction)speedChange:(id)sender{
    self.speedSliderValue.text = [NSString stringWithFormat:@"%.1f", self.speedSlider.value];
    [self ttsStart];
}

- (IBAction)pitchChange:(id)sender {
    self.pitchSliderValue.text = [NSString stringWithFormat:@"%.1f", self.pitchSlider.value];
    [self ttsStart];
}

-(IBAction)volumeChange:(id)sender{
    self.volumeSliderValue.text = [NSString stringWithFormat:@"%.1f", self.volumeSlider.value];
    [self ttsStart];
}

-(void)ttsStart{
    if (self.synthesizer.isPaused || self.synthesizer.isSpeaking) {
        [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
    if (self.textInput.text && self.selectedLanguage != nil) {
        AVSpeechSynthesisVoice *voice;
        if (self.segmentedControl.selectedSegmentIndex == 0) {
            voice = [AVSpeechSynthesisVoice voiceWithLanguage: self.selectedLanguage];
        } else {
            voice = [AVSpeechSynthesisVoice voiceWithIdentifier: self.selectedLanguage];
        }
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString: self.textInput.text];
        utterance.voice = voice;
        
        float adjustedRate = AVSpeechUtteranceMaximumSpeechRate * self.speedSlider.value;
        if (adjustedRate > AVSpeechUtteranceMaximumSpeechRate) {
            adjustedRate = AVSpeechUtteranceMaximumSpeechRate;
        } else if (adjustedRate < AVSpeechUtteranceMinimumSpeechRate) {
            adjustedRate = AVSpeechUtteranceMinimumSpeechRate;
        }
        utterance.rate = adjustedRate;
        
        float pitchMultiplier = self.pitchSlider.value;
        if (pitchMultiplier >= 0.5 && pitchMultiplier <= 2.0) {
            utterance.pitchMultiplier = pitchMultiplier;
        }
        
        utterance.volume = self.volumeSlider.value;
        
        [self.synthesizer speakUtterance: utterance];
    }
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance {
    [self.playBtn setTitle:@"Pause" forState:UIControlStateNormal];
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance {
    [self.playBtn setTitle:@"Play" forState:UIControlStateNormal];
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance {
    // 创建可变属性字符串来修改文本属性（如颜色）
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.textInput.text];
    // 设置非朗读部分的颜色为默认色
    [attributedText addAttribute:NSForegroundColorAttributeName value:self.textInput.textColor range:NSMakeRange(0, self.textInput.text.length)];
    [attributedText addAttribute:NSFontAttributeName value:self.textInput.font range:NSMakeRange(0, self.textInput.text.length)];
    // 设置正在朗读的文本部分的颜色为高亮色
    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:characterRange];
    // 更新 UITextView 的显示
    self.textInput.attributedText = attributedText;
    // 自动滚动到高亮部分
    [self.textInput scrollRangeToVisible:characterRange];
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    [self.playBtn setTitle:@"Play" forState:UIControlStateNormal];
}

@end
