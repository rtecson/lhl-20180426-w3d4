//
//  ViewController.m
//  w3d4-networking-demo
//
//  Created by Roland on 2018-02-28.
//  Copyright © 2018 MoozX Internet Ventures. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)buttonTapped:(UIButton *)sender {
    self.label.text = @"Starting...";
    [self makeNetworkRequest];
}

- (IBAction)afNetworkingButtonTapped:(id)sender {
    self.label.text = @"Starting AF Network Request...";
    [self makeAfNetworkRequest];
}


- (void)makeNetworkRequest {
    // URL to use
    NSString *urlString = @"https://swapi.co/api/people/";
    
    // Convert string to URL object
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Create a NSURLSessionDataTask object that will execute the URL and get a response
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Handle response here
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.label.text = @"Error";
                NSLog(@"Error: %@", error);
            });
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.label.text = @"Parsing";
        });
        
        [self processResponse:data];
    }];
    
    // Execute the task in a background thread
    [dataTask resume];
}

- (void)processResponse:(NSData *)responseData {
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:responseData
                                    options:0
                                      error:&error];
    if (error != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.label.text = @"Error";
            NSLog(@"Error: %@", error);
        });
        return;
    }
    
    if ([json isKindOfClass:[NSDictionary class]]) {
        NSDictionary *jsonDict = (NSDictionary *)json;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self processResponseDictionary:jsonDict];
            self.label.text = @"Completed!";
        });
    }
}

- (void)processResponseDictionary:(NSDictionary *)responseDictionary {
    NSLog(@"jsonDict: %@", responseDictionary);
}

- (void)makeAfNetworkRequest {
    // URL to use
    NSString *urlString = @"https://swapi.co/api/people/";
    
    // Convert string to URL object
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Convert URL object to URLRequest object
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];

    // Instantiate AF URL session manager with default configuration settings
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *afUrlSessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    // Create a NSURLSessionDataTask object that will execute the URL and get a response
    NSURLSessionDataTask *dataTask = [afUrlSessionManager dataTaskWithRequest:urlRequest uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        // Handle response here
        if (error != nil) {
            self.label.text = @"Error";
            NSLog(@"Error: %@", error);
        }
        
        self.label.text = @"Parsing";

        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self processResponseDictionary:responseObject];
        }
        self.label.text = @"Completed!";
    }];
    
    // Create a NSURLSessionDataTask object that will execute the URL and get a response
    // Execute the task in a background thread
    [dataTask resume];
}


@end
