import TaskController from 'tahi/pods/task/controller';

export default TaskController.extend({
  needs: ['admin/journal/index'],
  overlayClass: 'overlay--fullscreen journal-edit-overlay',
  propertyName: '',

  actions: {
    save() {
      this.get('controllers.admin/journal/index')
          .set(`${this.get('propertyName')}SaveStatus`, 'Saved')
          .get('model').save();

      this.send('closeAction');
    }
  }
});
