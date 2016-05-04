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
    [_logInBtn addTarget:self action:@selector(sentAudioToServer) forControlEvents:UIControlEventTouchUpInside];
    
    [_statusLabel setTextAlignment:NSTextAlignmentCenter];
    [_statusLabelConnection setTextAlignment:NSTextAlignmentCenter];
    
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
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    [recordSetting setValue:[NSNumber numberWithInt: 8] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"LogIn"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(sentAudioToServer)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    _pinEditText.inputAccessoryView = keyboardDoneButtonView;
}

-(void) viewWillAppear:(BOOL)animated
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    [_actionBtn setFrame:CGRectMake((screenRect.size.width - _actionBtn.frame.size.width)/2, _actionBtn.frame.origin.y, _actionBtn.frame.size.width, _actionBtn.frame.size.height)];
    [_playBtn setFrame:CGRectMake((screenRect.size.width - _playBtn.frame.size.width)/2, _playBtn.frame.origin.y, _playBtn.frame.size.width, _playBtn.frame.size.height)];
    [_pinEditText setFrame:CGRectMake((screenRect.size.width - _pinEditText.frame.size.width)/2, _pinEditText.frame.origin.y, _pinEditText.frame.size.width, _pinEditText.frame.size.height)];
    [_logInBtn setFrame:CGRectMake((screenRect.size.width - _logInBtn.frame.size.width)/2, _logInBtn.frame.origin.y, _logInBtn.frame.size.width, _logInBtn.frame.size.height)];
    [_statusLabel setFrame:CGRectMake((screenRect.size.width - _statusLabel.frame.size.width)/2, _statusLabel.frame.origin.y, _statusLabel.frame.size.width, _statusLabel.frame.size.height)];
    [_statusLabelConnection setFrame:CGRectMake((screenRect.size.width - _statusLabelConnection.frame.size.width)/2, _statusLabelConnection.frame.origin.y, _statusLabelConnection.frame.size.width, _statusLabelConnection.frame.size.height)];
}

- (IBAction)playRecordedAudio {
    if(player.isPlaying) {
        [player stop];
    }
    if (!recorder.recording){
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
        //[self parseWavFile:recorder.url];
    }
}

- (IBAction)recordingAudio {
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
    }
    
    [_statusLabelConnection setBackgroundColor:[UIColor clearColor]];
    [_pinEditText setText:@""];
    
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        [_actionBtn setImage:[self imageByScalingAndCroppingForSize:CGSizeMake(_actionBtn.frame.size.height,_actionBtn.frame.size.width) : [UIImage imageNamed:@"mic_recording.png"]] forState:UIControlStateNormal];
        
        timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
        
        [self hidePinView];
        
    } else {
        // Stop recording
        counter = 0;
        [recorder stop];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        
        [_actionBtn setImage:[self imageByScalingAndCroppingForSize:CGSizeMake(_actionBtn.frame.size.height,_actionBtn.frame.size.width) : [UIImage imageNamed:@"mic_stop.png"]] forState:UIControlStateNormal];
        
        [timer invalidate];
        
        [_statusLabelConnection setText:@"Recording stoped"];
        [_playBtn setEnabled:YES];
        
        [self showPinView];
    }
}

-(void) timerFired {
    NSLog(@"Recording %d sec", counter);
    counter++;
    [_statusLabelConnection setText:[NSString stringWithFormat:@"Recording %d sec", counter]];
    if(counter == 20) {
        [timer invalidate];
        [self recordingAudio];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

struct WAVHEADER
{
    // WAV-формат начинается с RIFF-заголовка:
    
    // Содержит символы "RIFF" в ASCII кодировке
    // (0x52494646 в big-endian представлении)
    char chunkId[4];
    
    // 36 + subchunk2Size, или более точно:
    // 4 + (8 + subchunk1Size) + (8 + subchunk2Size)
    // Это оставшийся размер цепочки, начиная с этой позиции.
    // Иначе говоря, это размер файла - 8, то есть,
    // исключены поля chunkId и chunkSize.
    unsigned long chunkSize;
    
    // Содержит символы "WAVE"
    // (0x57415645 в big-endian представлении)
    char format[4];
    
    // Формат "WAVE" состоит из двух подцепочек: "fmt " и "data":
    // Подцепочка "fmt " описывает формат звуковых данных:
    
    // Содержит символы "fmt "
    // (0x666d7420 в big-endian представлении)
    char subchunk1Id[4];
    
    // 16 для формата PCM.
    // Это оставшийся размер подцепочки, начиная с этой позиции.
    unsigned long subchunk1Size;
    
    // Аудио формат, полный список можно получить здесь http://audiocoding.ru/wav_formats.txt
    // Для PCM = 1 (то есть, Линейное квантование).
    // Значения, отличающиеся от 1, обозначают некоторый формат сжатия.
    unsigned short audioFormat;
    
    // Количество каналов. Моно = 1, Стерео = 2 и т.д.
    unsigned short numChannels;
    
    // Частота дискретизации. 8000 Гц, 44100 Гц и т.д.
    unsigned long sampleRate;
    
    // sampleRate * numChannels * bitsPerSample/8
    unsigned long byteRate;
    
    // numChannels * bitsPerSample/8
    // Количество байт для одного сэмпла, включая все каналы.
    unsigned short blockAlign;
    
    // Так называемая "глубиная" или точность звучания. 8 бит, 16 бит и т.д.
    unsigned short bitsPerSample;
    
    // Подцепочка "data" содержит аудио-данные и их размер.
    
    // Содержит символы "data"
    // (0x64617461 в big-endian представлении)
    char subchunk2Id[4];
    
    // numSamples * numChannels * bitsPerSample/8
    // Количество байт в области данных.
    unsigned long subchunk2Size;
    
    // Далее следуют непосредственно Wav данные.
};

- (NSString*) getBase64AudioData:(NSURL*) fileUrl
{
    NSData *audioData = [NSData dataWithContentsOfFile:fileUrl.path];
    
    NSLog(@"File path: %@", fileUrl.path);
    NSLog(@"File size: %d", audioData.length);
    
    NSUInteger size = [audioData length];
    NSUInteger newSize = size - 44;
    Byte *byteData = (Byte*)malloc(newSize);
    [audioData getBytes:byteData range:NSMakeRange(44, newSize)];
    
    struct WAVHEADER header;
    
    [audioData getBytes:&header range:NSMakeRange(0, 44)];
    
    // Выводим полученные данные
    NSLog(@"Sample rate: %lu\n", header.sampleRate);
    NSLog(@"Channels: %d\n", header.numChannels);
    NSLog(@"Bits per sample: %d\n", header.bitsPerSample);
    
    NSData *newData = [NSData dataWithBytes:byteData length:newSize];
    
    free(byteData);
    
    NSLog(@"New data");
    NSLog(@"%@", [newData base64Encoding]);
    
    return [newData base64Encoding];
}

-(void) showPinView {
    [_pinEditText setHidden:NO];
    [_logInBtn setHidden:NO];
}

-(void) hidePinView {
    [_pinEditText setHidden:YES];
    [_logInBtn setHidden:YES];
}

-(void) sentAudioToServer
{
    if([[_pinEditText text] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please, enter pin code" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    [_pinEditText endEditing:YES];
    NSString *authBasicStr = [NSString stringWithFormat:@"%@:%@", @"Aketa", @"Aketa"];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [[authBasicStr dataUsingEncoding:NSUTF8StringEncoding] base64Encoding]];
    
    //NSASCIIStringEncoding
    
    NSString *postValues = [NSString stringWithFormat:@"{\"login\":\"%@\",\"password\":\"%@\"}",[self getBase64AudioData:recorder.url],[_pinEditText text]];
    
    //NSString *postValues = [NSString stringWithFormat:@"{\"login\":\"%@\",\"password\":\"%@\"}",@"dupond",@"x"];
    
    //NSData *postData = [postValues dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSData *postData = [postValues dataUsingEncoding:NSUTF8StringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.lybs.fr/AketaDemo/rest/session/login"]]];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [request setValue:@"AketaUser" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Pragma"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [request setValue:@"en-US,en;q=0.8,ru;q=0.6,uk;q=0.4" forHTTPHeaderField:@"Accept-Language"];
    
    [request setHTTPBody:postData];
    
    NSLog(@"Basic value: %@", authValue);
    
    
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if(conn) {
        //[_loginBtn setEnabled:NO];
        [_statusLabelConnection setText:@"Sending request to server ..."];
    } else {
        NSLog(@"Connection could not be made");
        [_statusLabelConnection setText:@"Connection error."];
    }
    
}

// This method is used to receive the data which we get using post method.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data
{
    //[_loginBtn setEnabled:YES];
    [_statusLabelConnection setText:@"Connection success"];
    
    NSError *error = nil;
    id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    NSLog(@"%@",[jsonData description]);
    
    if(error) {
        [_statusLabelConnection setText:@"JSON parse error"];
    }
    
    if([jsonData isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = jsonData;
        
        if([dict valueForKey:@"message"]) {
            [_statusLabelConnection setBackgroundColor:[UIColor redColor]];
            [_statusLabelConnection setText:[dict valueForKey:@"message"]];
            
            [_actionBtn setImage:[self imageByScalingAndCroppingForSize:CGSizeMake(_actionBtn.frame.size.height,_actionBtn.frame.size.width) : [UIImage imageNamed:@"error_btn.png"]] forState:UIControlStateNormal];
        } else {
            //[_statusLabelConnection setText:[jsonData description]];
            NSMutableString* info = [[NSMutableString alloc] init];
            for( NSString *aKey in [jsonData allKeys] )
            {
                [info appendFormat:@"%@ : %@\n", aKey, [jsonData objectForKey:aKey]];
            }
            [_statusLabelConnection setText:info];
            [_statusLabelConnection setBackgroundColor:[UIColor greenColor]];
            [_statusLabelConnection sizeToFit];
            
            [_actionBtn setImage:[self imageByScalingAndCroppingForSize:CGSizeMake(_actionBtn.frame.size.height,_actionBtn.frame.size.width) : [UIImage imageNamed:@"success_btn.png"]] forState:UIControlStateNormal];
        }
    }
}

// This method receives the error report in case of connection is not made to server.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //[_loginBtn setEnabled:YES];
    [_statusLabelConnection setText:[NSString stringWithFormat:@"Error: %@", error.description]];
    [_statusLabelConnection setBackgroundColor:[UIColor redColor]];
    [_statusLabelConnection sizeToFit];
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
