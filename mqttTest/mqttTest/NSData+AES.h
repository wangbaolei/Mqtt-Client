//
//  NSData+AES.h
//  mqttTest
//
//  Created by coder on 2018/3/20.
//  Copyright © 2018年 WBL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES)
/**
 * Encrypt NSData using AES256 with a given symmetric encryption key.
 * @param key The symmetric encryption key
 */
- (NSData *)AES256EncryptWithKey:(NSString *)key;

/**
 * Decrypt NSData using AES256 with a given symmetric encryption key.
 * @param key The symmetric encryption key
 */
- (NSData *)AES256DecryptWithKey:(NSString *)key;

@end
