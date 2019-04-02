//
//  Authorized.h
//  iAmGRoot
//
//  Created by Dana Buehre on 2/11/19.
//  Copyright © 2019 CreatureCoding. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Authorized : NSObject

+ (void)authorizedBlock:(void (^)(void (^_Nonnull)(void)))block;

+ (void)authorizeAsUser:(int)user group:(int)group;
+ (void)authorizeAsRoot;
+ (void)restore;

@end

NS_ASSUME_NONNULL_END
