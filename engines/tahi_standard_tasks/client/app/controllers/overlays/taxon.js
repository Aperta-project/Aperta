import TaskController from 'tahi/pods/paper/task/controller';
import SavesQuestionsOnClose from 'tahi/mixins/saves-questions-on-close';

var TaxonOverlayController;

TaxonOverlayController = TaskController.extend(SavesQuestionsOnClose);

export default TaxonOverlayController;
