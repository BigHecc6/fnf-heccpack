package;

import haxe.Json;

import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

typedef ModLister =
{
    var id:String;
    var name:String;
    var weeks:Array<Dynamic>;
    var modBefore:String;
}

class ModList
{
    private static var directories:Array<String> = [Paths.getPreloadPath()];
    private static var susList:Array<String> = CoolUtil.coolTextFile(Paths.getPreloadPath('moddies/mods.txt'));
    private static var rawJson:String = null;
    private static var defMod:ModLister = {
        "id": "og",
        "name": "Original",
        "weeks": [
            "tutorial",
            "week1",
            "week2",
            "week3",
            "week4",
            "week5",
            "week6",
            "week7"
        ],
        "modBefore": "og"
    };

    public static function getMod(mod:String):ModLister {
        var path:String = 'moddies/' + mod + '.json';
        if(OpenFlAssets.exists(Paths.getPreloadPath(path))) {
            rawJson = Assets.getText(Paths.getPreloadPath(path));
        }
        if (rawJson != null && rawJson.length > 0) {
            return cast Json.parse(rawJson);
        }
        return defMod;
    }

}