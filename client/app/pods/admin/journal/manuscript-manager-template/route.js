import Ember from 'ember';

export default Ember.Route.extend({
  actions: {
    chooseNewCardTypeOverlay(phaseTemplate) {
      this.controllerFor('overlays/chooseNewCardType').setProperties({
        phaseTemplate: phaseTemplate,
        journalTaskTypes: this.modelFor('admin.journal').get('journalTaskTypes')
      });

      this.send('openOverlay', {
        template: 'overlays/add-manuscript-template-card',
        controller: 'overlays/chooseNewCardType'
      });
    },

    addTaskType(phaseTemplate, taskType) {
      let newTask = this.store.createRecord('task-template', {
        title: taskType.get('title'),
        journalTaskType: taskType,
        phaseTemplate: phaseTemplate,
        template: []
      });

      if (taskType.get('kind') === 'Task') {
        this.controllerFor('overlays/adHocTemplate').setProperties({
          phaseTemplate: phaseTemplate,
          model: newTask,
          isNewTask: true
        });

        this.send('openOverlay', {
          template: 'overlays/adHocTemplate',
          controller: 'overlays/adHocTemplate'
        });
      } else {
        this.send('addTaskAndClose');
      }
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
