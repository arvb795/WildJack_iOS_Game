
#import "cocos2d.h"

@interface GameOverLayer : CCColorLayer
{
	CCLabel *_label;
	}
@property (nonatomic, retain) CCLabel *label;
@end

@interface GameOverScene : CCScene
{
	GameOverLayer *_layer;
	}
@property (nonatomic, retain) GameOverLayer *layer;

@end