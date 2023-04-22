//
//  GameStoreKitTwoApplePay.h
//  StoreKit2Demo
//
//  Created by steve on 2023/4/21.
//

#import <Foundation/Foundation.h>

@interface GameStoreKitTwoApplePay : NSObject

+ (instancetype)shareInstance;

- (void)setExtraBuyData:(NSString *)msg;
- (void)startObserver;
- (void)applebuyProduct:(NSString *)pid oid:(NSString*)oid source:(NSString*)source;

@end

