import Ember from 'ember';
import Utils from 'tahi/services/utils';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Controller.extend(ValidationErrorsMixin, {
  dirty: false,
  editMode: false,
  positionSort: ["position:asc"],
  journal: Ember.computed.alias('model.journal'),
  sortedPhaseTemplates: Ember.computed.sort('model.phaseTemplates', 'positionSort'),
  deletedRecords: null,
  showSaveButton: Ember.computed.or('dirty', 'editMode'),

  deleteRecord(record){
    let deleted = this.get('deletedRecords') || [];
    deleted.addObject(record);
    record.deleteRecord();

    this.setProperties({
      deletedRecords: deleted,
      dirty: true
    });
  },

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
      this.transitionToRoute('admin.journal.manuscript_manager_template.edit', this.get('model'));
    }
  },

  resetProperties(){
    this.setProperties({
      editMode: false,
      dirty: false,
      deletedRecords: []
    });
  },

  actions: {

    toggleEditMode(){
      this.clearAllValidationErrors();
      this.toggleProperty('editMode');
    },

    changeTaskPhase(taskTemplate, targetPhaseTemplate){
      let newPosition = targetPhaseTemplate.get('length');

      taskTemplate.setProperties({
        phaseTemplate: targetPhaseTemplate,
        position: newPosition
      });

      targetPhaseTemplate.get('taskTemplates').pushObject(taskTemplate);
      this.set('dirty', true);
    },

    addPhase(position){

      this.get('model.phaseTemplates').forEach(function(phaseTemplate) {
        if (phaseTemplate.get('position') >= position) {
          phaseTemplate.incrementProperty('position');
        }
      });

      this.store.createRecord('phaseTemplate', {
        name: 'New Phase',
        manuscriptManagerTemplate: this.get('model'),
        position: position
      });

      this.set('dirty', true);
    },

    removePhase(phaseTemplate){
      this.deleteRecord(phaseTemplate);
    },

    rollbackPhase(phase, oldName){
      phase.set('name', oldName);
    },

    removeTask(taskTemplate){
      this.deleteRecord(taskTemplate);
    },

    savePhase(phase){
      this.set('dirty', true);
    },

    saveTemplateOnClick(transition){

      if (this.get('dirty') || this.get('editMode')) {
        this.saveTemplate(transition);
      } else {
        this.send('rollback');
      }
    },

    rollback(){
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