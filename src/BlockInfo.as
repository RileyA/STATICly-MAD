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
		private var slength:int;
		private var alength:int;
		
		public function BlockInfo(surfaces:Vector.<String>, slength:int, actions:Vector.<String>, alength:int):void {
			this.surfaces = surfaces;
			this.actions = actions;
			this.slength = slength;
			this.alength = alength;
		}
		
		private function getSLength():int {
			return slength;
		}
		
		private function getALength():int {
			return alength;
		}
		
		public function getSurfaces():Vector.<String> {
			return surfaces;
		}
		
		public function getActions():Vector.<String> {
			return actions;
		}
	}
	
}