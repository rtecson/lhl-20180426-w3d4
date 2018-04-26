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
        // Handle response here, we're still in the background thread
        if (error != nil) {
            // If error is not nil, an error was encountered
            dispatch_async(dispatch_get_main_queue(), ^{
                // Back at main queue
                self.label.text = @"Error";
                NSLog(@"Error: %@", error);
            });
            return;
        }

        // Get here if there's no error
        dispatch_async(dispatch_get_main_queue(), ^{
            // Back at main queue
            self.label.text = @"Parsing";
        });
        
        // Parse the server's response
        [self processResponse:data];
    }];
    
    // Execute the task in a background thread
    [dataTask resume];
}

- (void)processResponse:(NSData *)responseData {
    // Convert data to JSON (parsing)
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:responseData
                                    options:0
                                      error:&error];
    if (error != nil) {
        // Error in parsing JSON
        dispatch_async(dispatch_get_main_queue(), ^{
            // Back at main queue
            self.label.text = @"Error";
            NSLog(@"Error: %@", error);
        });
        return;
    }
    
    // Cast JSON to NSDictionary only if it is truly a dictionary
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
    // Walk through dictionary, etc...
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
    NSURLSessionDataTask *dataTask = [afUrlSessionManager dataTaskWithRequest:urlRequest uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id _Nullable responseObject, NSError * _Nullable error) {
        // In AFNetworking, the completion block is already in the main thread
        // Handle response here
        if (error != nil) {
            self.label.text = @"Error";
            NSLog(@"Error: %@", error);
        }
        
        // In AFNetworking, the response is already parsed into a JSON object
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self processResponseDictionary:responseObject];
        }
        self.label.text = @"Completed!";
    }];
    
    // Execute the task in a background thread
    [dataTask resume];
}


@end
