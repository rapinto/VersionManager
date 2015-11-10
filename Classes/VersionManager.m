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



- (enum VersionManagerStatus)currentVersionStatus
{
    NSString* lMinimumAllowedVersion = [self getMinimumAllowedVersion];
    NSString* lCurrentAppVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString* lLastAvailableVersion = [self getLastDisplayedAvailableVersion];
    
    
    if (lCurrentAppVersion && [lCurrentAppVersion isKindOfClass:[NSString class]] && [lCurrentAppVersion length] > 0)
    {
        [self saveLastDisplayedAvailableVersion:lCurrentAppVersion];
        
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


- (void)setMinimumAllowedVersion:(float)_MinimumAllowedVersion lastAvailableVersion:(float)_LastAvailableVersion
{
    [self saveLastDisplayedAvailableVersion:[NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:_LastAvailableVersion]]];
    [self saveMinimumAllowedVersion:[NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:_MinimumAllowedVersion]]];
    
    [[VersionManager sharedInstance] checkVersion];
}


- (void)checkVersion
{
    switch ([self currentVersionStatus])
    {
        case kVersionManagerStatusNotUpToDate:
        {
            if ([self needToDisplayNewVersionAvailable])
            {
                if (_delegate && [_delegate respondsToSelector:@selector(newAppVersionAvailable)])
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


- (BOOL)needToDisplayNewVersionAvailable
{
    NSString* lCurrentAppVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    NSString* lLastDisplayAvailableVersion = [self getLastDisplayedAvailableVersion];
    if ([self currentVersionStatus] == kVersionManagerStatusNotUpToDate &&
        (lLastDisplayAvailableVersion == nil ||
         (lLastDisplayAvailableVersion && lCurrentAppVersion && [lLastDisplayAvailableVersion floatValue] < [lCurrentAppVersion floatValue])))
    {
        [self saveLastDisplayedAvailableVersion:[NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:[lCurrentAppVersion floatValue]]]];
        
        return YES;
    }
    
    return NO;
}



#pragma mark -
#pragma mark Private Methods



- (void)saveLastDisplayedAvailableVersion:(NSString*)lastDisplayedAvailableVersion
{
    NSUserDefaults* lUserDefaults = nil;
    
    if (_appGroup)
    {
        lUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:_appGroup];
    }
    else
    {
        lUserDefaults = [NSUserDefaults standardUserDefaults];
    }
    
    [lUserDefaults setObject:lastDisplayedAvailableVersion forKey:kLastAvailableVersion];
    [lUserDefaults synchronize];
}


- (NSString*)getLastDisplayedAvailableVersion
{
    NSUserDefaults* lUserDefaults = nil;
    
    if (_appGroup)
    {
        lUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:_appGroup];
    }
    else
    {
        lUserDefaults = [NSUserDefaults standardUserDefaults];
    }
    
    
    return (NSString*)[lUserDefaults objectForKey:kLastAvailableVersion];
}


- (void)saveMinimumAllowedVersion:(NSString*)minimumAllowedVersion
{
    NSUserDefaults* lUserDefaults = nil;
    
    if (_appGroup)
    {
        lUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:_appGroup];
    }
    else
    {
        lUserDefaults = [NSUserDefaults standardUserDefaults];
    }
    
    [lUserDefaults setObject:minimumAllowedVersion forKey:kMinimumAllowedVersion];
    [lUserDefaults synchronize];
}


- (NSString*)getMinimumAllowedVersion
{
    NSUserDefaults* lUserDefaults = nil;
    
    if (_appGroup)
    {
        lUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:_appGroup];
    }
    else
    {
        lUserDefaults = [NSUserDefaults standardUserDefaults];
    }
    
    
    return (NSString*)[lUserDefaults objectForKey:kMinimumAllowedVersion];
}

@end
