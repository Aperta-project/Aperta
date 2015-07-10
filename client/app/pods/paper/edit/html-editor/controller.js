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
    this.updateEditor();
  }.observes('model.body'),

  startEditing: function() {
    if (!this.get('model.lockedBy')) {
      this.set('model.lockedBy', this.currentUser);
      this.connectEditor();
      // when the paper is saved, the server knows who acquired the lock (this is required for the heartbeat to work)
      // when the save succeeds, we send the `startEditing` action, which is defined on `paper/edit/route`, which now starts the heartbeat
      this.get('model').save().then(()=> {
        this.send('startEditing');
      });
    }
  },

  stopEditing: function() {
    this.disconnectEditor();
    this.set('model.lockedBy', null);
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
    // Reject saving when the paper is not being locked by this user
    if (!this.get('lockedByCurrentUser')) {
      throw new Error('Paper can not be saved as it is locked. Please try again later.');
    }
    var editor = this.get('editor');
    if(Ember.isEmpty(editor)) { return; }

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
    // TODO: temp fix?
    if(this.get('editor')) {
      this.get('editor').disconnect();
    }
  },

});

export default HtmlEditorController;
