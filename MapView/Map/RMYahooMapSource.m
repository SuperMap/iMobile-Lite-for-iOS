//
//  RMYahooMapSource.m
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

#import "RMYahooMapSource.h"
#import <math.h>


@implementation RMYahooMapSource

- (id) init
{ 
	if(self = [super init])
	{
		[self setMaxZoom:18]; 
		[self setMinZoom:1];
	}
	
	return self;
}

- (NSString*) tileURL: (RMTile) tile
{
	NSInteger zoom = kDefaultMaxTileZoom - tile.zoom;
	NSInteger shift = tile.zoom -1;
	NSInteger x = tile.x;
	NSInteger y = pow(2,shift)-1-tile.y;
	NSString *tileThing = [NSString stringWithFormat:@"http://us.maps2.yimg.com/us.png.maps.yimg.com/png?v=3.1.0&t=m&x=%d&y=%d&z=%d",
						   [[NSNumber numberWithUnsignedLong:x] intValue], [[NSNumber numberWithUnsignedLong:y] intValue],[[NSNumber numberWithUnsignedLong:zoom] intValue]];
//	NSLog(@"%@",tileThing);
	return tileThing;
	
}

-(NSString*) uniqueTilecacheKey
{
	return @"YahooMaps";
}

-(NSString *)shortName
{
	return @"Yahoo Map";
}

-(NSString *)longDescription
{
	return @"Yahoo Maps are severely restricted by Terms of Service for typical Route-Me applications. This sample code is for demonstration purposes only.";
}

-(NSString *)shortAttribution
{
	return @"© Yahoo Maps";
}

-(NSString *)longAttribution
{
	return @"© Map data © Yahoo, though the way we are accessing these tiles is against the Yahoo Terms of Service.";
}

@end
