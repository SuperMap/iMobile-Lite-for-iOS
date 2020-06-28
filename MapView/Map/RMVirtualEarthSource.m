//
//  RMVirtualEarthURL.m
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

#import "RMVirtualEarthSource.h"
#import "MapView_Prefix.pch"


@implementation RMVirtualEarthSource
- (id) init
{
	return [self initWithHybridThemeUsingAccessKey:@""];
}

- (id) initWithAerialThemeUsingAccessKey:(NSString *)developerAccessKey
{
	RMLog(@"please see comments in RMVirtualEarthSource.h");
	NSAssert(([developerAccessKey length] > 0), @"Virtual Earth access key must be non-empty");
	if (self = [super init])
	{
		[self setMaxZoom:18];
		[self setMinZoom:1];
		
		maptypeFlag = @"a";
		accessKey = developerAccessKey;
		_shortName = @"Microsoft Virtual Earth satellite";
	}
	return self;
}

- (id) initWithRoadThemeUsingAccessKey:(NSString *)developerAccessKey
{
	RMLog(@"please see comments in RMVirtualEarthSource.h");
	NSAssert(([developerAccessKey length] > 0), @"Virtual Earth access key must be non-empty");
	if (self = [super init])
	{
		[self setMaxZoom:18];
		[self setMinZoom:1];
		
		maptypeFlag = @"r";
		accessKey = developerAccessKey;
		_shortName = @"Microsoft Virtual Earth roads";
	}
	return self;
}
- (id) initWithHybridThemeUsingAccessKey:(NSString *)developerAccessKey
{
	RMLog(@"please see comments in RMVirtualEarthSource.h");
	NSAssert(([developerAccessKey length] > 0), @"Virtual Earth access key must be non-empty");
	if (self = [super init]) 
	{
		[self setMaxZoom:18];
		[self setMinZoom:1];
		
		maptypeFlag = @"h";
		accessKey = developerAccessKey;
		_shortName = @"Microsoft Virtual Earth hybrid";
	}
	return self;
}

-(NSString*) tileURL: (RMTile) tile
{
	NSString *quadKey = [self quadKeyForTile:tile];
	return [self urlForQuadKey:quadKey];
}

-(NSString*) quadKeyForTile: (RMTile) tile
{
	NSAssert4(((tile.zoom >= self.minZoom) && (tile.zoom <= self.maxZoom)),
			  @"%@ tried to retrieve tile with zoomLevel %d, outside source's defined range %f to %f", 
			  self, tile.zoom, self.minZoom, self.maxZoom);
	NSMutableString *quadKey = [NSMutableString string];
	for (int i = tile.zoom; i > 0; i--)
	{
		int mask = 1 << (i - 1);
		int cell = 0;
		if ((tile.x & mask) != 0)
		{
			cell++;
		}
		if ((tile.y & mask) != 0)
		{
			cell += 2;
		}
		[quadKey appendString:[NSString stringWithFormat:@"%d", cell]];
	}
	return quadKey;
}

-(NSString*) urlForQuadKey: (NSString*) quadKey 
{
	NSString *mapExtension = @".png"; //extension
	
	//TODO what is the ?g= hanging off the end 1 or 15?
	return [NSString stringWithFormat:@"http://%@%d.ortho.tiles.virtualearth.net/tiles/%@%@%@?g=15", maptypeFlag, 3, maptypeFlag, quadKey, mapExtension];
}

-(NSString*) uniqueTilecacheKey
{
	return [NSString stringWithFormat:@"MicrosoftVirtualEarth%@", maptypeFlag];
}

-(NSString *)shortName
{
	return _shortName;
}
-(NSString *)longDescription
{
	return @"Microsoft Virtual Earth. All data © Microsoft or their licensees.";
}
-(NSString *)shortAttribution
{
	return @"© Microsoft Virtual Earth";
}
-(NSString *)longAttribution
{
	return @"Map data © Microsoft Virtual Earth.";
}

@end
