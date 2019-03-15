//
//  ViewController.h
//  ObjectiveSpeechExample
//
//  Created by ruroot on 11/25/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectiveSpeechExample-Swift.h"

@interface ViewController : UIViewController <SpeechRecognitionWithSwiftDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *micButton;
@property (weak, nonatomic) IBOutlet UILabel *mLabel;
- (IBAction)micButtonPressed:(UIButton *)sender;

@end

