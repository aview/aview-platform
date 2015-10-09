package testSuites.newTestSuite.testCases.tests{

	import com.gorillalogic.flexunit.IFlexMonkeyTest
    import com.gorillalogic.flexmonkey.core.MonkeyRunnable;
    import com.gorillalogic.flexmonkey.monkeyCommands.UIEventMonkeyCommand;
    import com.gorillalogic.flexunit.FlexMonkeyCustomTestBase;
    import mx.collections.ArrayCollection;

	[TestCase(order=1)]
	public class NewTest extends FlexMonkeyCustomTestBase {

	    public function NewTest() {
			super()    	}

		[Before]
		public function setUp():void {
		}

        private function createnewTestCommandList():ArrayCollection {
            var arr:ArrayCollection = new ArrayCollection();
            setupnewTestCommandList(arr);
            return arr;
        }

        private function setupnewTestCommandList(arr:ArrayCollection):void {
            var theRunnable:MonkeyRunnable=null;
            theRunnable=new UIEventMonkeyCommand('SelectText', 'txtLoginUser', 'automationName', ['0', '30'], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Input', 'txtLoginUser', 'automationName', ['invalid username'], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('ChangeFocus', 'txtLoginUser', 'automationName', [null], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Input', 'txtLoginPass', 'automationName', ['invalid password'], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Click', 'Login', 'automationName', [null], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

            theRunnable=new UIEventMonkeyCommand('Click', 'OK', 'automationName', [null], '', '', '10', '1000', false);
            arr.addItem(theRunnable);

        }
		[Test(async, timeout=73500)]
        public function newTestTest():void {
        	this.monkeyTestCaseName = "NewTest";
        	this.monkeyTestName = "newTestTest";
			if(Log.isDebug()) log.debug(this.monkeyTestCaseName + "." + this.monkeyTestName);
        	beforeTest(this.monkeyTestCaseName, this.monkeyTestName);
        	var commandList:ArrayCollection = createnewTestCommandList();
        	runFlexMonkeyCommands(commandList, 
        	                      null,  // use default callback (will end test)
        	                      250
        	                     ); 
        }


    }
}