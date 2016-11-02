//
//  ViewController.m
//  UploadFile
//
//  Created by Nagabhushan on 8/4/16.
//  Copyright © 2016 Nagabhushan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"Hello this is my test program..");
    NSLog(@"screen height %@",self.view);
    NSLog(@"scree frame %@",[UIScreen mainScreen]);
    NSString *bundleFile = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"images.jpeg"];
    NSURL* fileUrl = [NSURL fileURLWithPath:bundleFile];

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:fileUrl];
    
    [request setURL:[NSURL URLWithString:@"https://m-uatmobilecrm.allegion.com/mgwV2/sys/s/fs/logs/c-nkelkar/"]];
    [request setHTTPMethod:@"POST"]; // gem requires PUT not PATCH
    [request setValue:@"image/jpg" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"143b52g38cj2lj73h10" forHTTPHeaderField:@"GWSessionId"];
    [request setValue:@"c-nkelkar" forHTTPHeaderField:@"User name"];
    [request setValue:@"Welcome1" forHTTPHeaderField:@"Password"];
    
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.pankanis.uploadfiles"];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    NSURLSessionUploadTask* task = [session uploadTaskWithRequest:request fromFile:fileUrl];
    task.taskDescription = @"UPLOADFILES";
    [task resume];
}

/* Sent periodically to notify the delegate of upload progress.  This
 * information is also available as properties of the task.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    NSLog(@"Sent %lld total: %lld, expected: %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
}

/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    NSLog(@"Error description %@",error.description);

}



#pragma mark - NSURLSessionTaskDelegate

/* An HTTP request is attempting to perform a redirection to a different
 * URL. You must invoke the completion routine to allow the
 * redirection, allow the redirection with a modified request, or
 * pass nil to the completionHandler to cause the body of the redirection
 * response to be delivered as the payload of this request. The default
 * is to follow redirections.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSLog(@"skip %@", task.taskDescription);
    
}

/* The task has received a request specific authentication challenge.
 * If this delegate is not implemented, the session specific authentication challenge
 * will *NOT* be called and the behavior will be the same as using the default handling
 * disposition.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    if (challenge.previousFailureCount <= 3)
    {
        NSURLCredential *credential = [NSURLCredential credentialWithUser:@"c-nkelkar" password:@"Welcome1" persistence:NSURLCredentialPersistenceForSession];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
    else
    {
        NSLog(@"%s; challenge.error = %@", __FUNCTION__, challenge.error);
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
    return;
    
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust)
    {
        NSURLCredential *cred  = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:cred forAuthenticationChallenge:challenge];
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
        
        completionHandler (NSURLSessionAuthChallengeUseCredential, cred);
    }
    else if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodNTLM)
    {
        //Handle task based challenge for NTLM auth
        //TaskData *creds =  (TaskData*)_taskData[task.taskDescription];
        NSURLCredential *credential = [NSURLCredential credentialWithUser:@"c-nkelkar" password:@"Welcome1" persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        
        completionHandler (NSURLSessionAuthChallengeUseCredential, credential);
    }
    else{
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling,nil);
    }
}

/* Sent if a task requires a new, unopened body stream.  This may be
 * necessary when authentication has failed for any request that
 * involves a body stream.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
    NSLog(@"skip %@", task.taskDescription);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
