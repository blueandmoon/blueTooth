//
//  ViewController.m
//  blueToothExample
//
//  Created by 李根 on 16/9/20.
//  Copyright © 2016年 ligen. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()<CBCentralManagerDelegate>
@property (weak, nonatomic) IBOutlet UIView *btIndicator;
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
@property (weak, nonatomic) IBOutlet UIButton *connect;
@property(nonatomic, strong)CBCentralManager *manager;
@property(nonatomic, assign)BOOL isOpen;    //  蓝牙开启是否
@property(nonatomic, strong)NSMutableArray *peripheralArr;  //  扫描到的外设数组
@property(nonatomic, strong)CBPeripheral *activePeriphera;  //  当前连接到的peripheral
@property(nonatomic, strong)CBPeripheral *periphera;    //  当前选择的peripheral


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    _peripheralArr = [NSMutableArray array];
    _manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    
    
    
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    _isOpen = NO;
    _btIndicator.backgroundColor = [UIColor redColor];
    switch (central.state) {
        case CBCentralManagerStatePoweredOn: {
            NSLog(@"CBCentralManagerStatePoweredOn, 蓝牙打开🔛");
            _btIndicator.backgroundColor = [UIColor greenColor];
            _isOpen = YES;
        } break;
        case CBCentralManagerStateUnknown: {
            NSLog(@"CBCentralManagerStateUnknown");
        } break;
        case CBCentralManagerStatePoweredOff: {
            NSLog(@"CBCentralManagerStatePoweredOff, 蓝牙关闭");
        } break;
        case CBCentralManagerStateResetting: {
            NSLog(@"CBCentralManagerStateResetting");
        } break;
        case CBCentralManagerStateUnsupported: {
            NSLog(@"CBCentralManagerStateUnsupported");
        } break;
        case CBCentralManagerStateUnauthorized: {
            NSLog(@"CBCentralManagerStateUnauthorized");
        } break;
            
        default:
            break;
    }
}
- (IBAction)connectAction:(id)sender {
}
- (IBAction)scanAction:(id)sender {
    [_peripheralArr removeAllObjects];
    
    [_manager scanForPeripheralsWithServices:nil options:nil];
    [_scanBtn setTitle:@"scaning" forState:UIControlStateNormal];
    
    double delayTime = 5.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_manager stopScan];
    });
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"-------%@", peripheral.name);
    
    //  将扫描到的设备存到数组中
    if (peripheral.name != NULL) {
        NSDictionary *dic = [NSDictionary dictionaryWithObject:peripheral forKey:peripheral.name];
        [_peripheralArr addObject:dic];
        NSLog(@"设备数量: %lu", (unsigned long)_peripheralArr.count);
    }
    
    [_scanBtn setTitle:@"scan" forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
