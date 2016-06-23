import Ember from 'ember';

export default Ember.Route.extend({
  controllerName: 'admin.journal.manuscript_manager_template.edit',

  model() {

    let journal = this.modelFor('admin.journal');

    let newTemplate = this.store.createRecord('manuscript-manager-template', {
      journal: journal,
      paperType: "Research"
    });

    newTemplate.get('phaseTemplates').pushObject(
      this.store.createRecord('phase-template', {name: "Phase 1", position: 1})
    );

    newTemplate.get('phaseTemplates').pushObject(
      this.store.createRecord('phase-template', {name: "Phase 2", position: 2})
    );

    newTemplate.get('phaseTemplates').pushObject(
      this.store.createRecord('phase-template', {name: "Phase 3", position: 3})
    );

    this.set('journal', journal);
    this.set('newTemplate', newTemplate);

    return newTemplate;
  },

  setupController(controller, model) {
    controller.set('model', model);
    controller.set('journal', this.modelFor('admin.journal'));
    controller.set('editingName', true);
  },

  renderTemplate(){
    this.render('admin/journal/manuscript_manager_template/edit');
  },

  actions: {

    didRollBack(){
      let newTemplate = this.get('newTemplate');
      this.get('journal.manuscriptManagerTemplates').removeObject(newTemplate);
      this.transitionTo('admin.journal');
    }
  }
});
