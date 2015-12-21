import Ember from 'ember';
import BuildsTaskTemplate from 'tahi/mixins/controllers/builds-task-template';

export default Ember.Component.extend(BuildsTaskTemplate, {
  isNewTask: true,
  blocks: Ember.computed.alias('task.template'),

  actions: {
    // noops
    save()      {},
    saveModel() {},
    sendEmail() {}
  }
});
