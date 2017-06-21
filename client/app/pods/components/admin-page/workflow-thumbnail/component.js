import Ember from 'ember';

export default Ember.Component.extend({
  workflow: {},
  workflows: [],
  classNames: [],
  confirmDestroy: false,
  canDestroy: Ember.computed('workflow', 'workflows.[]', function() {
    let journal_id = this.get('workflow').get('journal').get('id');
    return this.get('workflows').filterBy('journal.id', journal_id).length > 1;
  }),

  actions: {
    toggleConfirmDestroy() {
      this.toggleProperty('confirmDestroy');
    },
    hideConfirmDestroy() {
      this.set('confirmDestroy', false);
    },
    destroyWorkflow() {
      if (this.get('canDestroy')) {
        return this.get('workflow').destroyRecord();
      }
    }
  }
});
