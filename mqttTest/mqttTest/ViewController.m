//
//  ViewController.m
//  mqttTest
//
//  Created by coder on 2018/3/19.
//  Copyright © 2018年 WBL. All rights reserved.
//

#import "ViewController.h"
#import "NSData+AES.h"

#import "MQTTClient.h"
#import "MQTTSessionManager.h"

@interface ViewController ()<MQTTSessionManagerDelegate>
@property (strong, nonatomic) MQTTSessionManager *manager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.manager) {
        MQTTSSLSecurityPolicyTransport *transport = [[MQTTSSLSecurityPolicyTransport alloc]init];
        transport.host = @"host.com";
        transport.port = 8883;
        transport.tls = YES;
        NSString*  ca = [[NSBundle bundleForClass:[MQTTSession class]] pathForResource:@"ca" ofType:@"der"];
        ////TODO:双向认证需加入client证书
//        NSString*  client = [[NSBundle bundleForClass:[MQTTSession class]] pathForResource:@"certificate" ofType:@"p12"];
//        transport.certificates = [MQTTSSLSecurityPolicyTransport clientCertsFromP12:client passphrase:@"password"];
        MQTTSSLSecurityPolicy *securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeCertificate];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        securityPolicy.validatesCertificateChain = NO;
        securityPolicy.pinnedCertificates = @[[NSData dataWithContentsOfFile:ca]];
        transport.securityPolicy = securityPolicy;
        
        self.manager = [[MQTTSessionManager alloc] init];
        self.manager.delegate = self;
        ////不使用证书
//        [self.manager connectTo:@"host.com"
//                           port:1883
//                            tls:NO
//                      keepalive:60  //心跳间隔不得大于120s
//                          clean:true
//                           auth:true
//                           user:@"username"
//                           pass:@"password"
//                           will:false
//                      willTopic:nil
//                        willMsg:nil
//                        willQos:0
//                 willRetainFlag:FALSE
//                   withClientId:@"clientid"];
        ////使用证书(这里采用单项认证，双向认证只需把certificates:参数设置为transport.certificates即可)
        [self.manager connectTo:@"host.com"
                           port:8883
                            tls:YES
                      keepalive:60
                          clean:true
                           auth:YES
                           user:@"username"
                           pass:@"password"
                           will:false
                      willTopic:nil
                        willMsg:nil
                        willQos:0
                 willRetainFlag:FALSE
                   withClientId:@"clientid"
                 securityPolicy:securityPolicy
                   certificates:nil];
    } else {
        [self.manager connectToLast];
    }
    /*
     * MQTTCLient: observe the MQTTSessionManager's state to display the connection status
     */
    
    [self.manager addObserver:self
                   forKeyPath:@"state"
                      options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                      context:nil];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    switch (self.manager.state) {
        case MQTTSessionManagerStateClosed:
            NSLog(@"MQTTSessionManagerStateClosed");
            break;
        case MQTTSessionManagerStateClosing:
            NSLog(@"MQTTSessionManagerStateClosing");
            break;
        case MQTTSessionManagerStateConnected:
            NSLog(@"MQTTSessionManagerStateConnected");
            //连接成功订阅
            for (int i=0; i<3; i++) {
                [self.manager subscribeToTopic:[NSString stringWithFormat:@"%d%d%d%d%d%d%d%d",i,i,i,i,i,i,i,i] atLevel:1];
            }
            break;
        case MQTTSessionManagerStateConnecting:
            NSLog(@"MQTTSessionManagerStateConnecting");
            break;
        case MQTTSessionManagerStateError:
            NSLog(@"MQTTSessionManagerStateError");
            break;
        case MQTTSessionManagerStateStarting:
            NSLog(@"MQTTSessionManagerStateStarting");
        default:
            NSLog(@"default");
            break;
    }
}

- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    NSLog(@"------------->>%@",topic);
    
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",dataString);
    
}


- (IBAction)connect:(id)sender {
    [self.manager connectToLast];
}
- (IBAction)sub:(id)sender {
    [self.manager subscribeToTopic:@"55555555555555555" atLevel:1];
}
- (IBAction)unsub:(id)sender {
    [self.manager unsubscribeTopic:@"55555555555555555"];
}
- (IBAction)disconnect:(id)sender {
    [self.manager disconnect];
}




@end
