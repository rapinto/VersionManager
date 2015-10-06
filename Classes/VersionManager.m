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




#define kMinimumAllowedVersion              @"kMinimumAllowedVersion"
#define kLastAvailableVersion               @"LastAvailableVersion"
#define kLastInstalledVersion               @"LastInstalledVersion"
#define kLastDisplayedAvailalbleVersion     @"LastDisplayedAvailalbleVersion"



#import "VersionManager.h"



@implementation VersionManager



#pragma mark -
#pragma mark Singleton Methods



static VersionManager* sharedInstance = nil;



+ (VersionManager*)sharedInstance
{
    if (!sharedInstance)
    {
        sharedInstance = [[VersionManager alloc] init];
    }
    
    return sharedInstance;
}



#pragma mark -
#pragma mark Version Management Methods



+ (enum VersionManagerStatus)currentVersionStatus
{
    NSString* lMinimumAllowedVersion = [[NSUserDefaults standardUserDefaults] valueForKey:kMinimumAllowedVersion];
    NSString* lCurrentAppVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString* lLastAvailableVersion = [[NSUserDefaults standardUserDefaults] valueForKey:kLastAvailableVersion];
    
    
    if (lCurrentAppVersion && [lCurrentAppVersion isKindOfClass:[NSString class]] && [lCurrentAppVersion length] > 0)
    {
        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.Dealabs"];
        [shared setValue:lCurrentAppVersion forKey:kLastInstalledVersion];
        [shared synchronize];
        
        // Version too old : display mandatory View
        if (lMinimumAllowedVersion && lCurrentAppVersion && [lMinimumAllowedVersion floatValue] > [lCurrentAppVersion floatValue])
        {
            return kVersionManagerStatusObsolete;
        }
        else
        {
            if (lLastAvailableVersion && lCurrentAppVersion && [lLastAvailableVersion floatValue] > [lCurrentAppVersion floatValue])
            {
                return kVersionManagerStatusNotUpToDate;
            }
            else
            {
                return kVersionManagerStatusUpToDate;
            }
        }
    }
    else
    {
        return kVersionManagerStatusUpToDate;
    }
}


+ (void)setMinimumAllowedVersion:(float)_MinimumAllowedVersion lastAvailableVersion:(float)_LastAvailableVersion
{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.Dealabs"];
    [shared setObject:[NSNumber numberWithFloat:_MinimumAllowedVersion] forKey:kMinimumAllowedVersion];
    [shared setObject:[NSNumber numberWithFloat:_LastAvailableVersion] forKey:kLastAvailableVersion];
    [shared synchronize];
    
    [[VersionManager sharedInstance] checkVersion];
}


- (void)checkVersion
{
    switch ([VersionManager currentVersionStatus])
    {
        case kVersionManagerStatusNotUpToDate:
        {
            if ([VersionManager needToDisplayNewVersionAvailable])
            {
                if (__delegate && [_delegate respondsToSelector:@selector(newAppVersionAvailable)])
                {
                    [_delegate newAppVersionAvailable];
                }
            }
            break;
        }
        case kVersionManagerStatusObsolete:
        {
            if (_delegate && [_delegate respondsToSelector:@selector(appVersionIsObsolete)])
            {
                [_delegate appVersionIsObsolete];
            }
            break;
        }
        case kVersionManagerStatusUpToDate:
        default:
        {
            break;
        }
    }
}


+ (BOOL)needToDisplayNewVersionAvailable
{
    NSString* lCurrentAppVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.Dealabs"];
    
    NSString* lLastDisplayAvailableVersion = [shared valueForKey:kLastDisplayedAvailalbleVersion];
    if ([VersionManager currentVersionStatus] == kVersionManagerStatusNotUpToDate &&
        (lLastDisplayAvailableVersion == nil ||
         (lLastDisplayAvailableVersion && lCurrentAppVersion && [lLastDisplayAvailableVersion floatValue] < [lCurrentAppVersion floatValue])))
    {
        [shared setObject:[NSNumber numberWithFloat:[lCurrentAppVersion floatValue]] forKey:kLastDisplayedAvailalbleVersion];
        [shared synchronize];
        
        return YES;
    }
    
    return NO;
}



@end
