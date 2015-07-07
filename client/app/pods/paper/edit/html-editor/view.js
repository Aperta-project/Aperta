import Ember from 'ember';
import PaperEditMixin from 'tahi/mixins/views/paper-edit';

var View = Ember.View.extend(PaperEditMixin, {

  editor: null,

  // Note: this is done because we instantiate the editor component
  // via template. To be able to access the component from within
  // the controller, here we pass it through.
  propagateEditor: function() {
    this.set('controller.editor', this.get('editor'));
  }.observes('editor'),

  initializeEditingState: function() {
    // start editing right away
    this.get('controller').startEditing();
  }.on('didInsertElement'),

  destroyEditor: function() {
    Ember.$(document).off('keyup.autoSave');
    var controller = this.get('controller');
    // stop editing when closing the editor
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
    this.get('controller').savePaper();
    Ember.run.cancel(this.short);
    Ember.run.cancel(this.long);
    this.short = null;
    this.long = null;
    this.keyCount = 0;
  },

  short: null,
  long: null,
  keyCount: 0,
});

export default View;
