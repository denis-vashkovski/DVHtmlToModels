//
//  DVHtmlToModels.h
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DVHtmlToModels : NSObject
- (void)prepareContextByName:(NSString *)contextName;
- (NSDictionary *)loadData;
@end
