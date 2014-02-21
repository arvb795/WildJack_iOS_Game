
#import "MenuScene.h"
#import "HelloWorldScene.h"

@implementation MenuLayer


-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		
		CCSprite *menuback = [CCSprite spriteWithFile:@"menuback.png"];
		[menuback setPosition:ccp(240,160)];
		[self addChild:menuback];
		
		
		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"new.png" selectedImage:@"new.png"
															   target:self
															 selector:@selector(onEnter:)];
		
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"credits.png" selectedImage:@"credits.png"
															   target:self
															 selector:@selector(doThis:)];
								  
		CCMenu *menu = [CCMenu menuWithItems:item1,item2, nil];
		
		[menu alignItemsVertically];
		
		[self addChild:menu];
		
		
		}
	return self;
}


-(void)doThis:(id)sender
{	
	
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"CREDITS" 
						  message:@"Aeshvarya Verma"
						  delegate:nil 
						  cancelButtonTitle:@"Ok" 
						  otherButtonTitles:nil]; 
	[alert show];
	[alert release];
	
}


- (void)onEnter:(id)sender {
	
	[[CCDirector sharedDirector]replaceScene:[CCZoomFlipAngularTransition transitionWithDuration:1 scene: [HelloWorld scene]]];
	
	
}


- (void)dealloc {
	
	[super dealloc];
}

@end