import Ember from 'ember';
import PaperBaseMixin from 'tahi/mixins/controllers/paper-base';
import PaperEditMixin from 'tahi/mixins/controllers/paper-edit';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

var HtmlEditorController = Ember.Controller.extend(PaperBaseMixin, PaperEditMixin, DiscussionsRoutePathsMixin, {
  subRouteName: 'edit',

  // initialized by paper/edit/view
  toolbar: null,

  // used to recover a selection when returning from another context (such as figures)
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
    this.connectEditor();
  },

  stopEditing: function() {
    this.disconnectEditor();
    this.savePaper();
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
    if (!this.get('lockedByCurrentUser')) {
      throw new Error('Paper can not be saved as it is locked. Please try again later.');
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
