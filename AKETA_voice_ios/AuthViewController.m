//
//  AuthViewController.m
//  AKETA_voice_ios
//
//  Created by adventis on 2/27/15.
//  Copyright (c) 2015 com.beardapps.aketavoice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthViewController.h"
#import "ViewController.h"

@interface AuthViewController ()

@end

@implementation AuthViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    [_loginBtn addTarget:self action:@selector(logIn) forControlEvents:UIControlEventTouchUpInside];
    
    [_statusLabel setTextAlignment:NSTextAlignmentCenter];
}

-(void) viewWillAppear:(BOOL)animated
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    [_logoImage setFrame:CGRectMake((screenRect.size.width - 250)/2, _logoImage.frame.origin.y, 250, 200)];
    
    [_loginEditText setFrame:CGRectMake((screenRect.size.width - _loginEditText.frame.size.width)/2, _loginEditText.frame.origin.y, _loginEditText.frame.size.width, _loginEditText.frame.size.height)];
    [_passwordEditText setFrame:CGRectMake((screenRect.size.width - _passwordEditText.frame.size.width)/2, _passwordEditText.frame.origin.y, _passwordEditText.frame.size.width, _passwordEditText.frame.size.height)];
    
    [_loginBtn setFrame:CGRectMake((screenRect.size.width - _loginBtn.frame.size.width)/2, _loginBtn.frame.origin.y, _loginBtn.frame.size.width, _loginBtn.frame.size.height)];
    [_statusLabel setFrame:CGRectMake((screenRect.size.width - _statusLabel.frame.size.width)/2, _statusLabel.frame.origin.y, _statusLabel.frame.size.width, _statusLabel.frame.size.height)];
}

-(void) logIn
{
    if([_loginEditText.text isEqualToString:@""] || [_passwordEditText.text isEqualToString:@""]) {
        [_statusLabel setText:@"Please fill up all fields"];
        return;
    }
    
    NSString *postValues = [NSString stringWithFormat:@"{\"username\"=\"%@\", \"password\"=\"%@\"}",_loginEditText.text,_passwordEditText.text];
    NSData *postData = [postValues dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.lybs.fr/AketaDemo/rest/session/login"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if(conn) {
        [_loginBtn setEnabled:NO];
        [_statusLabel setText:@"Sending request to server ..."];
    } else {
        NSLog(@"Connection could not be made");
        [_statusLabel setText:@"Connection error."];
    }
    
}

// This method is used to receive the data which we get using post method.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data
{
    [_loginBtn setEnabled:YES];
    [_statusLabel setText:@"Connection success"];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"recordView"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:NULL];
}

// This method receives the error report in case of connection is not made to server.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [_loginBtn setEnabled:YES];
    [_statusLabel setText:[NSString stringWithFormat:@"Error: %@", error.description]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
