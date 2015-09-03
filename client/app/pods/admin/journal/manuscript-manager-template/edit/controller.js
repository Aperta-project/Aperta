import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Controller.extend(ValidationErrorsMixin, {
  pendingChanges: false,
  editingMmtName: false,
  positionSort: ["position:asc"],
  journal: Ember.computed.alias('model.journal'),
  phaseTemplates: Ember.computed.alias('model.phaseTemplates'),
  sortedPhaseTemplates: Ember.computed.sort('phaseTemplates', 'positionSort'),
  showSaveButton: Ember.computed.or('pendingChanges', 'editingMmtName'),

  saveTemplate(transition){
    this.get('model').save().then(() => {
      this.successfulSave(transition);
    }, (response) => {
      this.displayValidationErrorsFromResponse(response);
    });
  },

  successfulSave(transition){
    this.resetProperties();
    if (transition) {
      this.transitionToRoute(transition);
    }else{
      let defaultRoute = 'admin.journal.manuscript_manager_template.edit';
      this.transitionToRoute(defaultRoute, this.get('model'));
    }
  },

  resetProperties(){
    this.setProperties({ editingMmtName: false, pendingChanges: false });
  },

  actions: {

    editMmtName(){
      this.clearAllValidationErrors();
      this.set('editingMmtName', true);
    },

    changeTaskPhase(taskTemplate, targetPhaseTemplate){
      let newPosition = targetPhaseTemplate.get('length');

      taskTemplate.setProperties({
        phaseTemplate: targetPhaseTemplate,
        position: newPosition
      });

      targetPhaseTemplate.get('taskTemplates').pushObject(taskTemplate);
      this.set('pendingChanges', true);
    },

    addPhase(position){

      this.get('phaseTemplates').forEach(function(phaseTemplate) {
        if (phaseTemplate.get('position') >= position) {
          phaseTemplate.incrementProperty('position');
        }
      });

      this.store.createRecord('phaseTemplate', {
        name: 'New Phase',
        manuscriptManagerTemplate: this.get('model'),
        position: position
      });

      this.set('pendingChanges', true);
    },

    removeRecord(record){
      record.deleteRecord();
      this.set('pendingChanges', true);
    },

    rollbackPhase(phase, oldName){
      phase.set('name', oldName);
    },

    savePhase(){
      this.set('pendingChanges', true);
    },

    saveTemplateOnClick(transition){

      if (this.get('pendingChanges') || this.get('editingMmtName')) {
        this.saveTemplate(transition);
      } else {
        this.send('cancel');
      }
    },

    cancel(){
      if (this.get('model.isNew')){
        this.get('model').deleteRecord();
        this.resetProperties();
      } else {
        this.store.unloadAll('taskTemplate');
        this.store.unloadAll('phaseTemplate');
        this.get('model').rollback();
        this.get('model').reload().then(() => {
          this.resetProperties();
        });
      }
    }
  }
});