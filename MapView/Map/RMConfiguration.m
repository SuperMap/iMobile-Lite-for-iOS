//
//  RMConfiguration.m
//
// Copyright (c) 2008-2009, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import "RMConfiguration.h"
#import "MapView_Prefix.pch"

static RMConfiguration* RMConfigurationSharedInstance = nil;

@implementation RMConfiguration

+ (RMConfiguration*) configuration
{
	
	@synchronized (RMConfigurationSharedInstance) {
		if (RMConfigurationSharedInstance != nil) return RMConfigurationSharedInstance;
	
		/// \bug magic string literals
		RMConfigurationSharedInstance = [[RMConfiguration alloc] 
										 initWithPath: [[NSBundle mainBundle] pathForResource:@"routeme" ofType:@"plist"]];

		return RMConfigurationSharedInstance;
	}
	return nil;
}


- (RMConfiguration*) initWithPath: (NSString*) path
{
	self = [super init];
	
	if (self==nil) return nil;
	
	NSData *plistData;
	NSString *error;
	NSPropertyListFormat format;

	if (path==nil) 
	{
		propList = nil;
		return self;
	}
	
	RMLog(@"reading configuration from %@", path);	
	plistData = [NSData dataWithContentsOfFile:path];

	propList = [[NSPropertyListSerialization 
					propertyListFromData:plistData
					mutabilityOption:NSPropertyListImmutable
					format:&format
					errorDescription:&error] retain];

	if(!propList)
	{
		RMLog(@"problem reading from %@: %@", path, error);
		[error release];
	}

	return self;
}
	

- (void) dealloc
{
	[propList release];
	[super dealloc];
}


- (NSDictionary*) cacheConfiguration
{
	if (propList==nil) return nil;
	/// \bug magic string literals
	return [propList objectForKey: @"caches"];
}

@end
