# DVHtmlToModels

Parse html to models.

## Installation
*DVHtmlToModels requires iOS 7.1 or later.*

### iOS 7

1.  Install [hpple](https://github.com/topfunky/hpple#installation)
2.  Copying all the files from DVHtmlToModels folder into your project.
3.  Make sure that the files are added to the Target membership.

### Using [CocoaPods](http://cocoapods.org)

1.  Add the pod `hpple` to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html).

        pod 'hpple', :git => 'https://github.com/topfunky/hpple.git'
        
2.  Add the pod `DVHtmlToModels`.

        pod 'DVHtmlToModels', :git => 'https://github.com/denis-vashkovski/DVHtmlToModels.git'

3.  Run `pod install` from Terminal, then open your app's `.xcworkspace` file to launch Xcode.

## Basic Usage

Create a `.plist` context file.

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>url</key>
	<string>https://example.com/example.html</string>
	<key>data</key>
	<array>
		<dict>
			<key>xPathRoot</key>
			<string>//xPath</string>
			<key>className</key>
			<string>ClassName1</string>
			<key>fields</key>
			<array>
				<dict>
					<key>name</key>
					<string>field1</string>
					<key>result</key>
					<array>
						<dict>
							<key>xPath</key>
							<string>//xPath</string>
							<key>attribute</key>
							<string>attribute1</string>
							<key>regex</key>
							<string>regex1</string>
							<key>formats</key>
							<array>
								<dict>
									<key>conditions</key>
									<array>
										<dict>
											<key>regex</key>
											<string>regex1</string>
											<key>negative</key>
											<true/>
										</dict>
									</array>
									<key>format</key>
									<string>http://example.com%@</string>
								</dict>
								<dict>
									<key>type</key>
									<string>date</string>
									<key>format</key>
									<string>dd.MM.yyyy</string>
								</dict>
							</array>
						</dict>
					</array>
				</dict>
				<dict>
					<key>name</key>
					<string>field2</string>
					<key>result</key>
					<array>
						<dict>
						        <!--
                                        If field is a custom object
                                -->
							<key>data</key>
							<dict>
							        ...
							</dict>
						</dict>
					</array>
				</dict>
			</array>
		</dict>
	</array>
</dict>
</plist>
```

Create a classes for models.

``` objective-c
@interface ClassName1 : NSObject
@property (nonatomic, strong) NSString *field1;
@property (nonatomic, strong) ClassName2 *field2;
@end
```

Import the class header.

``` objective-c
#import "DVHtmlToModels.h"
```
Just create `DVHtmlToModels` instance with context.

``` objective-c
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	DVHtmlToModels *htmlToModels = [DVHtmlToModels htmlToModelsWithContextByName:@"context_example"];
    NSDictionary *data = [htmlToModels loadData];
    if (data) {
        self.models = data[NSStringFromClass([ClassName1 class])];
    }
}
```

## Demo

Build and run the `DVHtmlToModels_Example` project in Xcode to see `DVHtmlToModels` in action.

## Contact

Denis Vashkovski

- https://github.com/denis-vashkovski
- denis.vashkovski.vv@gmail.com

## License

This project is is available under the MIT license. See the LICENSE file for more info. Attribution by linking to the [project page](https://github.com/denis-vashkovski/DVHtmlToModels) is appreciated.
