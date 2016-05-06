//
//  ViewController.m
//  XXBKeychainDemo
//
//  Created by xiaobing on 16/5/6.
//  Copyright © 2016年 xiaobing. All rights reserved.
//

#import "ViewController.h"
#import <Security/Security.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textFiled;
- (IBAction)saveMessage:(id)sender;
- (IBAction)getMessage:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ViewController
static NSString *serviceName = @"com.xiaoxiaobing.com";

- (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    [searchDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrAccount];
    [searchDictionary setObject:serviceName forKey:(id)kSecAttrService];
    return searchDictionary;
}

- (NSData *)searchKeychainCopyMatching:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    
    // Add search attributes
    [searchDictionary setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    
    // Add search return types
    [searchDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    CFDataRef attributes;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, (CFTypeRef *)&attributes);
    if (status == errSecSuccess) {
        NSData *passDat = (__bridge_transfer NSData *)attributes;
        
        return passDat;
    }
    return nil;
}

- (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier {
    NSMutableDictionary *dictionary = [self newSearchDictionary:identifier];
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [dictionary setObject:passwordData forKey:(id)kSecValueData];
    OSStatus status = SecItemAdd((CFDictionaryRef)dictionary, NULL);
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

- (BOOL)updateKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier {
    
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [updateDictionary setObject:passwordData forKey:(id)kSecValueData];
    
    OSStatus status = SecItemUpdate((CFDictionaryRef)searchDictionary,
                                    (CFDictionaryRef)updateDictionary);
    
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

- (void)deleteKeychainValue:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    SecItemDelete((CFDictionaryRef)searchDictionary);
}

- (IBAction)saveMessage:(id)sender {
    [self createKeychainValue:@"hello" forIdentifier:@"pasword"];
    [self updateKeychainValue:@"upname" forIdentifier:@"name"];
}

- (IBAction)getMessage:(id)sender {
    NSData *passwordData = [self searchKeychainCopyMatching:@"name"];
    if (passwordData) {
        NSString *password = [[NSString alloc] initWithData:passwordData
                                                   encoding:NSUTF8StringEncoding];
        self.label.text = password;
    }
}
@end
