package;

#if desktop
import cpp.abi.Abi;
#end
import flixel.graphics.FlxGraphic;
import flixel.FlxCamera;
import flixel.addons.plugin.taskManager.FlxTask;
import flixel.group.FlxSpriteGroup;
import flixel.addons.ui.FlxUIGroup;
import flixel.ui.FlxButton;
import flixel.FlxObject;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.ColorTween;
import flixel.util.FlxStringUtil;
import lime.utils.Assets;
import flixel.addons.display.FlxBackdrop;
#if desktop
import Discord.DiscordClient;
#end
using StringTools;

enum CreditsType
{
   Dev; Contributor; BetaTester; Supporter; SpecialThanks;
}

class Credits extends MusicBeatState
{
	var bg:FlxSprite;
   var checkeredBackground:FlxBackdrop;
   var selectedFormat:FlxText;
   var defaultFormat:FlxText;
   var curNameSelected:Int = 0;
   var creditsTextGroup:Array<CreditsText> = new Array<CreditsText>();
   var menuItems:Array<CreditsText> = new Array<CreditsText>();
   var state:State;
   var selectedPersonGroup:FlxSpriteGroup = new FlxSpriteGroup();
   var selectPersonCam:FlxCamera = new FlxCamera();
   var mainCam:FlxCamera = new FlxCamera();
   var transitioning:Bool = false;

   var curSocialMediaSelected:Int = 0;
   var socialButtons:Array<SocialButton> = new Array<SocialButton>();
   var hasSocialMedia:Bool = true;
   
   var peopleInCredits:Array<Person> = 
   [
      // Developers //
      new Person("Cuzsie", CreditsType.Dev, "Director, Creator, Programmer, and Main Developer",
      [

      ]),
      new Person("Galcy", CreditsType.Dev, "Artist",
      [

      ]),
      new Person("PTG", CreditsType.Dev, "dont really know yet :trol:",
      [

      ]),
      new Person("Memory_001", CreditsType.Dev, "dont really know yet :trol:",
      [

      ]),
      new Person("sk0rbias", CreditsType.Dev, "Made some of the Credits Icons",
      [

      ]),



      // Beta Testers //
      new Person("German", CreditsType.BetaTester, "Beta Tester",
      [

      ]),
      new Person("Ietsy", CreditsType.BetaTester, "Beta Tester",
      [

      ]),
      new Person("Foxnap", CreditsType.BetaTester, "Beta Tester",
      [

      ]),



      // Speical Thanks (aka i like alotta people) //
      new Person("MoldyGH", CreditsType.SpecialThanks, "",
      [

      ]),
      new Person("Epic189Cool", CreditsType.SpecialThanks, "",
      [

      ]),
      new Person("Niffirg", CreditsType.SpecialThanks, "",
      [

      ]),
      new Person("Carxsor", CreditsType.SpecialThanks, "",
      [

      ]),
      new Person("MissingTextureMan101", CreditsType.SpecialThanks, "",
      [

      ]),
      new Person("Leather128", CreditsType.SpecialThanks, "",
      [

      ]),
      new Person("MoonCakeez", CreditsType.SpecialThanks, "",
      [

      ]),
      new Person("wildy", CreditsType.SpecialThanks, "bob mod x)",
      [

      ]),
      new Person("Sticky", CreditsType.SpecialThanks, "",
      [

      ]),
      new Person("CesarFever", CreditsType.SpecialThanks, "",
      [

      ]),
      new Person("kaistudio", CreditsType.SpecialThanks, "",
      [

      ]),
      new Person("PaperKitty", CreditsType.Dev, "dont really know yet :trol:",
      [

      ])
   ];

	override function create()
	{
      #if desktop
      DiscordClient.changePresence("In the Credits Menu", null);
      #end

      mainCam.bgColor.alpha = 0;
      selectPersonCam.bgColor.alpha = 0;
      FlxG.cameras.reset(mainCam);
      FlxG.cameras.add(selectPersonCam);

      FlxCamera.defaultCameras = [mainCam];
      selectedPersonGroup.cameras = [selectPersonCam];

      state = State.SelectingName;
      defaultFormat = new FlxText().setFormat("Aller", 32, FlxColor.WHITE, CENTER);
      selectedFormat = new FlxText().setFormat("Aller", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
      selectedFormat.borderSize = 2;
      selectedFormat.borderQuality = 2;
      
      bg = new FlxSprite(0,0).loadGraphic(Paths.image("ui/Backgrounds/FunkinBG", "preload"));
		bg.color = FlxColor.LIME;
      bg.scrollFactor.set();
      bg.setGraphicSize(1920,1080);
      bg.screenCenter();
		add(bg);

      checkeredBackground = new FlxBackdrop(Paths.image('ui/checkeredBG', "preload"), 0.2, 0.2, true, true);
		add(checkeredBackground);
		checkeredBackground.scrollFactor.set(0, 0.07);
      
      var developers:Array<Person> = new Array<Person>();
      var contributors:Array<Person> = new Array<Person>();
      var betaTesters:Array<Person> = new Array<Person>();
      var supporters:Array<Person> = new Array<Person>();
      var specialThanks:Array<Person> = new Array<Person>();

      for (person in peopleInCredits) 
      {
         switch (person.creditsType)
         {
            case Dev: developers.push(person);
            case Contributor: contributors.push(person);
            case BetaTester: betaTesters.push(person);
            case Supporter: supporters.push(person);
            case SpecialThanks: specialThanks.push(person);
         }
      }

      for (i in 0...peopleInCredits.length)
      {
         var currentPerson = peopleInCredits[i];
         if (currentPerson == developers[0] || currentPerson == contributors[0] || currentPerson == betaTesters[0] || currentPerson == supporters[0] || currentPerson == specialThanks[0])
         {
            var textString:String = '';
            switch (currentPerson.creditsType)
            {
               case Dev:
                  textString = 'Developers';
               case Contributor:
                  textString = 'Contributors';
               case BetaTester:
                  textString = 'Beta Testers';
               case Supporter:
                  textString = 'Supporters';
               case SpecialThanks:
                  textString = 'Special Thanks';
            }

            var titleText:FlxText = new FlxText(0, 0, 0, textString);
            titleText.setFormat("Comic Sans MS Bold", 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            titleText.borderSize = 3;
            titleText.borderQuality = 3;
            titleText.screenCenter(X);
            titleText.scrollFactor.set(0, 1);

            var personIcon:PersonIcon = new PersonIcon(titleText);
            personIcon.loadGraphic(Paths.image('credits/icons/titles/' + textString));
            add(personIcon);

            var creditsTextTitleText = new CreditsText(titleText, false, personIcon);
            creditsTextGroup.push(creditsTextTitleText);
            add(titleText);
         }

         var textItem:FlxText = new FlxText(0, i * 50, 0, currentPerson.name, 32);
         textItem.setFormat(defaultFormat.font, defaultFormat.size, defaultFormat.color, defaultFormat.alignment, defaultFormat.borderStyle, defaultFormat.borderColor);
         textItem.screenCenter(X);
         textItem.scrollFactor.set(0, 1);


         var personIcon:PersonIcon = new PersonIcon(textItem);
         personIcon.loadGraphic(Paths.image('credits/icons/' + currentPerson.name));
         add(personIcon);

         var creditsTextItem:CreditsText = new CreditsText(textItem, true, personIcon);

         add(textItem);
         creditsTextGroup.push(creditsTextItem);
         menuItems.push(creditsTextItem);
      }
      
      var selection = 0;
      
      changeSelection();
      
      for (creditsText in creditsTextGroup)
      {
         creditsText.selectionId = selection - curNameSelected;
         selection++;  
      }
      for (creditsText in creditsTextGroup)
      {
         var scaledY = FlxMath.remapToRange(creditsText.selectionId, 0, 1, 0, 1.5);
         creditsText.text.y = scaledY * 75 + (FlxG.height * 0.5);
      }

		super.create();
	}
   
	override function update(elapsed:Float)
   {
      checkeredBackground.x -= 0.45 / (100 / 60);
		checkeredBackground.y -= 0.16 / (100 / 60);
      
      var fadeTimer:Float = 0.08;
      var upPressed = controls.UP_P;
		var downPressed = controls.DOWN_P;
		var back = controls.BACK;
		var accept = controls.ACCEPT;
      switch (state)
      {
         case State.SelectingName:
			   if (upPressed)
				{
               changeSelection(-1);
				}
				if (downPressed)
				{
               changeSelection(1);
            }
				if (back)
				{
					FlxG.switchState(new MainMenuState());
				}
				if (accept && !transitioning)
				{
               transitioning = true;
               for (creditsText in creditsTextGroup)
               {
                  FlxTween.tween(creditsText.text, {alpha: 0}, fadeTimer);
                  FlxTween.tween(creditsText.icon, {alpha: 0}, fadeTimer);
                  if (creditsText == creditsTextGroup[creditsTextGroup.length - 1])
                  {
                     FlxTween.tween(creditsText.text, {alpha: 0}, fadeTimer, 
                     {
                        onComplete: function(tween:FlxTween)
                        {
                           FlxCamera.defaultCameras = [selectPersonCam];
                           selectPerson(peopleInCredits[curNameSelected]);
                        }
                     });
                  }
               }
				}
         case State.OnName:
            if (back && !transitioning)
            {
               transitioning = true; 
               for (item in selectedPersonGroup)
               {
                  FlxTween.tween(item, {alpha: 0}, fadeTimer);
                  if (item == selectedPersonGroup.members[selectedPersonGroup.members.length - 1])
                  {
                     FlxTween.tween(item, {alpha: 0}, fadeTimer,
                     { 
                        onComplete: function (tween:FlxTween) 
                        {
                           selectedPersonGroup.forEach(function(spr:FlxSprite)
                           {
                              remove(selectedPersonGroup.remove(spr, true));
                           });
                           for (i in 0...socialButtons.length) 
                           {
                              socialButtons.remove(socialButtons[i]);
                           }
                           FlxCamera.defaultCameras = [mainCam];
                           for (creditsText in creditsTextGroup)
                           {
                              FlxTween.tween(creditsText.text, {alpha: 1}, fadeTimer);
                              FlxTween.tween(creditsText.icon, {alpha: 1}, fadeTimer);
                              if (creditsText == creditsTextGroup[creditsTextGroup.length - 1])
                              {
                                 FlxTween.tween(creditsText.text, {alpha: 1}, fadeTimer, 
                                 {
                                    onComplete: function(tween:FlxTween)
                                    {
                                       selectedPersonGroup = new FlxSpriteGroup();
                                       socialButtons = new Array<SocialButton>();
                                       FlxG.mouse.visible = false;
                                       transitioning = false;
                                       state = State.SelectingName;
                                    }
                                 });
                              }
                           }
                        }
                     });
                  }
               }
            }
            if (hasSocialMedia)
            {
               if (upPressed)
               {
                    changeSocialMediaSelection(-1);
               }
               if (downPressed)
               {
                  changeSocialMediaSelection(1);
               }
               if (accept)
               {
                  var socialButton = socialButtons[curSocialMediaSelected];
                  if (socialButton != null && socialButton.socialMedia.socialMediaName != 'discord')
                  {
                     FlxG.openURL(socialButton.socialMedia.socialLink);
                  }
               }
            }
      }
      
      super.update(elapsed);
   }

   function changeSelection(amount:Int = 0)
   {
      if (amount != 0)
      {
         FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
         curNameSelected += amount;
      }
      if (curNameSelected > peopleInCredits.length - 1)
      {
         curNameSelected = 0;
      }
      if (curNameSelected < 0)
      {
         curNameSelected = peopleInCredits.length - 1;
      }
      FlxG.camera.follow(menuItems[curNameSelected].text, 0.1);
      updateText(curNameSelected);
   }
   function changeSocialMediaSelection(amount:Int = 0)
   {
      if (amount != 0)
      {
         FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
         curSocialMediaSelected += amount;
      }
      if (curSocialMediaSelected > socialButtons.length - 1)
      {
         curSocialMediaSelected = 0;
      }
      if (curSocialMediaSelected < 0)
      {
         curSocialMediaSelected = socialButtons.length - 1;
      }
      updateSocialMediaUI();
   }

   function updateText(index:Int)
   {
      var currentText:FlxText = menuItems[index].text;
      if (menuItems[index].menuItem)
      {
		   currentText.setFormat(selectedFormat.font, selectedFormat.size, selectedFormat.color, selectedFormat.alignment, selectedFormat.borderStyle, 
            selectedFormat.borderColor);
         currentText.borderSize = selectedFormat.borderSize;
         currentText.borderQuality = selectedFormat.borderQuality;
      }
		for (i in 0...menuItems.length)
		{
         if (menuItems[i] == menuItems[curNameSelected])
         {
            continue;
         }
			var currentText:FlxText = menuItems[i].text;
			currentText.setFormat(defaultFormat.font, defaultFormat.size, defaultFormat.color, defaultFormat.alignment, defaultFormat.borderStyle,
				defaultFormat.borderColor);
			currentText.screenCenter(X);
		}
   }
   function updateSocialMediaUI()
   {
      if (hasSocialMedia)
      {
         for (socialButton in socialButtons)
         {
            var isCurrentSelected = socialButton == socialButtons[curSocialMediaSelected];
            if (isCurrentSelected)
            {
               fadeSocialMedia(socialButton, 1);
            }
            else
            {
               fadeSocialMedia(socialButton, 0.3);
            }
         }
      }
   }
   function fadeSocialMedia(socialButton:SocialButton, amount:Float)
   {
      for (i in 0...socialButton.graphics.length) 
      {
         var graphic:FlxSprite = socialButton.graphics[i];
         graphic.alpha = amount;
      }
   }

   function selectPerson(selectedPerson:Person)
   {
      curSocialMediaSelected = 0;
      var fadeTime:Float = 0.4;
      var blackBg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
      blackBg.screenCenter(X);
      blackBg.updateHitbox();
      blackBg.scrollFactor.set();
      blackBg.active = false;

      var personName:FlxText = new FlxText(0, 100, 0, selectedPerson.name, 50);
      personName.setFormat(selectedFormat.font, selectedFormat.size, selectedFormat.color, selectedFormat.alignment, selectedFormat.borderStyle, selectedFormat.borderColor);
      personName.screenCenter(X);
      personName.updateHitbox();
      personName.scrollFactor.set();
      personName.active = false;
      
      var credits:FlxText = new FlxText(0, personName.y + 50, FlxG.width / 1.25, selectedPerson.credits, 25);
      credits.setFormat(selectedFormat.font, selectedFormat.size, selectedFormat.color, selectedFormat.alignment, selectedFormat.borderStyle, selectedFormat.borderColor);
      credits.screenCenter(X);
      credits.updateHitbox();
      credits.scrollFactor.set();
      credits.active = false;

      blackBg.alpha = 0;
      personName.alpha = 0;
      credits.alpha = 0;
      
      selectedPersonGroup.add(blackBg);
      selectedPersonGroup.add(personName);
      selectedPersonGroup.add(credits);

      add(blackBg);
      add(personName);
      add(credits);

      FlxTween.tween(blackBg, { alpha: 0.7 }, fadeTime);
      FlxTween.tween(personName, { alpha: 1 }, fadeTime);
      FlxTween.tween(credits, { alpha: 1 }, fadeTime, { onComplete: function(tween:FlxTween)
      {
         if (selectedPerson.socialMedia.length == 0)
         {
            transitioning = false;
            state = State.OnName;
         }
      }});
      
      for (i in 0...selectedPerson.socialMedia.length)
      {
         var social:Social = selectedPerson.socialMedia[i];
         var socialGraphic:FlxSprite = new FlxSprite(0, credits.y + 100 + (i * 100)).loadGraphic(Paths.image('credits/' + social.socialMediaName));
         var discordText:FlxText = null;
         socialGraphic.updateHitbox();
         socialGraphic.screenCenter(X);
         socialGraphic.scrollFactor.set();
         socialGraphic.active = false;
         socialGraphic.alpha = 0;
         add(socialGraphic);

         if (social.socialMediaName == 'discord')
         {
            var offsetY:Float = 20;
            discordText = new FlxText(socialGraphic.x + 100, socialGraphic.y + (i * 100) + offsetY, 0, social.socialLink, 40);
            discordText.setFormat(defaultFormat.font, defaultFormat.size, defaultFormat.color, defaultFormat.alignment, defaultFormat.borderStyle, defaultFormat.borderColor);
            discordText.alpha = 0;
            discordText.updateHitbox();
            discordText.scrollFactor.set();
            discordText.active = false;
            add(discordText);
            FlxTween.tween(discordText, { alpha: 1 }, fadeTime);
            selectedPersonGroup.add(discordText);
         }

         var socialButton:SocialButton;
         
         if (discordText != null)
         {
            socialButton = new SocialButton([socialGraphic, discordText], social);
         }
         else
         {
            socialButton = new SocialButton([socialGraphic], social);
         }
         socialButtons.push(socialButton);
         selectedPersonGroup.add(socialGraphic);
         
         var isCurrentSelectedButton = socialButton == socialButtons[curSocialMediaSelected];
         var targetAlpha = isCurrentSelectedButton ? 1 : 0.3;

         if (i == selectedPerson.socialMedia.length - 1)
         {
            FlxTween.tween(socialGraphic, { alpha: targetAlpha }, fadeTime, { onComplete: function(tween:FlxTween)
            {
               transitioning = false;
               state = State.OnName;
            }});
         }
         else
         {
            FlxTween.tween(socialGraphic, { alpha: targetAlpha }, fadeTime);
         }
      }
      hasSocialMedia = socialButtons.length != 0;

   }
}

class Person
{
   public var name:String;
   public var creditsType:CreditsType;
   public var credits:String;
	public var socialMedia:Array<Social>;

	public function new(name:String, creditsType:CreditsType, credits:String, socialMedia:Array<Social>)
	{
      this.name = name;
      this.creditsType = creditsType;
		this.credits = credits;
      this.socialMedia = socialMedia;
	}
}
class Social
{
   public var socialMediaName:String;
   public var socialLink:String;

   public function new(socialMedia:String, socialLink:String)
   {
      this.socialMediaName = socialMedia;
      this.socialLink = socialLink;
   }
}
class CreditsText
{
   public var text:FlxText;
   public var menuItem:Bool;
   public var selectionId:Int;
   public var icon:PersonIcon;

   public function new(text:FlxText, menuItem:Bool, icon:PersonIcon)
   {
      this.text = text;
      this.menuItem = menuItem;
      this.icon = icon;
   }
}
class PersonIcon extends FlxSprite
{
   public var tracker:FlxObject;

   public function new(tracker:FlxObject)
   {
      this.tracker = tracker;
      super();
   }
   public override function update(elapsed:Float)
   {
      super.update(elapsed);
      if (tracker != null) 
      {
         var biggerValue = Math.max(tracker.height, height);
         var smallerValue = Math.min(tracker.height, height);

         setPosition(tracker.x + tracker.width + 20, tracker.y + (smallerValue - biggerValue) / 2);
      }
   }
}
class SocialButton
{
   public var graphics:Array<FlxSprite>;
   public var socialMedia:Social;

   public function new(graphics:Array<FlxSprite>, socialMedia:Social)
   {
      this.graphics = graphics;
      this.socialMedia = socialMedia;
   }
}
enum State
{
   SelectingName; OnName;
}