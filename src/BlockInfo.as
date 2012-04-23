package 
{
	import flash.utils.*;
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class BlockInfo {
		
		private var surfaces:Vector.<String>;
		private var actions:Vector.<String>;
		
		public function BlockInfo(surfaces:Vector.<String>, actions:Vector.<String>):void {
			this.surfaces = surfaces;
			this.actions = actions;
		}
		
		public function getSurfaces():Vector.<String> {
			return surfaces;
		}
		
		public function getActions():Vector.<String> {
			return actions;
		}
	}
	
}
