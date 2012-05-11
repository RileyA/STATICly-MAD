package cgs.server.abtesting
{
	import cgs.server.abtesting.tests.ABTest;
	import cgs.server.abtesting.tests.Variable;
	import cgs.server.logging.CGSServer;
	import cgs.server.logging.requests.CallbackRequest;
	
	import com.adobe.serialization.json.JSONDecoder;
	
	import flash.utils.Dictionary;
	
	public class ABTester
	{
		public static const BOOLEAN_VARIABLE:int = 0;
		public static const INTEGER_VARIABLE:int = 1;
		public static const NUMBER_VARIABLE:int = 2;
		public static const STRING_VARIABLE:int = 3;
		
		//Singleton instance.
		private static var _instance:ABTester;
		
		private var _tests:Vector.<ABTest>;
		
		//Dictionary of all variables. key = variable name, value = variableContainer.
		private var _variables:Dictionary;
		
		//Reference to the server which is used to make requests.
		private var _server:IABTestingServer;
		
		//Callback to be called when the conditions have been loaded.
		private var _conditionsCallback:CallbackRequest;
		
		//Indicates if the conditions have been loaded from the server.
		private var _conditionsLoaded:Boolean;
		
		private var _testVariableTimer:TestVariableTimer;
		
		public function ABTester()
		{
			_variables = new Dictionary();
			_testVariableTimer = new TestVariableTimer();
		}
		
		/**
		 * Clear the singleton instance so that a new instance can be created.
		 * init() must be called again.
		 */
		public static function resetSingleton():void
		{
			_instance = null;
		}
		
		/**
		 * Initialize must be called prior to using the ab tester.
		 */
		public static function init(server:IABTestingServer):void
		{
			instance._server = server;
		}
		
		/**
		 * Get an instance of the abtester singleton. This class has both
		 * static and instance functions so that dependency injection can still
		 * be used.
		 */
		public static function get instance():ABTester
		{
			if(_instance == null)
			{
				_instance = new ABTester();
			}
			
			return _instance;
		}
		
		/**
		 * Get the test id for the user. If the user is in multiple tests this
		 * just returns the first test id. Will return -1 if no test is loaded.
		 */
		public static function GetUserTestId():int
		{
			return instance.getUserTestId();
		}
		
		public function getUserTestId():int
		{
			if(_tests.length == 0) return 0;
			
			return _tests[0].id;
		}
		
		/**
		 * Get the condition id for the user. If the user is in multiple conditions
		 * this will return the first condition id. Will return -1 if no condition id for user.
		 */
		public static function GetUserConditionId():int
		{
			return instance.getUserConditionId();
		}
		
		public function getUserConditionId():int
		{
			if(_tests.length == 0) return 0;
			
			return _tests[0].conditionID;
		}
		
		/**
		 * Loads / creates test conditions for the user. This also loads any variables
		 * that have been determined, by test results, to persist across all users.
		 * This should not be called until a valid CGS uid has been loaded from the server.
		 * 
		 * @param callback a function to be called when the user's test conditions have been loaded
		 * from the server. Function should have the signature of (failed:Boolean).
		 */
		public static function loadUserTestConditions(callback:Function):void
		{
			if(_instance != null)
			{
				_instance.resetTestConditions();
			}
			instance.loadUserTestConditions(callback);
		}
		
		/**
		 * Make the user a no condition user. They will not be assigned to a test and
		 * will use default values set in the client.
		 */
		public static function noConditionUser():void
		{
			instance.noConditionUser();
		}
		
		public function noConditionUser():void
		{
			_server.noUserConditions();
		}
		
		private function resetTestConditions():void
		{
			for each(var variable:VariableContainer in _variables)
			{
				variable.removeTestVariables();
			}
		}
		
		public function loadUserTestConditions(callback:Function):void
		{
			_conditionsCallback = new CallbackRequest(callback);
			
			_server.requestUserTestConditions(handleConditionsLoaded);
		}
		
		private function handleConditionsLoaded(conditions:Object, failed:Boolean):void
		{
			var callback:Function = _conditionsCallback.callback;
			_conditionsCallback = null;
			
			if(!failed)
			{
				parseJSONData(conditions);
			}
			
			if(callback != null)
			{
				callback(failed);
			}
		}
		
		/**
		 * Register a default value for a variable with the given name.
		 */
		public static function registerDefaultValue(varName:String, value:*, valueType:int = Variable.STRING_VARIABLE):void
		{
			instance.registerDefaultValue(varName, value, valueType);
		}
		
		public function registerDefaultValue(varName:String, value:*, valueType:int):void
		{
			var varContainer:VariableContainer = _variables[varName];
			if(varContainer == null)
			{
				varContainer = new VariableContainer(value, valueType);
				_variables[varName] = varContainer;
			}
			else
			{
				varContainer.setDefaultValue(value);
				varContainer.type = valueType;
			}
		}
		
		private function registerTestVariable(variable:Variable):void
		{
			var varContainer:VariableContainer = _variables[variable.name];
			if(varContainer == null)
			{
				varContainer = new VariableContainer(variable.value, variable.type);
				_variables[variable.name] = varContainer;
			}
			
			varContainer.setTestVariable(variable);
		}
		
		/**
		 * Get the current value for the variable with the given name.
		 * 
		 * @param varName the name of the variable.
		 * @return * the current value of the variable. Will return null if the
		 * variable is not contained in the tester.
		 */
		public static function getVariableValue(varName:String):*
		{
			return instance.getVariableValue(varName);
		}
		
		public function getVariableValue(varName:String):*
		{
			var varValue:* = null;
			var varCon:VariableContainer = _variables[varName];
			if(varCon != null)
			{
				varValue = varCon.currentValue();
			}
			
			return varValue;
		}
		
		protected function getVariable(varName:String):Variable
		{
			var varCon:VariableContainer = _variables[varName];
			if(varCon != null)
			{
				return varCon.testVariable;
			}
			
			return null;
		}
		
		/**
		 * Indicates if the variable with the given name is being tested.
		 * 
		 * @param varName the name of the variable.
		 * @return true if the variable is currently being tested.
		 */
		public static function isVariableInTest(varName:String):Boolean
		{
			return instance.isVariableInTest(varName);
		}
		
		public function isVariableInTest(varName:String):Boolean
		{
			var varContainer:VariableContainer = _variables[varName];
			if(varContainer != null)
			{
				return varContainer.isInTest();
			}
			
			return false;
		}
		
		//
		// Override values for variables.
		//
		
		public static function overrideVariableValue(varName:String, value:*):void
		{
			instance.overrideVariableValue(varName, value);
		}
		
		public function overrideVariableValue(varName:String, value:*):void
		{
			var varCon:VariableContainer = _variables[varName];
			if(varCon != null)
			{
				varCon.setOverrideValue(value);
			}
		}
		
		//
		// Should time utilities be added to the tester?
		// Any other testing utilities?
		//
		
		/**
		 * Log the start and end of a variable test. This method should be used when the start and end
		 * of a variable test occur at the same time. If the start and end of tests occur at different times
		 * the startVariableTesting and endVariableTesting should be used.
		 */
		public static function variableTested(varName:String, results:Object = null):void
		{
			instance.variableTested(varName, results);
		}
		
		public function variableTested(varName:String, results:Object = null):void
		{
			var variable:Variable = getVariable(varName);
			
			if(variable == null) return;
			
			var test:ABTest = variable.abTest;
			if(!test.hasTestingStarted)
			{
				//Test start is only logged once.
				logTestStart(test.id, test.conditionID);
			}
			
			//Log the start of the variable test.
			variable.testingStarted = true;
			logVariableTestStart(test.id, test.conditionID, variable.id, test.nextResultID);
			
			//Log the end of the variable test.
			variable.tested = true;
			logVariableResults(test.id, test.conditionID, variable.id, test.currentResultID, -1, results);
			
			//Send the test complete event to the server if the test has been completed.
			if(test.tested)
			{
				logTestEnd(test.id, test.conditionID);
			}
		}
		
		/**
		 * Signal to the ab testing engine that a variable has started being tested on the user.
		 * 
		 * @param varName the name of the variable being tested.
		 * @param startData optional data to be logged on the server as part of the test.
		 */
		public static function startVariableTesting(varName:String, startData:Object = null):void
		{
			instance.startVariableTesting(varName, startData);
		}
		
		public function startVariableTesting(varName:String, startData:Object = null):void
		{
			sendVariableStart(varName, -1, startData);
		}
		
		private function sendVariableStart(varName:String, time:Number = -1, detail:Object = null):void
		{
			var variable:Variable = getVariable(varName);
			
			if(variable == null) return;
			
			//TODO - Send a cancel if the variable is still in test?
			variable.inTest = true;
			
			var test:ABTest = variable.abTest;
			if(!test.hasTestingStarted)
			{
				logTestStart(test.id, test.conditionID);
			}
			
			variable.testingStarted = true;
			logVariableTestStart(test.id, test.conditionID, variable.id, test.nextResultID, time, detail);
		}
		
		/**
		 * Let the tester know that the variable with the given name has been tested and
		 * it's results are known. If all variables in the test have been tested
		 * the results of the test will be logged on the server. Use this method
		 * if the variable test is not time based.
		 * 
		 * @param varName the name of the variable which has been tested.
		 * @param results an optional object containing the results of the variable test.
		 */
		public static function endVariableTesting(varName:String, results:Object = null):void
		{
			instance.endVariableTesting(varName, results);
		}
		
		public function endVariableTesting(varName:String, results:Object = null):void
		{
			var time:Number = -1;
			if(_testVariableTimer.containsVariableTimer(varName))
			{
				time = _testVariableTimer.endVariableTimer(varName);
			}
			
			sendVariableResults(varName, time, results);
		}
		
		private function sendVariableResults(varName:String, time:Number = -1, results:Object = null):void
		{
			//Send the variable test results to the server.
			var variable:Variable = getVariable(varName);
			
			if(variable == null) return;
			
			//Do not send variable results if the start testing has not been called.
			if(!variable.inTest) return;
			
			var test:ABTest = variable.abTest;
			
			variable.tested = true;
			logVariableResults(test.id, test.conditionID, variable.id, test.currentResultID, time, results);
			
			//Send the test complete event to the server if the test has been completed.
			if(test.tested)
			{
				logTestEnd(test.id, test.conditionID);
				test.reset();
			}
		}
		
		/**
		 * Cancel a variable test.
		 */
		public static function cancelVariableTesting(varName:String, details:Object = null):void
		{
			//TODO - Implement.
		}
		
		public function cancelVariableTesting(varName:String, details:Object = null):void
		{
			
		}
		
		//
		// Timed variable testing.
		//
		
		/**
		 * Let the tester know that a variable has begun its testing on the user.
		 */
		public static function startTimedVariableTesting(varName:String, startData:Object = null):void
		{
			instance.startTimedVariableTesting(varName, startData);
		}
		
		public function startTimedVariableTesting(varName:String, startData:Object = null):void
		{
			var variable:Variable = getVariable(varName);
			
			if(variable == null) return;
			
			//Variable test has already been started.
			if(variable.inTest) return;
			
			_testVariableTimer.startVariableTimer(varName);
			sendVariableStart(varName, -1, startData);
		}
		
		//
		// Server request handling.
		//
		
		private function logTestStart(testID:int, condID:int):void
		{
			_server.logTestStart(testID, condID);
		}
		
		private function logTestEnd(testID:int, condID:int):void
		{
			_server.logTestEnd(testID, condID);
		}
		
		//Log the start of a variable test.
		private function logVariableTestStart(testID:int, condID:int, varID:int, resultID:int, time:Number = -1, detail:Object = null):void
		{
			_server.logConditionVariableStart(testID, condID, varID, resultID, time, detail);
		}
		
		//Log the results for a variable test.
		private function logVariableResults(testID:int, condID:int, varID:int, resultID:int, time:Number = -1, detail:Object = null):void
		{
			_server.logConditionVariableResults(testID, condID, varID, resultID, time, detail);
		}
		
		//Cancel a variable test.
		private function logCancelVariableTesting(testID:int, condID:int, varID:int, detail:Object = null):void
		{
			//TODO - Implement.
		}
		
		private function getABTest(id:int):ABTest
		{
			for each(var test:ABTest in _tests)
			{
				if(test.id == id)
				{
					return test;
				}
			}
			
			return null;
		}
		
		//
		// Server data parsing.
		//
		
		private function parseJSONData(data:Object):void
		{
			if(data == null) return;
			
			_tests = new Vector.<ABTest>();
			var testData:Object = data.tests;
			var test:ABTest;
			for each(var currTestData:Object in testData)
			{
				test = new ABTest();
				test.parseJSONData(currTestData);
				addTestVariables(test);
				_tests.push(test);
			}
			
			//Parse the current status of the tests.
			var testID:int;
			if(data.hasOwnProperty("t_status"))
			{
				var testStatus:Object = data.t_status;
				for each(var currTestStatus:Object in testStatus)
				{
					testID = currTestStatus.test_id;
					test = getABTest(testID);
					if(test != null)
					{
						test.parseTestStatusData(currTestStatus);
					}
				}
			}
			
			//Parse the current status of the condition variables.
			if(data.hasOwnProperty("v_status"))
			{
				var variablesStatus:Object = data.v_status;
				for each(var currVarStatus:Object in variablesStatus)
				{
					testID = currVarStatus.test_id;
					test = getABTest(testID);
					if(test != null)
					{
						test.parseVariableStatus(currVarStatus);
					}
				}
			}
			
			//TODO - Parse override values when they are implemented on the server side.
		}
		
		private function addTestVariables(test:ABTest):void
		{
			for each(var variable:Variable in test.variables)
			{
				registerTestVariable(variable);
			}
		}
	}
}

import cgs.server.abtesting.tests.Variable;

internal class VariableContainer
{
	//Type of the variable.
	private var _varType:int;
	
	//Default value for the variable. This is used if there is no test or override values.
	private var _defaultValue:*;
	
	//Indicates if the default value was set to null.
	private var _defaultIsNull:Boolean;
	
	//Value which can be set if completed test has been set to propagate it's values.
	private var _overrideValue:*;
	
	//Indicates if the override value was set to null.
	private var _overrideIsNull:Boolean;
	
	//Test variable information. This variable value is used if it is set.
	private var _testVariable:Variable;
	
	public function VariableContainer(defaultValue:*, varType:int)
	{
		_defaultValue = defaultValue;
		_varType = varType;
	}
	
	public function set type(type:int):void
	{
		_varType = type;
	}
	
	/**
	 * Get the current valid value for the variable. Will return overriden value if set
	 * then the actual test value and then the default value.
	 */
	public function currentValue():*
	{
		if(_overrideValue != null || _overrideIsNull)
		{
			return _overrideValue;
		}
		else if(_testVariable != null)
		{
			return _testVariable.value;
		}
		else if(_defaultValue != null || _defaultIsNull)
		{
			return _defaultValue;
		}
		
		return null;
	}
	
	public function setDefaultValue(value:*):void
	{
		_defaultValue = value;
		_defaultIsNull = _defaultValue == null;
	}
	
	public function setOverrideValue(value:*):void
	{
		_overrideValue = value;
		_overrideIsNull = _overrideValue == null;
	}
	
	public function removeTestVariables():void
	{
		_testVariable = null;
		_overrideValue = null;
	}
	
	public function setTestVariable(value:Variable):void
	{
		_testVariable = value;
	}
	
	/**
	 * Indicates if the variable is currently being tested.
	 */
	public function isInTest():Boolean
	{
		return _testVariable != null;
	}
	
	public function get testVariable():Variable
	{
		return _testVariable;
	}
}