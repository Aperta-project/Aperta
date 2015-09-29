import TaskController from 'tahi/pods/paper/task/controller';
import SavesQuestionsOnClose from 'tahi/mixins/saves-questions-on-close';

export default TaskController.extend(SavesQuestionsOnClose, {
  actions: {
    savePaperShortTitle() {
      this.get('model.paper').save();
    }
  }
});
