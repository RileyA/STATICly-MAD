package cgs.server.abtesting
{
	public class ABTesterConstants
	{
		//
		// AB testing url's.
		//
		
		//Temp set to local. Change to a dev server once that is setup.
		public static const AB_TEST_URL_LOCAL:String = "http://localhost:10082/";
		
		//Development URL for ab testing.
		public static const AB_TEST_URL_DEV:String = "http://dev.ws.centerforgamescience.com/cgs/apps/abtest/ws/index.php/";
		
		//Production URL for ab testing.
		public static const AB_TEST_URL:String = "http://prd.ws.centerforgamescience.com/cgs/apps/abtest/ws/index.php/";
		
		//URL to be used to create a new ab test.
		public static const CREATE_TEST:String = "abtest/set/";
		
		public static const EDIT_TEST:String = "abtest/edit/";
		
		//
		// Test request methods.
		//
		
		public static const REQUEST_ALL_TESTS:String = "abtest/request/";
		
		public static const REQUEST_TESTS_BY_ID:String = "abtest/requesttestsbyid/";
		
		public static const REQUEST_TEST_STATS:String = "teststatus/requestteststats/";
		
		//
		// Condition request methods.
		//
		
		public static const REQUEST_TEST_CONDITIONS:String = "abtest/requesttestconditions/";
		
		//
		// Variable request methods.
		//
		
		public static const REQUEST_CONDITION_VARIABLES:String = "abtest/requestconditionvariables/";
		
		public static const GET_USER_CONDITIONS:String = "userconditions/request/";
		
		public static const NO_CONDITION_USER:String = "userconditions/nocondition/";
		
		public static const LOG_TEST_START_END:String = "teststatus/set/";
		
		public static const LOG_CONDITION_RESULTS:String = "conditionresults/set/";
		
		//
		// Test queue request methods.
		//
		
		public static const REQUEST_TEST_QUEUE_TESTS:String = "queue/requesttests/";
		
		public static const REQUEST_ACTIVE_TEST_QUEUE:String = "queue/requestactivetests/";
		
		//
		// Test update methods.
		//
		
		public static const DEACTIVATE_TEST:String = "abtest/deactivate/";
		public static const STOP_TEST:String = "abtest/stop";
		public static const ACTIVATE_TEST:String = "abtest/activate/";
		
		//
		// Test results methods.
		//
		
		public static const REQUEST_USER_COUNT:String = "userconditions/usercount/";
		
		public static const USERS_CONDITIONS_REQUEST:String = "userconditions/requestusers/";
		
		public static const USERS_TEST_RESULTS_REQUEST:String = "conditionresults/requestresultsbyuid/";
		
		public static const REQUEST_TEST_RESULTS_BY_ID:String = "testresults/getbyids/";
		public static const LOAD_TEST_RESULTS:String = "testresults/load/";
		public static const RELOAD_TEST_RESULTS:String = "testresults/reload/"
		public static const LOAD_USER_RESULTS_DATA:String = "testresults/retrieve/";
		
		//Method to get all test status information.
		public static const LOAD_TEST_RESULTS_STATUS:String = "testresults/getstatus/";
		
		public static const LOAD_TEST_RESULTS_STATUS_BY_IDS:String = "testresults/getstatusbyids/";
		
		public static const CANCEL_TEST_RESULTS:String = "testresults/cancel/";
		
		public static const REQUEST_CUSTOM_RESULTS:String = "testresults/getcustom/";
		
		public static const CREATE_CUSTOM_RESULTS:String = "testresults/createcustom/";
		
		public static const EDIT_CUSTOM_RESULTS:String = "testresults/editcustom/";
		
		public static const DELETE_CUSTOM_RESULTS:String = "testresults/deletecustom/";
		
		/**
		 * Get the game specific url for the game with the given name.
		 */
		public static function getGameABTestingURL(gameName:String):String
		{
			return "http://" + gameName + ".ws.centerforgamescience.com/cgs/apps/abtest/ws/index.php/";
		}
	}
}