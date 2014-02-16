//
//  FMSectionEditViewLayOutStrategy.h
//  NewsColumns
//
//  Created by Apple on 14-2-14.
//  Copyright (c) 2014年 Dean. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - layout strategy protocol
@protocol FMSectionEditViewLayOutStrategy <NSObject>
- (void)setupItemSize:(CGSize)itemSize  andItemSpacing:(NSInteger)spacing withMainEdgeInsets:(UIEdgeInsets)edgeInsets andCenteredGrid:(BOOL)centered;

- (void)rebaseWithItemCount:(NSInteger)count insideOfBounds:(CGRect)bounds;

- (CGSize)contentSize;

- (CGPoint)originForItemAtPosition:(NSInteger)position;

- (NSInteger)itemPositionForLocation:(CGPoint)location;

- (NSRange)rangeOfPositionsInBoundsFromOffset:(CGPoint)offset;


@end

@interface FMSectionEditViewLayOutStrategy : NSObject

@end
