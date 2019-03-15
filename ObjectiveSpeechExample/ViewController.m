//
//  ViewController.m
//  ObjectiveSpeechExample
//
//  Created by ruroot on 11/25/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
{
    SpeechRecognitionWithSwift *swiftObject;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    swiftObject = [[SpeechRecognitionWithSwift alloc] init];
    swiftObject.delegate = self;
}


- (IBAction)micButtonPressed:(UIButton *)sender {
    [swiftObject micButtonPressedFunc];
}

- (void)didPrepareSpeech:(SpeechRecognitionWithSwift * _Nonnull)controller finalString:(NSString * _Nonnull)finalString isMicButtonEnabled:(BOOL)isMicButtonEnabled labelString:(NSString * _Nonnull)labelString {
    NSLog(@"%@", finalString);
    self.titleLabel.text   = finalString;
    self.micButton.enabled = isMicButtonEnabled;
    self.mLabel.text = labelString;
}


@end
