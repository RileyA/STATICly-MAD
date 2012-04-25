package {
	import flash.utils.ByteArray;
	import com.adobe.serialization.json.*;
	import flash.utils.*;

	/** A collection of random utilities */
	public class MiscUtils {

		/** Loads a ByteArray containing JSON info into an object 
				@param raw The JSON data
				@param out The object to output to */
		public static function loadJSON(raw:ByteArray, out:Object):void {
			parseObject(com.adobe.serialization.json.JSON.decode(
				raw.readUTFBytes(raw.length)), out);
		}
		
		/** A hideous abomination that puts the data from generic object thing
			returned by JSON.decode into an actual object */
		private static function parseObject(obj:Object, out:Object):void {
			for(var key:String in obj) {
				if (key in out) {
					if (obj[key] is Array && out[key] is Vector.<*>) {
						var type:Class = getDefinitionByName(getQualifiedClassName(
							out[key]).split("<")[1].split(">")[0]) as Class;
						for (var i:uint = 0; i < obj[key].length; ++i) {
							out[key].push(new type());
							if (obj[key][i] is Number || obj[key][i] is Boolean 
								|| obj[key][i] is String)
								out[key][i] = obj[key][i];
							else
								parseObject(obj[key][i], out[key][i]);
						}
					} else if ((obj[key] is Number && out[key] is Number) 
						|| (obj[key] is Boolean && out[key] is Boolean)
						|| (obj[key] is String && out[key] is String)) {
						out[key] = obj[key];
					} else {
						parseObject(obj[key], out[key]);
					}
				}
			}
		}
	}
}
