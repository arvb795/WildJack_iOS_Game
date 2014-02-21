
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"


// HelloWorld Layer
@interface HelloWorld : CCColorLayer
{
	NSMutableArray *_targets;
	NSMutableArray *_projectiles;
	int _projectilesDestroyed;
	bool _pauseScreenUp;
	CCLayer *pauseLayer;
	CCSprite *_pauseScreen;
	CCMenu *_pauseScreenMenu;
	NSString *score;
	CCLabel *label;
	
	
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;



@end




