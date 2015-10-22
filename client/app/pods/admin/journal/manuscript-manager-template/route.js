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
      let isAdhocType = false;

      taskTypeList.forEach((taskType) => {

        let newTaskTemplate = this.store.createRecord('taskTemplate', {
          title: taskType.get('title'),
          journalTaskType: taskType,
          phaseTemplate: phaseTemplate,
          template: []
        });

        if (taskType.get('kind') === 'Task') {
          isAdhocType = true;

          this.controllerFor('overlays/adHocTemplate').setProperties({
            phaseTemplate: phaseTemplate,
            model: newTaskTemplate,
            isNewTask: true
          });
        }
      });

      if (isAdhocType) {
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
