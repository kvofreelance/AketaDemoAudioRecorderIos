//
//  ViewController.h
//  AKETA_voice_ios
//
//  Created by adventis on 2/27/15.
//  Copyright (c) 2015 com.beardapps.aketavoice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define RECAUDIOFILE @"aketa_audio.m4a"

@interface ViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate> {
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSTimer *timer;
    int counter;
}

@property (strong, nonatomic) IBOutlet UIButton *actionBtn;
@property (strong, nonatomic) IBOutlet UIButton *playBtn;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

@end

