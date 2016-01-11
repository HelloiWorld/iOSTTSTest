//
//  ViewController.m
//  IOSTTSTest
//
//  Created by P on 14-9-5.
//  Copyright (c) 2014年 Naturalsoft. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

-(NSDictionary *)languageDictionary{
    if (!_languageDictionary) {
        NSArray *voices = [AVSpeechSynthesisVoice speechVoices];
        
        NSArray *languages = [voices valueForKey:@"language"];
        NSLog(@"voices:%@",languages);
        NSLocale *currentLocale = [NSLocale autoupdatingCurrentLocale];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        for (NSString *code in languages) {
            dictionary[code]=[currentLocale displayNameForKey:NSLocaleIdentifier value:code];
            
        }
        
        _languageDictionary = dictionary;
    }
    return _languageDictionary;
}

-(NSArray *)languageCodes{
    if (!_languageCodes) {
        _languageCodes=[self.languageDictionary keysSortedByValueUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    return _languageCodes;
}

-(AVSpeechSynthesizer *)synthesizer{
    if (!_synthesizer) {
        _synthesizer=[[AVSpeechSynthesizer alloc] init];
        _synthesizer.delegate=self;
    }
    return _synthesizer;
}

-(void)ttsStart{
    if (self.textInput.text && !self.synthesizer.isSpeaking) {
        // zh-CN en-US  nil:defualt
        NSLog(@"%@",self.selectedLanguage);
        
        AVSpeechSynthesisVoice *voice=[AVSpeechSynthesisVoice voiceWithLanguage:self.selectedLanguage];
        AVSpeechUtterance *utterance=[[AVSpeechUtterance alloc] initWithString:self.textInput.text];
        utterance.voice=voice;
        
        float adjustedRate = AVSpeechUtteranceMaximumSpeechRate*self.speedSlider.value;
        if (adjustedRate > AVSpeechUtteranceMaximumSpeechRate) {
            adjustedRate=AVSpeechUtteranceMaximumSpeechRate;
        }
        
        if (adjustedRate < AVSpeechUtteranceMinimumSpeechRate) {
            adjustedRate=AVSpeechUtteranceMinimumSpeechRate;
        }
        
        utterance.rate=adjustedRate;
        
        float pitchMultiplier=1.0;
        if ((pitchMultiplier>=0.5)&&(pitchMultiplier<=2.0)) {
            utterance.pitchMultiplier=pitchMultiplier;
        }
        
        utterance.volume=self.volumeSlider.value;
        
        
        [self.synthesizer speakUtterance:utterance];
    }
}


-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance{

}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    [self.playBtn setTitle:@"Play" forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"%@",self.languageDictionary);
    NSLog(@"%@",self.languageCodes);
}

-(IBAction)playBtnClick:(id)sender{
    [self hideKeyClick:Nil];
    if ([[self.playBtn titleForState:UIControlStateNormal] isEqualToString:@"Play"]) {
        
        if (self.synthesizer.isPaused) {
            [self.synthesizer continueSpeaking];
        }else{
            [self ttsStart];
        }
        [self.playBtn setTitle:@"Pause" forState:UIControlStateNormal];
    }else{
        [self.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        [self.playBtn setTitle:@"Play" forState:UIControlStateNormal];
    }
}

-(IBAction)hideKeyClick:(id)sender{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil]; 
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.languageCodes count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *languageCode=self.languageCodes[[self.languageCodes count] - row - 1];
    NSString *languageName=self.languageDictionary[languageCode];
    return languageName;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.selectedLanguage=[self.languageCodes objectAtIndex:[self.languageCodes count] - row - 1];
    NSLog(@"%@",self.selectedLanguage);
    //[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@""];
    //[[NSUserDefaults standardUserDefaults] synchronize];
}


-(IBAction)speedChange:(id)sender{
    if (self.synthesizer.isPaused || self.synthesizer.isSpeaking) {
        [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        [self ttsStart];
    }
    
}

-(IBAction)volumeChange:(id)sender{
    if (self.synthesizer.isPaused || self.synthesizer.isSpeaking) {
        [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        [self ttsStart];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
