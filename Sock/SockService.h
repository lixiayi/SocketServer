//
//  SockService.h
//  Sock
//
//  Created by stoicer on 2022/9/21.
//

#import <Foundation/Foundation.h>

//#import <netinet/in.h>

NS_ASSUME_NONNULL_BEGIN

@interface SockService : NSObject

@property (nonatomic, copy) void(^receBock)(NSString *);
- (int)buildServer;

@end

NS_ASSUME_NONNULL_END
