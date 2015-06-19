import Ember from 'ember';
import PaperEditMixin from 'tahi/mixins/views/paper-edit';

var View = Ember.View.extend(PaperEditMixin, {

  editor: null,

  propagateEditor: function() {
    this.set('controller.editor', this.get('editor'));
  }.observes('editor'),

  updateEditorLockedState: function() {
    var editor = this.get('controller.editor');
    if (!editor) {
      return;
    }
    if (this.get('isEditing')) {
      editor.enable();
    } else {
      editor.disable();
    }
  }.observes('isEditing'),

  initializeEditingState: function() {
    // try tpo start editing
    // TODO for now we should switch to a simplified locking strategy:
    // When the editor is opened it will acquire the lock and release it when leaving
    // If the paper is locked already we should indicate it somehow
    this.get('controller').startEditing();
  }.on('didInsertElement'),

  destroyEditor: function() {
    Ember.$(document).off('keyup.autoSave');
  }.on('willDestroyElement'),

  timeoutSave: function() {
    if (Ember.testing) {
      return;
    }
    this.saveEditorChanges();
    this.get('controller').send('savePaper');
    Ember.run.cancel(this.short);
    Ember.run.cancel(this.long);
    this.short = null;
    this.long = null;
    this.keyCount = 0;
  },

  short: null,
  long: null,
  keyCount: 0,

  saveEditorChanges: function() {
    var documentBody = this.get('editor').getBodyHtml();
    this.get('controller').send('updateDocumentBody', documentBody);
  },
});

export default View;
