import Ember from 'ember';
import PaperEditMixin from 'tahi/mixins/views/paper-edit';

export default Ember.View.extend(PaperEditMixin, {

  editor: null,

  // Note: this is done because we instantiate the editor component
  // via template. To be able to access the component from within
  // the controller, here we pass it through.
  propagateEditor: function() {
    this.set('controller.editor', this.get('editor'));
  }.observes('editor'),

  initializeEditingState: function() {
    var controller = this.get('controller');
    // When the paper is not locked we take a click
    // on the paper body to acquire the lock
    this.$('.paper-body').on('click', (e)=>{
      if (!controller.get('model.lockedBy')) {
        e.preventDefault();
        e.stopPropagation();
        controller.acquireLock();
      }
    });
  }.on('didInsertElement'),

  destroyEditor: function() {
    Ember.$(document).off('keyup.autoSave');
    var controller = this.get('controller');
    // Unlock the paper when leaving
    if (controller.get('lockedByCurrentUser')) {
      controller.releaseLock();
    }
  }.on('willDestroyElement'),

  // Note: this must be here as it is used by mixins/views/paper-edit
  saveEditorChanges: function() {
    this.get('controller').savePaper();
  },

  timeoutSave: function() {
    if (Ember.testing) {
      return;
    }
    this.saveEditorChanges();
    Ember.run.cancel(this.short);
    Ember.run.cancel(this.long);
    this.short = null;
    this.long = null;
    this.keyCount = 0;
  },

  short: null,
  long: null,
  keyCount: 0
});
