//
//  ViewController.m
//  AKETA_voice_ios
//
//  Created by adventis on 2/27/15.
//  Copyright (c) 2015 com.beardapps.aketavoice. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    counter = 0;
    [_playBtn setEnabled:NO];
    
    // Disable Stop/Play button when application launches
    
    
    [_actionBtn setImage:[self imageByScalingAndCroppingForSize:CGSizeMake(_actionBtn.frame.size.height,_actionBtn.frame.size.width) : [UIImage imageNamed:@"mic_none.png"]] forState:UIControlStateNormal];
    
    [_actionBtn addTarget:self action:@selector(recordingAudio) forControlEvents:UIControlEventTouchUpInside];
    [_playBtn addTarget:self action:@selector(playRecordedAudio) forControlEvents:UIControlEventTouchUpInside];
    
    [_statusLabel setTextAlignment:NSTextAlignmentCenter];
    
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               RECAUDIOFILE,
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

-(void) viewWillAppear:(BOOL)animated
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    [_actionBtn setFrame:CGRectMake((screenRect.size.width - _actionBtn.frame.size.width)/2, _actionBtn.frame.origin.y, _actionBtn.frame.size.width, _actionBtn.frame.size.height)];
    [_playBtn setFrame:CGRectMake((screenRect.size.width - _playBtn.frame.size.width)/2, _playBtn.frame.origin.y, _playBtn.frame.size.width, _playBtn.frame.size.height)];
    [_statusLabel setFrame:CGRectMake((screenRect.size.width - _statusLabel.frame.size.width)/2, _statusLabel.frame.origin.y, _statusLabel.frame.size.width, _statusLabel.frame.size.height)];
}

- (IBAction)playRecordedAudio {
    if(player.isPlaying) {
        [player stop];
    }
    if (!recorder.recording){
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
    }
}

- (IBAction)recordingAudio {
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        [_actionBtn setImage:[self imageByScalingAndCroppingForSize:CGSizeMake(_actionBtn.frame.size.height,_actionBtn.frame.size.width) : [UIImage imageNamed:@"mic_recording.png"]] forState:UIControlStateNormal];
        
        timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
        
    } else {
        // Stop recording
        counter = 0;
        [recorder stop];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        
        [_actionBtn setImage:[self imageByScalingAndCroppingForSize:CGSizeMake(_actionBtn.frame.size.height,_actionBtn.frame.size.width) : [UIImage imageNamed:@"mic_stop.png"]] forState:UIControlStateNormal];
        
        [timer invalidate];
        
        [_statusLabel setText:@"Recording stoped"];
        [_playBtn setEnabled:YES];
    }
}

-(void) timerFired {
    NSLog(@"Recording %d sec", counter);
    counter++;
    [_statusLabel setText:[NSString stringWithFormat:@"Recording %d sec", counter]];
    if(counter == 20) {
        [timer invalidate];
        [self recordingAudio];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize:(UIImage *)srcimage
{
    UIImage *sourceImage = srcimage;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

@end
