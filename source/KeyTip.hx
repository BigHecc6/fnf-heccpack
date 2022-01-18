package; //Ooh its another one of my custom made packages!

import flixel.FlxCamera;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using StringTools;

class KeyTip extends FlxSpriteGroup {
    public static var textBG:FlxSprite;
    var keyTexts:FlxTypedGroup<FlxText>;
    var keyIcons:FlxTypedGroup<FlxSprite>;
    var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
    var keks:Array<Dynamic>;

    public function new(keys:Array<Dynamic>, show:Bool, ?camera:FlxCamera = null) {
        
        super(x, y);
        textBG = new FlxSprite(0, FlxG.height - 52).makeGraphic(FlxG.width, 52, 0xFF000000);
		textBG.alpha = 0.6;
        textBG.scrollFactor.set();

        add(textBG);
        keyTexts = new FlxTypedGroup<FlxText>();
        keyIcons = new FlxTypedGroup<FlxSprite>();
        keks = keys;

        if(camera != null) {
            cam = [camera];
        }

        for (key in keys) {
            addKey(key[0], key[1]);
        }
        for (key in 0...keys.length) {
            if (keys[key] == keys[0]) {
                keyTexts.members[0].x = 0;
                keyIcons.members[0].x = (keyTexts.members[0].width) + 5;
            } else {
                keyTexts.members[key].x = (keyIcons.members[key-1].x + keyIcons.members[key-1].width) + 10;
                keyIcons.members[key].x = (keyTexts.members[key].x + keyTexts.members[key].width) + 5;
            }
        }
        if (!show) {
            hide(false);
        }
        for (text in keyTexts.members) {
            add(text);
            text.cameras = cam;
        }
        for (icon in keyIcons.members) {
            add(icon);
            icon.cameras = cam;
        }
        textBG.cameras = cam;
        keyTexts.cameras = cam;
        keyIcons.cameras = cam;
        
        

        


    }
    public function addKey(text:String, icon:String) {
        var keyText:FlxText = new FlxText(0, textBG.y + 17, 0, text + ':', 18);
        keyText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, LEFT);
        keyText.updateHitbox();
		keyText.scrollFactor.set();
        keyTexts.add(keyText);
        keyText.cameras = cam;
        

        var keyIcon:FlxSprite = new FlxSprite(0, textBG.y + 17);
        keyIcon.frames = Paths.getSparrowAtlas('keys');
        keyIcon.animation.addByPrefix('button', icon, 1, false);
        keyIcon.setGraphicSize(Std.int(keyIcon.width * 0.25));
        var ofs:Int = iconOffset(icon);
        keyIcon.scrollFactor.set();
        keyIcon.animation.play('button');
        keyIcon.updateHitbox();
        keyIcon.y -= keyIcon.height/2 + ofs;
        keyIcons.add(keyIcon);
        keyIcon.cameras = cam;
        
    }
    public function show(ease:Bool) {
        if (ease) {
            FlxTween.tween(textBG, { y: FlxG.height - 52 }, 0.2, { ease: FlxEase.quadOut });
            for (text in keyTexts.members) {
                FlxTween.tween(text, { y: FlxG.height - 35 }, 0.2, { ease: FlxEase.quadOut });
            }
            for (icon in 0...keyIcons.members.length) {
                var ofs:Int = iconOffset(keks[icon][1]);
                FlxTween.tween(keyIcons.members[icon], { y: FlxG.height - 35 + ofs }, 0.2, { ease: FlxEase.quadOut });
            }
        } else {
            textBG.y = FlxG.height - 52;
            for (text in keyTexts.members) {
                text.y = textBG.y + 17;
            }
            for (icon in 0...keyIcons.members.length) {
                var ofs:Int = iconOffset(keks[icon][1]);
                keyIcons.members[icon].y = textBG.y + 17 + ofs;
            }
        }
    }
    public function hide(ease:Bool) {
        if (ease) {
            FlxTween.tween(textBG, { y: FlxG.height }, 0.2, { ease: FlxEase.quadIn });
            for (text in keyTexts.members) {
                FlxTween.tween(text, { y: FlxG.height + 17 }, 0.2, { ease: FlxEase.quadIn });
            }
            for (icon in keyIcons.members) {
                FlxTween.tween(icon, { y: FlxG.height + 17 }, 0.2, { ease: FlxEase.quadIn });
            }
        } else {
            textBG.y = FlxG.height;
            for (text in keyTexts.members) {
                text.y = FlxG.height + 17;
            }
            for (icon in keyIcons.members) {
                icon.y = FlxG.height + 17;
            }
        }
    }
    public function changeKeys(keys:Array<Dynamic>, ?tween:FlxTween) {
        keyTexts.clear();
        keyIcons.clear();
        for (key in keys) {
            addKey(key[0], key[1]);
        }
        for (key in 0...keys.length) {
            if (keys[key] == keys[0]) {
                keyTexts.members[0].x = 0;
                keyIcons.members[0].x = (keyTexts.members[0].width) + 5;
            } else {
                keyTexts.members[key].x = (keyIcons.members[key-1].x + keyIcons.members[key-1].width) + 10;
                keyIcons.members[key].x = (keyTexts.members[key].x + keyTexts.members[key].width) + 5;
            }
        }

        hide(false);

        for (text in keyTexts.members) {
            add(text);
            text.cameras = cam;
        }
        for (icon in keyIcons.members) {
            add(icon);
            icon.cameras = cam;
        }
        textBG.cameras = cam;
        keyTexts.cameras = cam;
        keyIcons.cameras = cam;

        show(true);
        trace('done');
    }
    private function iconOffset(text:String):Int {
        var int:Int;
        switch(text) {
            case 'updown':
                int = -5;
            case 'leftright':
                int = -5;
            case 'brackets':
                int = -5;
            case 'esc':
                int = 2;
            default:
                int = 0;
        }
        return int;
    }
}