//
//  VersionManager.h
//
//
//  Created by Raphael Pinto on 12/08/2015.
//
//  The MIT License (MIT)
//  Copyright (c) 2013 Raphael Pinto.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.



enum VersionManagerStatus
{
    kVersionManagerStatusUpToDate,
    kVersionManagerStatusObsolete,
    kVersionManagerStatusNotUpToDate
};



#import <Foundation/Foundation.h>


@protocol VersionManagerDelegate <NSObject>


- (void)newAppVersionAvailable;
- (void)appVersionIsObsolete;


@end



@interface VersionManager : NSObject



@property (weak, nonatomic) NSObject<VersionManagerDelegate>* delegate;
@property (nonatomic, strong) NSString* appGroup;



+ (VersionManager*)sharedInstance;

- (enum VersionManagerStatus)currentVersionStatus; // Need to be called each time the app start.
- (void)setMinimumAllowedVersion:(float)_MinimumAllowedVersion lastAvailableVersion:(float)_LastAvailableVersion;
- (BOOL)needToDisplayNewVersionAvailable;



@end
