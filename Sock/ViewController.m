//
//  ViewController.m
//  Sock
//
//  Created by stoicer on 2022/9/21.
//

#import "ViewController.h"
#import "SockService.h"

@interface ViewController ()
@property (nonatomic, strong) SockService *srv;
@property (weak, nonatomic) IBOutlet UILabel *showLabl;

@end

@implementation ViewController
- (void)dealloc
{
    self.srv = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.showLabl.text = @"链接中";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showStr:) name:@"showStrNotify" object:nil];
    
    SockService *service = [SockService new];
    [service buildServer];
    self.srv = service;
    
    __weak typeof (self) weakSelf = self;
    self.srv.receBock = ^(NSString * _Nonnull str) {
        NSLog(@"str----->%@",str);
        weakSelf.showLabl.text = str;
    };
}

- (void)showStr:(NSNotification *)notify
{
    NSString *str = (NSString *)notify.object;
    self.showLabl.text = str;
}


@end
