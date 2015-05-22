import Ember from 'ember';

export default Ember.Route.extend({
  actions: {
    chooseNewCardTypeOverlay(phaseTemplate) {
      this.controllerFor('overlays/chooseNewCardType').setProperties({
        phaseTemplate: phaseTemplate,
        journalTaskTypes: this.modelFor('admin.journal').get('journalTaskTypes')
      });

      this.render('overlays/add-manuscript-template-card', {
        into: 'application',
        outlet: 'overlay',
        controller: 'overlays/chooseNewCardType'
      });
    },

    addTaskType(phaseTemplate, taskType) {
      let newTask = this.store.createRecord('taskTemplate', {
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
        this.render('overlays/adHocTemplate', {
          into: 'application',
          outlet: 'overlay',
          controller: 'overlays/adHocTemplate'
        });
      } else {
        this.send('addTaskAndClose');
      }
    },

    addTaskAndClose() {
      this.controllerFor('admin.journal.manuscriptManagerTemplate/edit').set('dirty', true);
      this.send('closeOverlay');
    },

    closeAction() {
      this.send('closeOverlay');
    },

    viewCard() {},

    showDeleteConfirm(task) {
      this.render('overlays/cardDelete', {
        into: 'application',
        outlet: 'overlay',
        controller: 'overlays/card-delete',
        model: task
      });
    }
  }
});
