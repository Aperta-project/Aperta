import TaskController from 'tahi/pods/paper/task/controller';
import SavesQuestionsOnClose from 'tahi/mixins/saves-questions-on-close';
var CompetingInterestsOverlayController;

CompetingInterestsOverlayController = TaskController.extend(SavesQuestionsOnClose, {
  declareNoCompeteCopy: "The authors have declared that no competing interests exist."
});

export default CompetingInterestsOverlayController;
