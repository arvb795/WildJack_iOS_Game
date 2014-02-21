//

// Import the interfaces
#import "SimpleAudioEngine.h"
#import "HelloWorldScene.h"
#import "GameOverScene.h"
#import "MenuScene.h"

// HelloWorld implementation
@implementation HelloWorld

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}




-(void)spriteMoveFinished:(id)sender {
	CCSprite *sprite = (CCSprite *)sender;
	[self removeChild:sprite cleanup:YES];
	GameOverScene *gameOverScene = [GameOverScene node];
	[gameOverScene.layer.label setString:@"Game Over, Team Aeshmik"];
	
	[[CCDirector sharedDirector] replaceScene:gameOverScene];
	if (sprite.tag == 1) { // target
		[_targets removeObject:sprite];
		
		} else if (sprite.tag == 2) { // projectile
		[_projectiles removeObject:sprite];
			
						
 }
}

-(void)addTarget {
	
	CCSprite *target = [CCSprite spriteWithFile:@"Target.png" 
										   rect:CGRectMake(0, 0, 27, 40)]; 
	target.tag = 1;
	[_targets addObject:target];
	
	// Determine where to spawn the target along the Y axis
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	int minY = target.contentSize.height/2;
	int maxY = winSize.height - target.contentSize.height/2;
	int rangeY = maxY - minY;
	int actualY = (arc4random() % rangeY) + minY;
	
	// Create the target slightly off-screen along the right edge,
	// and along a random position along the Y axis as calculated above
	target.position = ccp(winSize.width + (target.contentSize.width/2), actualY);
	[self addChild:target];
	
	// Determine speed of the target
	int minDuration = 2.0;
	int maxDuration = 4.0;
	int rangeDuration = maxDuration - minDuration;
	int actualDuration = (arc4random() % rangeDuration) + minDuration;
	
	// Create the actions
	id actionMove = [CCMoveTo actionWithDuration:actualDuration 
										position:ccp(-target.contentSize.width/2, actualY)];
	id actionMoveDone = [CCCallFuncN actionWithTarget:self 
											 selector:@selector(spriteMoveFinished:)];
	[target runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
	
}



// on "init" you need to initialize your instance
-(id) init
{
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
	_targets = [[NSMutableArray alloc] init];
	_projectiles = [[NSMutableArray alloc] init];	
	
	if( (self=[super initWithColor:ccc4(55,155,183,195) ] ) ) {
		_pauseScreenUp=FALSE;
				

		
		label =[CCLabel labelWithString:score fontName:@"Arial" fontSize:25];
		
		label.position=ccp(25,275);
		label.color=ccc3(0,0,0);
		
		[label setString:@"0"];
		
		[self addChild:label z:3];
		
		CCMenuItem *pauseMenuItem = [CCMenuItemImage 
									 itemFromNormalImage:@"pausebutton.gif" selectedImage:@"pausebutton.gif" 
									 target:self selector:@selector(PauseButtonTapped:)];
		pauseMenuItem.position = ccp(450, 297);
		CCMenu *upgradeMenu = [CCMenu menuWithItems:pauseMenuItem, nil];
		upgradeMenu.position = CGPointZero;
		[self addChild:upgradeMenu z:2];
		
				CGSize winSize = [[CCDirector sharedDirector] winSize];
		CCSprite *player = [CCSprite spriteWithFile:@"Player.png" 
											   rect:CGRectMake(0, 0, 27, 40)];
		
		player.position = ccp(player.contentSize.width/2, winSize.height/2);
		
		CCSprite *bg = [CCSprite spriteWithFile:@"aeshback.png"];
				[bg setPosition:ccp(240,160)];
		
		CCSprite *score1 = [CCSprite spriteWithFile:@"score.png"];
		[score1 setPosition:ccp(30,300)];
		[self addChild:score1 z:1];
		[self addChild:bg z:0];
		
		[self addChild:player z:1];
		
		self.isTouchEnabled = YES;
		
	}
	
	[self schedule:@selector(gameLogic:) interval:1.0];
	[self schedule:@selector(update:)];
	return self;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"throw.caf"];
	
	// Choose one of the touches to work with
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
	
	
	// Set up initial location of projectile
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	CCSprite *projectile = [CCSprite spriteWithFile:@"Projectile.png" 
											   rect:CGRectMake(0, 0, 20, 20)];
	projectile.position = ccp(20, winSize.height/2);
	projectile.tag = 2;
	[_projectiles addObject:projectile];		
	// Determine offset of location to projectile
	int offX = location.x - projectile.position.x;
	int offY = location.y - projectile.position.y;
	
	// Bail out if we are shooting down or backwards
	if (offX <= 0) return;
	
	// Ok to add now - we've double checked position
	[self addChild:projectile];
	
	// Determine where we wish to shoot the projectile to
	int realX = winSize.width + (projectile.contentSize.width/2);
	float ratio = (float) offY / (float) offX;
	int realY = (realX * ratio) + projectile.position.y;
	CGPoint realDest = ccp(realX, realY);
	
	// Determine the length of how far we're shooting
	int offRealX = realX - projectile.position.x;
	int offRealY = realY - projectile.position.y;
	float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
	float velocity = 480/1; // 480pixels/1sec
	float realMoveDuration = length/velocity;
	
	// Move projectile to actual endpoint
	[projectile runAction:[CCSequence actions:
						   [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
						   [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
						   nil]];
	
}




-(void)gameLogic:(ccTime)dt {
	[self addTarget];
}

- (void)update:(ccTime)dt {
	
	NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
	for (CCSprite *projectile in _projectiles) {
		CGRect projectileRect = CGRectMake(
										   projectile.position.x - (projectile.contentSize.width/2), 
										   projectile.position.y - (projectile.contentSize.height/2), 
										   projectile.contentSize.width, 
										   projectile.contentSize.height);
		
		NSMutableArray *targetsToDelete = [[NSMutableArray alloc] init];
		for (CCSprite *target in _targets) {
			CGRect targetRect = CGRectMake(
										   target.position.x - (target.contentSize.width/2), 
										   target.position.y - (target.contentSize.height/2), 
										   target.contentSize.width, 
										   target.contentSize.height);
			
			if (CGRectIntersectsRect(projectileRect, targetRect)) {
				[targetsToDelete addObject:target];				
			}						
		}
		
		for (CCSprite *target in targetsToDelete) {
			[_targets removeObject:target];
			[self removeChild:target cleanup:YES];
			_projectilesDestroyed++;
			
			[label setString:[NSString stringWithFormat:@"%i", _projectilesDestroyed ]];
			
				if (_projectilesDestroyed > 200000000) {
				GameOverScene *gameOverScene = [GameOverScene node];
				[gameOverScene.layer.label setString:@"You Win!"];
				[[CCDirector sharedDirector] replaceScene:gameOverScene];
				
			}
		}
		
		
		    if (targetsToDelete.count > 0) {
			[projectilesToDelete addObject:projectile];
		}
		[targetsToDelete release];
	}
	
	for (CCSprite *projectile in projectilesToDelete) {
		[_projectiles removeObject:projectile];
		[self removeChild:projectile cleanup:YES];
	}
	[projectilesToDelete release];

}

-(void)PauseButtonTapped:(id)sender
{
	//NSLog(@"pausebutton");
	if(_pauseScreenUp ==FALSE)
	{
		_pauseScreenUp=TRUE;
		//if you have music uncomment the line bellow
		//[[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
		[[CCDirector sharedDirector] pause];
		CGSize s = [[CCDirector sharedDirector] winSize];
		pauseLayer = [CCColorLayer layerWithColor: ccc4(150, 150, 150, 125) width: s.width height: s.height];
		
		pauseLayer.position = CGPointZero;
		[self addChild: pauseLayer z:8];
		
		_pauseScreen =[[CCSprite spriteWithFile:@"pauseBackground.gif"] retain];
		_pauseScreen.position= ccp(250,150);
		[self addChild:_pauseScreen z:8];
		
		CCMenuItem *ResumeMenuItem = [CCMenuItemImage 
									  itemFromNormalImage:@"continuebutton.gif" selectedImage:@"continuebutton.gif" 
									  target:self selector:@selector(ResumeButtonTapped:)];
		ResumeMenuItem.position = ccp(250, 190);
		CCMenuItem *QuitMenuItem = [CCMenuItemImage 
									itemFromNormalImage:@"Exitbutton.gif" selectedImage:@"Exitbutton.gif" 
									target:self selector:@selector(QuitButtonTapped:)];
		QuitMenuItem.position = ccp(250, 100);
		_pauseScreenMenu = [CCMenu menuWithItems:ResumeMenuItem,QuitMenuItem, nil];
		_pauseScreenMenu.position = ccp(0,0);
		[self addChild:_pauseScreenMenu z:10];
		//[[CCDirector sharedDirector] stopAnimation];
		//_pauseScreenUp=TRUE;
		
	}
}
-(void)ResumeButtonTapped:(id)sender{
	[self removeChild:_pauseScreen cleanup:YES];
	[self removeChild:_pauseScreenMenu cleanup:YES];
	[self removeChild:pauseLayer cleanup:YES];
	[[CCDirector sharedDirector] resume];
	_pauseScreenUp=FALSE;
}
-(void)QuitButtonTapped:(id)sender{
	[self removeChild:_pauseScreen cleanup:YES];
	[self removeChild:_pauseScreenMenu cleanup:YES];
	[self removeChild:pauseLayer cleanup:YES];
	
	[[CCDirector sharedDirector] resume];
	_pauseScreenUp=FALSE;
	[[CCDirector sharedDirector]replaceScene:[CCZoomFlipAngularTransition transitionWithDuration:0.5f scene: [MenuLayer node]]];
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	[_targets release];
	_targets = nil;
	[_projectiles release];
	_projectiles = nil;
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end


