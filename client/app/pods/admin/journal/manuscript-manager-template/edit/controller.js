import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Controller.extend(ValidationErrorsMixin, {
  pendingChanges: false,
  editingName: false,
  positionSort: ['position:asc'],
  journal: Ember.computed.alias('model.journal'),
  phaseTemplates: Ember.computed.alias('model.phaseTemplates'),
  sortedPhaseTemplates: Ember.computed.sort('phaseTemplates', 'positionSort'),
  showSaveButton: Ember.computed.or('pendingChanges', 'editingName'),

  showCardDeleteOverlay: false,
  taskToDelete: null,

  showAdHocTaskOverlay: false,
  adHocTaskToDisplay: null,

  showChooseNewCardOverlay: false,
  addToPhase: null,
  journalTaskTypes: [],
  journalTaskTypesIsLoading: false,

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

  updateTaskPositions(itemList) {
    this.beginPropertyChanges();
    itemList.forEach((item, index) => {
      item.set('position', index + 1);
    });
    this.endPropertyChanges();
  },

  usesResearchArticleReviewerReport: Ember.computed('model.usesResearchArticleReviewerReport', function(key, value){
    let model = this.get('model');

    // when we're not being used as a getter
    if(value !== undefined){
      model.set(key, value);
      model.save();
    }
    return model.get(key);
  }),

  resetProperties(){
    this.setProperties({ editingName: false, pendingChanges: false });
  },

  actions: {
    hideAdHocTaskOverlay() {
      this.set('showAdHocTaskOverlay', false);
    },

    showChooseNewCardOverlay(phase) {
      this.setProperties({
        addToPhase: phase,
        journalTaskTypesIsLoading: true
      });

      const journalId = this.get('model.journal.id');
      this.store.find('adminJournal', journalId).then(adminJournal => {
        this.setProperties({
          journalTaskTypes: adminJournal.get('journalTaskTypes'),
          journalTaskTypesIsLoading: false
        });
      });

      this.set('showChooseNewCardOverlay', true);
    },

    hideChooseNewCardOverlay() {
      this.set('showChooseNewCardOverlay', false);
    },

    addTaskType(phaseTemplate, taskTypeList) {
      if (!taskTypeList) { return; }
      let hasAdHocType = false;

      taskTypeList.forEach((taskType) => {
        const newTaskTemplate = this.store.createRecord('taskTemplate', {
          title: taskType.get('title'),
          journalTaskType: taskType,
          phaseTemplate: phaseTemplate,
          template: []
        });

        if (taskType.get('kind') === 'Task') {
          hasAdHocType = true;
          this.set('adHocTaskToDisplay', newTaskTemplate);
        }
      });

      if (hasAdHocType) {
        this.set('showAdHocTaskOverlay', true);
      }

      this.set('pendingChanges', true);
    },

    showCardDeleteOverlay(task) {
      this.set('taskToDelete', task);
      this.set('showCardDeleteOverlay', true);
    },

    hideCardDeleteOverlay() {
      this.set('showCardDeleteOverlay', false);
    },

    editMmtName(){
      this.clearAllValidationErrors();
      this.setProperties({ editingName: true, pendingChanges: true });
    },

    taskMovedWithinList(item, oldIndex, newIndex, itemList) {
      itemList.removeAt(oldIndex);
      itemList.insertAt(newIndex, item);
      this.updateTaskPositions(itemList);
      this.set('pendingChanges', true);
    },

    taskMovedBetweenList(
      item, oldIndex, newIndex, newList, sourceItems, newItems) {
      sourceItems.removeAt(oldIndex);
      newItems.insertAt(newIndex, item);
      item.set('phaseTemplate', newList);

      this.updateTaskPositions(sourceItems);
      this.updateTaskPositions(newItems);

      this.set('pendingChanges', true);
    },

    startDragging(item, container) {
      item.addClass('card--dragging');
      container.parent().addClass('column-content--dragging');
    },

    stopDragging(item, container) {
      item.removeClass('card--dragging');
      container.parent().removeClass('column-content--dragging');
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
      this.saveTemplate(transition);
    },

    cancel(){
      if (this.get('model.isNew')){
        this.get('model').deleteRecord();
        this.resetProperties();
        this.transitionToRoute('admin.journal', this.get('journal'));
      } else {
        this.store.unloadAll('taskTemplate');
        this.store.unloadAll('phaseTemplate');
        this.get('model').rollback();
        this.get('journal').reload().then(() => {
          this.resetProperties();
        });
      }
    }
  }
});
