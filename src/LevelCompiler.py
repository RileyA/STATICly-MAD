import os
q=open("LevelQids.csv","w")
f=open("LevelAssets.as","w")
f.write("""// Autogenerated file: Do not edit!

package {

	public class LevelAssets {
""")

path="../media/levels/"
names=[file[:-5] for file in os.listdir(path) if file.endswith(".json")]
names.sort();
for name in names:
    f.write(
"""		[Embed(source="../media/levels/{name}.json",  mimeType=
			"application/octet-stream")] private static const {name}_lvl:Class;
""".format(name=name))

f.write("""

		/**
		* Load all existing levels into a dictionary
		*/
		private static var associativeArray:Object;
		public static var qidArray:Object;
		{
			associativeArray = new Object();
			qidArray = new Object();
""")

qid = 1
for name in names:
    f.write("""			associativeArray["{name}"] = {name}_lvl;
			qidArray["{name}"] = {qid};
""".format(name=name,qid=qid))
    q.write(str(qid) + ", " + str(name) + "\n")
    qid = qid + 1

f.write("""		}

		public static function getLevelSource(name:String):Class {
			return associativeArray[name];
		}

		public static function getLevelQid(name:String):int {
			return qidArray[name];
		}
	}
}
""")

f.close()
q.close()
