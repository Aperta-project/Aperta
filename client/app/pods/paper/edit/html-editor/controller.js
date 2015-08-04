import Ember from 'ember';
import PaperBaseMixin from 'tahi/mixins/controllers/paper-base';
import PaperEditMixin from 'tahi/mixins/controllers/paper-edit';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

var HtmlEditorController = Ember.Controller.extend(PaperBaseMixin, PaperEditMixin, DiscussionsRoutePathsMixin, {
  subRouteName: 'edit',

  editorComponent: "tahi-editor-ve",

  // initialized by paper/edit/view
  toolbar: null,
  hasOverlay: false,

  // used to recover a selection when returning from another context (such as figures)
  isEditing: Ember.computed.alias('lockedByCurrentUser'),

  paperBodyDidChange: function() {
    this.updateEditor();
  }.observes('model.body'),

  startEditing() {
    this.acquireLock();
    this.connectEditor();
  },

  stopEditing() {
    this.disconnectEditor();
    this.releaseLock();
  },

  acquireLock() {
    // Note:
    // when the paper is saved, the server knows who acquired the lock
    // (this is required for the heartbeat to work)
    // when the save succeeds, we send the `startEditing` action,
    // which is defined on `paper/edit/route`, which now starts the heartbeat
    // Thus, to acquire the lock it is necessary to
    // 1. set model.lockedBy = this.currentUser
    // 2. save the model, which sends the updated lockedBy to the server
    // 3. let the router know that we are starting editing
    var paper = this.get('model');
    paper.set('lockedBy', this.currentUser);
    paper.set('body', this.get('editor').getBodyHtml());
    paper.save().then(()=>{
      this.send('startEditing');
    });
  },

  releaseLock() {
    var paper = this.get('model');
    paper.set('lockedBy', null);
    paper.save().then(()=>{
      // FIXME: don't know why but when calling this during willDestroyElement
      // this action will not be handled.
      this.send('stopEditing');
    });
  },

  updateEditorLockState: function() {
    if (this.get('lockedByCurrentUser')) {
      this.connectEditor();
    } else {
      this.disconnectEditor();
    }
  }.observes('lockedByCurrentUser'),

  updateEditor() {
    var editor = this.get('editor');
    if (editor) {
      editor.update();
    }
  },

  savePaper() {
    if (!this.get('model.editable')) {
      return;
    }
    var editor = this.get('editor');
    if(Ember.isEmpty(editor)) { return; }

    var paper = this.get('model');
    var manuscriptHtml = editor.getBodyHtml();
    paper.set('body', manuscriptHtml);
    if (paper.get('isDirty')) {
      return paper.save().then(()=>{
        this.set('saveState', true);
        this.set('isSaving', false);
      });
    } else {
      this.set('isSaving', false);
      return paper.save();
    }
  },

  connectEditor() {
    this.get('editor').connect();
  },

  disconnectEditor() {
    // TODO: temp fix?
    if(this.get('editor')) {
      this.get('editor').disconnect();
    }
  },

  getBodyHtml() {
    var editor = this.get('editor');
    return editor.getBodyHtml();
  },

  setBodyHtml(html) {
    var editor = this.get('editor');
    return editor.setBodyHtml(html);
  },

});

export default HtmlEditorController;
