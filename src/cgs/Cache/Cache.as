package cgs.Cache 
{
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	
	/**
	 * Properties and functions for generally using the pre-packaged flash cache.
	 * 
	 * @author Rich
	 **/
	public class Cache 
	{
		// State
		protected static var m_cache:SharedObject;
		
		/**
		 *
		 * State
		 *
		**/
		
		/**
		 * Returns whether or not the cache (shared object) presently exists
		 */
		protected static function get cacheExists():Boolean 
		{
			if (m_cache)
				return true;
			else
			{
				try 
				{
					m_cache = SharedObject.getLocal("userData");
					return true;
				}
				catch (err:Error)
				{
					trace("ERROR: Unable to obtain the Shared Object - aka The Flash Cache");
				}
			}
			return false;
		}
		
		/**
		 * Returns the present size of the cache in bytes.
		 */
		public static function get size():uint
		{
			return cacheExists?m_cache.size:0;
		}
		
		/**
		 *
		 * Clearing
		 *
		**/
		
		/**
		 * Removes all properties from the cache.
		 */
		public static function clearCache():void
		{
			if(cacheExists)
				m_cache.clear();
		}
		
		/**
		 *
		 * Saving
		 *
		**/
		
		/**
		 * Deletes the given property from the cache if it exists.
		 * @param	property The property to be removed.
		 */
		public static function deleteSave(property:String):void
		{
			if(cacheExists && saveExists(property))
			{
				delete m_cache.data[property];
				try 
				{
					m_cache.flush();
				}
				catch (err:Error)
				{
					trace("ERROR: Flush Failed! " + err.message);
				}
			}
		}
		
		/**
		 * Attempts to retrieve the given property, may return null if not found.
		 * @param	property The property to be retrieved.
		 * @return
		 */
		public static function getSave(property:String):*
		{
			return cacheExists?m_cache.data[property]:null;
		}
		
		/**
		 * Creates the given property with the given default value if it does not already exist.
		 * @param	property The property to be added.
		 * @param	defaultVal The default value of the added property.
		 */
		public static function initSave(property:String, defaultVal:*):void
		{
			if (!cacheExists)
				return;
			if (!m_cache.data.hasOwnProperty(property))
				m_cache.data[property] = defaultVal;
			try 
			{
				m_cache.flush();
			}
			catch (err:Error)
			{
				trace("ERROR: Flush Failed! " + err.message);
			}
		}
		
		/**
		 * Returns whether or not the given property already exists in the cache.
		 * @param	property The property to look for.
		 * @return
		 */
		public static function saveExists(property:String):Boolean 
		{
			return cacheExists?m_cache.data.hasOwnProperty(property):false;
		}
		
		/**
		 * Sets the property with the given value (will always override the existing value).
		 * @param	property The property to be updated
		 * @param	val The new value of the property
		 * @return
		 */
		public static function setSave(property:String, val:*):Boolean
		{
			if (!cacheExists)
				return false;
			m_cache.data[property] = val;
			try 
			{
				m_cache.flush();
			}
			catch (err:Error)
			{
				trace("ERROR: Flush Failed! " + err.message);
			}
			return true;
		}
		
	}

}