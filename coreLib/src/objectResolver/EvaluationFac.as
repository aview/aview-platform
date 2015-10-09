package objectResolver
{
	import mx.core.FlexGlobals;
	
	public class EvaluationFac
	{
		public function EvaluationFac()
		{
		}

		public var abstractHelper = FlexGlobals.topLevelApplication.applicationModuleHandler.getabstractHelperObj();
		public var arrayCollectionExtended = FlexGlobals.topLevelApplication.applicationModuleHandler.getarrayCollectionExtendedObj();
		public var arrayCollectionUtil = FlexGlobals.topLevelApplication.applicationModuleHandler.getarrayCollectionUtilObj();
		public var auditable = FlexGlobals.topLevelApplication.applicationModuleHandler.getauditableObj();
		public var aViewStringUtil = FlexGlobals.topLevelApplication.applicationModuleHandler.getaViewStringUtilObj();
		public var checkBoxDataGrid = FlexGlobals.topLevelApplication.applicationModuleHandler.getcheckBoxDataGridObj();
		public var checkBoxHeaderColumn = FlexGlobals.topLevelApplication.applicationModuleHandler.getcheckBoxHeaderColumnObj();
		public var checkBoxRenderer = FlexGlobals.topLevelApplication.applicationModuleHandler.getcheckBoxRendererObj();
		public var customAlert = FlexGlobals.topLevelApplication.applicationModuleHandler.getcustomAlertObj();
		public var statusVO = FlexGlobals.topLevelApplication.applicationModuleHandler.getstatusVOObj();
	}
}

/*
import edu.amrita.aview.common.components.alert.CustomAlert;
import edu.amrita.aview.common.components.ArrayCollectionExtended;
import edu.amrita.aview.common.components.checkBox.CheckBoxDataGrid;
import edu.amrita.aview.common.components.checkBox.CheckBoxHeaderColumn;
import edu.amrita.aview.common.components.checkBox.CheckBoxRenderer;
import edu.amrita.aview.common.helper.AbstractHelper;
import edu.amrita.aview.common.util.ArrayCollectionUtil;
import edu.amrita.aview.common.util.AViewStringUtil;
import edu.amrita.aview.common.vo.Auditable;
import edu.amrita.aview.common.vo.StatusVO;

		//var aviewPlayer = FlexGlobals.topLevelApplication.applicationModuleHandler.getObj();
		// .\common\components\DateFormatter.mxml
		var dateFormatter = FlexGlobals.topLevelApplication.applicationModuleHandler.getDateFormatterObj();
		//.\gclm\helper\ClassHelper.as
		var classHelper = FlexGlobals.topLevelApplication.applicationModuleHandler.getObj();

		//.\gclm\helper\CourseHelper.as
		var courseHelper = FlexGlobals.topLevelApplication.applicationModuleHandler.getObj();
		new Array
		new ArrayCollection
		new CategorySummary
		new CategoryView
		new CategoryWiseResult
		new Date
		new DateFormatter
		new LiveQuizResult
		new LocationBasedResult0
		new Object
		new QbCategoryHelper
		new QbDifficultyLevelVO
		new QbQuestionTypeHelper
		new QbQuestionTypeVO
		new QbQuestionVO
		new QbSubcategoryHelper
		new QbSubcategoryVO
		new QuestionLevelResult
		new QuestionPaperHelper
		new QuestionPaperResult
		new QuizQuestionResponseHelper
		new StudentWiseResult
		new SubcategoryView
		new AddRandomQuestion
		new ArrayList
		new ClassHelper
		new CourseHelper
		new DateFormatter
		new LiveQuestionPaperPreview
		new QbCategoryVO
		new QbDifficultyLevelHelper
		new QbDifficultyLevelVO
		new QbQuestionTypeHelper
		new QbQuestionTypeVO
		new QuestionBank
		new QuestionPaper
		new QuestionPaperQuestions
		new QuestionPaperQuestionVO
		new QuestionPaperVO
		new QuestionPaperVO
		new QuizQuestionChoiceResponseVO
		new QuizQuestionResponseVO
		new QuizResponseHelper
		new QuizResponseVO
		new QuizResult
		new QuizSummary
		new Sort
		new SortField
		new StudentOffLineQuizView
		new StudentViewLiveQuiz
		new Timer
		
*/		
