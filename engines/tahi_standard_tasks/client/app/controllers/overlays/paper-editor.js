import TaskController from 'tahi/pods/paper/task/controller';
import Select2Assignees from 'tahi/mixins/controllers/select-2-assignees';
import RESTless from 'tahi/services/rest-less';
import Ember from 'ember';

const { computed } = Ember;

export default TaskController.extend(Select2Assignees, {
  selectedUser: null,
  composingEmail: false,

  hasInvitedInvitation: computed.equal('model.invitation.state', 'invited'),
  hasRejectedInvitation: computed.equal('model.invitation.state', 'rejected'),

  showEditorSelect: computed('model.editor', 'model.invitation', 'model.invitation.state', function(){
    if (this.get('model.editor')) {
      return false;
    } else if (Ember.isEmpty(this.get('model.invitation'))) {
      return true;
    } else {
      return this.get('model.invitation.state') === "accepted";
    }
  }),

  select2RemoteSource: computed('select2RemoteUrl', function(){
    return {
      url: this.get('select2RemoteUrl'),
      dataType: "json",
      quietMillis: 500,
      data: function(term) {
        return {
          query: term
        };
      },
      results: function(data) {
        return {
          results: data.filtered_users
        };
      }
    };
  }),

  select2RemoteUrl: computed('model.paper', function(){
    return "/api/filtered_users/editors/" + (this.get('model.paper.id')) + "/";
  }),

  template: computed.alias('model.invitationTemplate'),

  setLetterTemplate: function() {
    let customTemplate;
    customTemplate = this.get('template').
      replace(/\[EDITOR NAME\]/, this.get('selectedUser.fullName')).
      replace(/\[YOUR NAME\]/, this.get('currentUser.fullName'));
    return this.set('updatedTemplate', customTemplate);
  },

  actions: {
    cancelAction() {
      this.set('selectedUser', null);
      return this.set('composingEmail', false);
    },

    composeInvite() {
      if (!this.get('selectedUser')) {
        return;
      }
      this.setLetterTemplate();
      return this.set('composingEmail', true);
    },

    didSelectEditor(select2User) {
      return this.store.find('user', select2User.id).then((user) => {
        return this.set('selectedUser', user);
      });
    },

    removeEditor() {
      let promises = [],
          deleteUrl = "/api/papers/" + (this.get('model.paper.id')) + "/editor";
      promises.push(RESTless.delete(deleteUrl));
      if (this.get('model.invitation')) {
        promises.push(this.get('model.invitation').destroyRecord());
      }
      return Ember.RSVP.all(promises).then(() => {
        var editor = this.get('model')._relationships.editor;
        return editor.setCanonicalRecord(null);
      });
    },
    setLetterBody() {
      this.set('model.body', [this.get('updatedTemplate')]);
      this.model.save();
      return this.send('inviteEditor');
    },
    inviteEditor() {
      var invitation;
      invitation = this.store.createRecord('invitation', {
        task: this.get('model'),
        email: this.get('selectedUser.email')
      });
      invitation.save().then(() => {
        return this.get('model').set('invitation', invitation);
      });
      return this.set('composingEmail', false);
    },
    destroyInvitation() {
      return this.get('model.invitation').destroyRecord();
    }
  }
});
