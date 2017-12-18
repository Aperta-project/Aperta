import Ember from 'ember';

export default Ember.Component.extend({
  activeEdit: Ember.computed('currentReviewerReport.adminEdits.[]', function() {
    return this.get('currentReviewerReport.adminEdits').findBy('active', true);
  }),
  notesClass: Ember.computed('notesEmpty', function() {
    return this.get('notesEmpty') ? 'form-control error' : 'form-control';
  }),

  actions: {
    cancelEdit() {
      this.set('currentReviewerReport.activeAdminEdit', false);
      this.set('currentReviewerReport.cancelPendingAnswerSaves', true);
      Ember.run(() => {
        this.get('activeEdit').destroyRecord();
        this.get('currentReviewerReport').reload().then(() => {
          this.set('currentReviewerReport.cancelPendingAnswerSaves', false);
        });
      });
    },

    saveEdit() {
      let activeEdit = this.get('activeEdit');
      let notes = activeEdit.get('notes');
      // If Ember thinks the note is empty, or the note contains only whitespace,
      // consider it invalid, and don't save the edit
      if (Ember.isEmpty(notes) || !/\S/.test(notes)) {
        this.set('notesEmpty', true);
      } else {
        let report = this.get('currentReviewerReport');
        activeEdit.set('active', false);
        activeEdit.save().then(function() {
          report.set('activeAdminEdit', false);
        });
      }
    },

    clearNotesError() {
      this.set('notesEmpty', false);
    }
  }
});
