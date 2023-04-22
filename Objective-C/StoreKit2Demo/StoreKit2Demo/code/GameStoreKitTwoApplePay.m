//
//  GameStoreKitTwoApplePay.m
//  StoreKit2Demo
//
//  Created by steve on 2023/4/21.
//

#import "GameStoreKitTwoApplePay.h"
#import "StoreKit2Demo-Bridging-Header.h"
#import "StoreKit2Demo-Swift.h"

@interface GameStoreKitTwoApplePay()
{
    BOOL _isInit;
    NSDictionary *_extraBuyData;
    SKTProduct *_product;
}
@property(copy,nonatomic) NSString *orderId;
@property(copy,nonatomic) NSString *source;
@end

@implementation GameStoreKitTwoApplePay

+ (instancetype)shareInstance {
    static GameStoreKitTwoApplePay * single = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        single = [[self alloc] init];
    });
    return single;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isInit = NO;
    }
    return self;
}

- (void)setExtraBuyData:(NSDictionary *)msg {
    _extraBuyData = msg;
}

- (void)startObserver {
    
}

- (void)applebuyProduct:(NSString *)pid oid:(NSString*)oid source:(NSString*)source {
    //    SKTwoIAP();
    if ([SKTwoIAP canMakePayments]) {
        self.orderId = oid;
        self.source = source;
        [[SKTwoIAP sharedInstance] requestProductWithPid:pid completionHandler:^(SKTProduct *product) {
            [self productsRequest:pid didReceiveResponse:product];
        }];
    }
    else{
        NSLog(@"账号没有开通支付功能");
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:1];
        [dic setObject:@"failed, not can make payments" forKey:@"msg"];
        //        [ThinkDataLogSdk onTraceByALY:@"shopping_evoke" map:dic];
        
        NSMutableDictionary *dec = [[NSMutableDictionary alloc] initWithCapacity:1];
        [dec setObject:@"no product" forKey:@"error_dec"];
        //        [GameSupportLibProxy doInvokeMessageToLua:@"apple_pay_call" msg:dec];
        return;
    }
}

- (void)productsRequest:(NSString *)productId didReceiveResponse:(SKTProduct *)product {
    if (productId == nil || [productId isEqualToString:@""] || product == nil || product.id == nil) {
        NSLog(@"接收到的商品信息为空");
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:1];
        [dic setObject:@"failed, productInfo.count is 0" forKey:@"msg"];
//        [ThinkDataLogSdk onTraceByALY:@"shopping_evoke" map:dic];
        
        NSMutableDictionary *dec = [[NSMutableDictionary alloc] initWithCapacity:1];
        [dec setObject:@"productInfo.count is 0" forKey:@"error_dec"];
//        [GameSupportLibProxy doInvokeMessageToLua:@"apple_pay_call" msg:dec];
        return;
    }
    else if (![productId isEqualToString:product.id]) {
        NSLog(@"购买商品和返回商品不符");
    }
    else {
//                for (SKProduct * pro in productInfo){
//                    NSLog(@"显示名称:%@",[pro localizedTitle]);
//                    NSLog(@"显示名称:%@",[pro localizedDescription]);
//                    NSLog(@"显示名称:%@",[pro productIdentifier]);
//                    NSLog(@"显示名称:%@",[pro price]);
//                }
    }
    
    _product = product;
    
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    [dic setObject:@"ok, got product info" forKey:@"msg"];
//    if (self.orderId) {
//        [dic setValue:self.orderId forKey:@"order_id"];
//    }
//    if (self.source) {
//        [dic setValue:self.source forKey:@"entrance"];
//    }
//    if (self.entranceId) {
//        [dic setValue:self.entranceId forKey:@"entrance_id"];
//    }
//    if (self.pageId) {
//        [dic setValue:self.pageId forKey:@"page_id"];
//    }
//    if (self.actionId) {
//        [dic setValue:self.actionId forKey:@"action_id"];
//    }
//    if (self.product) {
//        [dic setValue:[self.product price] forKey:@"goods_price"];
//        [dic setValue:[self.product localizedTitle] forKey:@"goods_name"];
//        [dic setValue:[self.product priceLocale].currencyCode forKey:@"goods_code"];
//        [dic setValue:[self.product productIdentifier] forKey:@"sku_id"];
//    }
//    [ThinkDataLogSdk onTraceByALY:@"shopping_evoke" map:dic];
}

@end
