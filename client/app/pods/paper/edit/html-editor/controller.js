import Ember from 'ember';
import PaperBaseMixin from 'tahi/mixins/controllers/paper-base';
import PaperEditMixin from 'tahi/mixins/controllers/paper-edit';

var HtmlEditorController = Ember.Controller.extend(PaperBaseMixin, PaperEditMixin, {
  isEditing: Ember.computed.alias('lockedByCurrentUser'),
  hasOverlay: false,
  editorComponent: 'tahi-editor-ve',

  paperBodyDidChange: function() {
    if (!this.get('lockedByCurrentUser')) {
      this.updateEditor();
    }
  }.observes('model.body'),

  startEditing: function() {
    this.set('model.lockedBy', this.currentUser);
    this.get('model').save().then(function() {
      this.connectEditor();
      this.send('startEditing');
      this.set('saveState', false);
    }.bind(this));
  },

  stopEditing: function() {
    this.set('model.body', this.get('editor').getBodyHtml());
    this.set('model.lockedBy', null);
    this.send('stopEditing');
    this.disconnectEditor();
    this.get('model').save().then(function() {
      this.set('saveState', true);
    }.bind(this));
  },

  updateEditor: function() {
    var editor = this.get('editor');
    if (editor) {
      editor.update();
    }
  },

  savePaper: function() {
    if (!this.get('model.editable')) {
      return;
    }
    var editor = this.get('editor');
    var paper = this.get('model');
    var manuscriptHtml = editor.getBodyHtml();
    paper.set('body', manuscriptHtml);
    if (paper.get('isDirty')) {
      paper.save().then(function() {
        this.set('saveState', true);
        this.set('isSaving', false);
      }.bind(this));
    } else {
      this.set('isSaving', false);
    }
  },

  connectEditor: function() {
    this.get('editor').connect();
  },

  disconnectEditor: function() {
    this.get('editor').disconnect();
  },
});

export default HtmlEditorController;
