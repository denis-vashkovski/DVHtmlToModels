//
//  DVHtmlToModels.h
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DVHtmlToModelsCompletionBlock)(NSDictionary *data, NSData *htmlData);

@interface DVHtmlToModels : NSObject
+ (instancetype) alloc __attribute__((unavailable("alloc not available, call initWithContextByName: instead")));
- (instancetype) init __attribute__((unavailable("init not available, call initWithContextByName: instead")));
+ (instancetype) new __attribute__((unavailable("new not available, call initWithContextByName: instead")));

+ (instancetype)htmlToModelsWithContextByName:(NSString *)contextName;
+ (instancetype)htmlToModelsWithContextOfFile:(NSString *)path;
+ (instancetype)htmlToModelsWithContext:(NSDictionary *)context;

- (instancetype)initWithContextByName:(NSString *)contextName;
- (instancetype)initWithContextOfFile:(NSString *)path;
- (instancetype)initWithContext:(NSDictionary *)context;

@property (nonatomic, copy, readonly) NSString *url;

- (void)loadDataWithReplacingURLParameters:(NSArray<NSString *> *)replacingURLParameters
                        queryURLParameters:(NSDictionary *)queryURLParameters
                                    asJSON:(BOOL)asJSON
                         completionHandler:(DVHtmlToModelsCompletionBlock)completionHandler;

- (void)loadDataWithCompletionHandler:(DVHtmlToModelsCompletionBlock)completionHandler;
@end
