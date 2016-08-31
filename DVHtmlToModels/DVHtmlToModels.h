//
//  DVHtmlToModels.h
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DVHtmlToModels : NSObject
+ (instancetype) alloc __attribute__((unavailable("alloc not available, call initWithContextByName: instead")));
- (instancetype) init __attribute__((unavailable("init not available, call initWithContextByName: instead")));
+ (instancetype) new __attribute__((unavailable("new not available, call initWithContextByName: instead")));

+ (instancetype)htmlToModelsWithContextByName:(NSString *)contextName;

@property (nonatomic, strong, readonly) NSString *url;

- (NSDictionary *)loadDataWithUrlParameters:(NSArray<NSString *> *)parameters;
- (NSDictionary *)loadData;
@end
