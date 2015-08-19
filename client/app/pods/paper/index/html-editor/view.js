import Ember from 'ember';
import PaperEditMixin from 'tahi/mixins/views/paper-edit';

export default Ember.View.extend(PaperEditMixin, {

  editor: null,

  // Note: this is done because we instantiate the editor component
  // via template. To be able to access the component from within
  // the controller, here we pass it through.
  propagateEditor: Ember.observer('editor', function() {
    this.set('controller.editor', this.get('editor'));
  }),

  initializeEditingState: Ember.on('didInsertElement', function() {
    let controller = this.get('controller');
    // When the paper is not locked we take a click
    // on the paper body to acquire the lock
    this.$('.paper-body').on('click', (e)=>{
      if (!controller.get('model.lockedBy')) {
        e.preventDefault();
        e.stopPropagation();
        controller.acquireLock();
      }
    });
  }),

  destroyEditor: Ember.on('willDestroyElement', function() {
    Ember.$(document).off('keyup.autoSave');
    let controller = this.get('controller');
    // Unlock the paper when leaving
    if (controller.get('lockedByCurrentUser')) {
      controller.releaseLock();
    }
  }),

  // Note: this must be here as it is used by mixins/views/paper-edit
  saveEditorChanges() {
    this.get('controller').savePaper();
  },

  timeoutSave() {
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
