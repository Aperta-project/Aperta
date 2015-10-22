import Ember from 'ember';

export default Ember.Route.extend({
  actions: {
    chooseNewCardTypeOverlay(phaseTemplate) {
      this.controllerFor('overlays/chooseNewCardType').setProperties({
        phase: phaseTemplate,
        journalTaskTypes: this.modelFor('admin.journal').get('journalTaskTypes')
      });

      this.send('openOverlay', {
        template: 'overlays/chooseNewCardType',
        controller: 'overlays/chooseNewCardType'
      });
    },

    addTaskType(phaseTemplate, taskTypeList) {

      if (!taskTypeList) { return; }

      let promises = [];

      taskTypeList.forEach((taskTemplate) => {

        let newTaskTemplatePromise = this.store.createRecord('taskTemplate', {
          title: taskTemplate.get('title'),
          journalTaskType: taskTemplate,
          phaseTemplate: phaseTemplate,
          template: []
        }).save();

        promises.push(newTaskTemplatePromise);
      });

      Ember.RSVP.all(promises).then(() => {
        this.send('closeOverlay');
      });
    },

    addTaskAndClose() {
      let defaultRoute = 'admin.journal.manuscript_manager_template.edit';
      this.controllerFor(defaultRoute).set('pendingChanges', true);
      this.send('closeOverlay');
    },

    closeAction() {
      this.send('closeOverlay');
    },

    // Noop. We don't want to open cards in MMT screen
    viewCard() {},

    showDeleteConfirm(task) {
      this.send('openOverlay', {
        template: 'overlays/cardDelete',
        controller: 'overlays/card-delete',
        model: task
      });
    }
  }
});
