//
//  AuthViewController.h
//  AKETA_voice_ios
//
//  Created by adventis on 2/27/15.
//  Copyright (c) 2015 com.beardapps.aketavoice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AuthViewController : UIViewController {

}
@property (strong, nonatomic) IBOutlet UITextField *loginEditText;
@property (strong, nonatomic) IBOutlet UITextField *passwordEditText;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIImageView *logoImage;

@end
