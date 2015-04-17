import Ember from 'ember';
import BuildsTaskTemplate from 'tahi/mixins/controllers/builds-task-template';

export default Ember.Controller.extend(BuildsTaskTemplate, {
  isNewTask: false,
  blocks: Ember.computed.alias('template'),
  phaseTemplate: null,

  actions: {
    closeAction() {
      this.send('addTaskAndClose');
    }
  }
});
