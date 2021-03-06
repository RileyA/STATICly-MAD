package {
	import flash.utils.ByteArray;
	import com.adobe.serialization.json.*;
	import flash.utils.*;
	import Particle.*;
	import starling.textures.Texture;

	/** A collection of random utilities */
	public class MiscUtils {

		// embed a spiffy font
		[Embed(source="../media/fonts/akashi.ttf", embedAsCFF="false", fontFamily="akashi")]
		public static const akashi:Class;
		
		[Embed(source = "../media/images/bspark.png")]
		private static const m_spark_b:Class;
		public static const sparkTex_b:Texture=Texture.fromBitmap(new m_spark_b);
		[Embed(source = "../media/images/rspark.png")]
		private static const m_spark_r:Class;
		public static const sparkTex_r:Texture=Texture.fromBitmap(new m_spark_r);
		[Embed(source = "../media/images/bspark_small.png")]
		private static const m_spark_bs:Class;
		public static const sparkTex_bs:Texture=Texture.fromBitmap(new m_spark_bs);
		[Embed(source = "../media/images/rspark_small.png")]
		private static const m_spark_rs:Class;
		public static const sparkTex_rs:Texture=Texture.fromBitmap(new m_spark_rs);
		[Embed(source = "../media/images/longspark.png")]
		private static const m_longspark:Class;
		public static const longspark:Texture=Texture.fromBitmap(new m_longspark);
		
		public static function getDisplayName(levelName:String):String{
			var l:LevelInfo=loadLevelInfo(levelName);
			return l?l.title:"";
		}
		
		/**
		* Returns a LevelInfo matching the given level name.
		*/
		public static function loadLevelInfo(name:String):LevelInfo {
			var sourceClass:Class = LevelAssets.getLevelSource(name);
			if (!sourceClass)return null;
			var info:LevelInfo = new LevelInfo();
			loadJSON(new sourceClass() as ByteArray, info);
			return info;
		}

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
					if (obj[key] is Array && (out[key] is Vector.<*> 
						|| getQualifiedClassName(out[key]) == "__AS3__.vec::Vector.<Number>")) {
						var type:Class = getDefinitionByName(getQualifiedClassName(
							out[key]).split("<")[1].split(">")[0]) as Class;
						for (var i:uint = 0; i < obj[key].length; ++i) {
							out[key].push(new type());
							if (out[key][i] is Number 
								|| out[key][i] is Boolean 
								|| out[key][i] is String)
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

		public static function outputJSON(obj:Object):String {
			return outputObject(obj);
		}

		/** Escape newlines 'n stuff */
		public static function escapeString(str:String):String {
			return str
			  .replace(/[\"]/g, '\\"')
			  .replace(/[\\]/g, '\\\\')
			  .replace(/[\/]/g, '\\/')
			  .replace(/[\b]/g, '\\b')
			  .replace(/[\f]/g, '\\f')
			  .replace(/[\n]/g, '\\n')
			  .replace(/[\r]/g, '\\r')
			  .replace(/[\t]/g, '\\t');
		}
	
		/** This mess takes a simple object and dumps its fields into a JSON 
			formatted string */
		private static function outputObject(obj:Object, tabs:String=""):String {
			var out:String = "{";
			var xml:XML = describeType(obj);
			var first:Boolean = true;
			for each(var v:XML in xml..variable) {
				if (first) {
					first = false;
				} else {
					out += ","
				}
				out += "\n" + tabs + "\t";
				out += "\"" + v.@name + "\" : ";
				if (obj[v.@name] is Number) {
					out += obj[v.@name];
				} else if (obj[v.@name] is String) {
					out += "\"" + escapeString(obj[v.@name]) + "\"";
				} else if (obj[v.@name] is Boolean) {
					out += obj[v.@name] ? "true" : "false";
				} else if (obj[v.@name] is Vector.<*> || 
					getQualifiedClassName(v.@name) 
					== "__AS3__.vec::Vector.<Number>") {
					out += "\n" + tabs + "\t[";
					var firstArr:Boolean = true;
					for (var i:uint = 0; i < obj[v.@name].length; ++i) {
						if (firstArr)
							firstArr = false;
						else 
							out += ",";
						out += "\n" + tabs + "\t";
						if (obj[v.@name][i] is Number) {
							out += obj[v.@name][i];
						} else if (obj[v.@name][i] is String) {
							out += "\"" + escapeString(obj[v.@name][i]) + "\"";
						} else if (obj[v.@name][i] is Boolean) {
							out += obj[v.@name][i] ? "true" : "false";
						} else if (obj[v.@name][i] is Vector.<*> || 
							getQualifiedClassName(v.@name) 
							== "__AS3__.vec::Vector.<Number>") {
							out += "[]";// not supported!
						} else {
							out += tabs + "\t" +
							outputObject(obj[v.@name][i], tabs + "\t\t");
						}
					}
					out += "\n" + tabs + "\t]";
				} else {
					out += "\n" + tabs + "\t" + outputObject(obj[v.@name], 
						tabs + "\t");
				}
			}
			out += "\n" + tabs + "}";
			return out;
		}


		/**
		* Takes a number and rounds it to the specified number of decimal places.
		*/
		public static function setPrecision(number:Number, precision:int):Number {
			precision = Math.pow(10, precision);
			return (Math.round(number * precision)/precision);
		}
	}
}
