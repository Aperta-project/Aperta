import Ember from 'ember';
import PaperIndexMixin from 'tahi/mixins/views/paper-index';

export default Ember.View.extend(PaperIndexMixin, {

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
    this.$('.manuscript-inner').on('click', (e)=>{
      if (!controller.get('model.lockedBy')) {
        e.preventDefault();
        e.stopPropagation();
        controller.acquireLock();
      }
    });
    controller.updateEditorLockState();
  }),

  destroyEditor: Ember.on('willDestroyElement', function() {
    Ember.$(document).off('keyup.autoSave');
    let controller = this.get('controller');
    // Unlock the paper when leaving
    if (controller.get('lockedByCurrentUser')) {
      controller.releaseLock();
    }
  }),

  // Note: this must be here as it is used by mixins/views/paper-index
  saveEditorChanges() {
    this.get('controller').savePaper();
  },
  
  short: null,
  long: null,
  keyCount: 0
});
