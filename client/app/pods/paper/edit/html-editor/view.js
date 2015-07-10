import Ember from 'ember';
import PaperEditMixin from 'tahi/mixins/views/paper-edit';

var View = Ember.View.extend(PaperEditMixin, {

  editor: null,

  propagateEditor: function() {
    this.set('controller.editor', this.get('editor'));
  }.observes('editor'),

  initializeEditingState: function() {
    // start editing right away
    this.get('controller').startEditing();
  }.on('didInsertElement'),

  destroyEditor: function() {
    Ember.$(document).off('keyup.autoSave');
    // stop editing when closing the editor
    this.get('controller').stopEditing();
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
    let editor = this.get('editor');
    if(Ember.isEmpty(editor)) { return; }

    var documentBody = editor.getBodyHtml();
    this.get('controller').send('updateDocumentBody', documentBody);
  },
});

export default View;
