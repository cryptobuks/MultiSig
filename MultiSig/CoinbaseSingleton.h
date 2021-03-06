//
//  CoinbaseAPIClient.h
//  MultiSig
//
//  Created by William Emmanuel on 4/6/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <coinbase-official/Coinbase.h>
#import <CoreBitcoin/CoreBitcoin.h>

@interface CoinbaseSingleton : NSObject

@property (nonatomic,strong) Coinbase *client;
@property (nonatomic,strong) BTCKeychain *keychain;

+(CoinbaseSingleton*) shared;
-(BOOL)authenticated;

@end
