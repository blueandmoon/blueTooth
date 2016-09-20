//
//  ViewController.m
//  blueToothExample
//
//  Created by 李根 on 16/9/20.
//  Copyright © 2016年 ligen. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()<CBCentralManagerDelegate, CBPeripheralDelegate>
@property (weak, nonatomic) IBOutlet UIView *btIndicator;
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
@property (weak, nonatomic) IBOutlet UIButton *connect;
@property (weak, nonatomic) IBOutlet UIButton *writeBtn;
@property(nonatomic, strong)CBCentralManager *manager;
@property(nonatomic, assign)BOOL isOpen;    //  蓝牙开启是否
@property(nonatomic, strong)NSMutableArray *peripheralArr;  //  扫描到的外设数组
@property(nonatomic, strong)CBPeripheral *activePeriphera;  //  当前连接到的peripheral
@property(nonatomic, strong)CBPeripheral *periphera;    //  当前选择的peripheral
@property(nonatomic, strong)CBCharacteristic *characteristic;


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

#pragma mark    - connect
- (IBAction)connectAction:(id)sender {
    NSLog(@"开始连接蓝牙: %lu", _peripheralArr.count);
    _activePeriphera = _peripheralArr[0];   //  连接第一个设备
    [_manager connectPeripheral:_activePeriphera options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [_connect setTitle:@"connected" forState:UIControlStateNormal];
    NSLog(@"didConnectPeripheral: %@", peripheral.name);
    NSLog(@"peripheral.identifier %@", peripheral.identifier);
    
    //  查找服务
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    
    NSLog(@"activicePeripheral.services: %@", peripheral.services);
    for (CBService *service in peripheral.services) {
        NSLog(@"service.UUID-----%@", service.UUID);
        
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"9FA480E0-4967-4542-9390-D343DC5D04AE"]]) {
//            NSLog(@"有了");
            NSLog(@"activicePeripheral.services: %@", peripheral.services);
            [peripheral discoverCharacteristics:nil forService:service];    //  发现特征
        } else {
//            NSLog(@"无");
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [_connect setTitle:@"connect" forState:UIControlStateNormal];
    NSLog(@"didFailToConnectPeripheral");
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [_connect setTitle:@"connect" forState:UIControlStateNormal];
    NSLog(@"didDisconnectPeripheral");
}

#pragma mark    - scan
- (IBAction)scanAction:(id)sender {
    [_peripheralArr removeAllObjects];
    
    [_manager scanForPeripheralsWithServices:nil options:nil];
    [_scanBtn setTitle:@"scaning" forState:UIControlStateNormal];
    
    double delayTime = 3.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_manager stopScan];
        NSLog(@"扫描到的设备数量: %lu", _peripheralArr.count);
    });
}

#pragma mark    - discover
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"--discoverPeripheral-----%@", peripheral.name);
    
    //  将扫描到的设备存到数组中
//    if (peripheral.name != NULL) {
////        NSDictionary *dic = [NSDictionary dictionaryWithObject:peripheral forKey:peripheral.name];
//        [_peripheralArr addObject:peripheral];
//        NSLog(@"设备数量: %lu", (unsigned long)_peripheralArr.count);
//    }
    
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"9FA480E0-4967-4542-9390-D343DC5D04AE"]]) {
            NSLog(@"哈哈哈哈哈😁");
        }
    }
    
    
    if (![_peripheralArr containsObject:peripheral]) {  //  不包括, 怎么加入
        [_peripheralArr addObject:peripheral];
        
    }
    
    [_scanBtn setTitle:@"scan" forState:UIControlStateNormal];
    
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"didDiscoverCharacteristicsForService error: %@", error.localizedDescription);
    } else {
        NSLog(@"service.characteristics: %@", service.characteristics);
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"AF0BADB1-5B99-43CD-917A-A77BC549E3CC"]]) {
                NSLog(@"characteristic: %@", characteristic);
                
                _characteristic = characteristic;
                [_activePeriphera setNotifyValue:YES forCharacteristic:_characteristic];
            }
        }
    }
}

#pragma mark    - 写数据
- (void)writeChar:(NSData *)data {
    [_activePeriphera writeValue:data forCharacteristic:_characteristic type:CBCharacteristicWriteWithResponse];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"didWriteValueForCharacteristic error: %@", error.localizedDescription);
    } else {
        NSLog(@"写入数据成功啦");
    }
}

- (IBAction)writeAction:(id)sender {
    
    NSString *str = @"Base";
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    [self writeChar:data];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
