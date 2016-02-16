import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';
import Select2Assignees from 'tahi/mixins/controllers/select-2-assignees';

const { computed } = Ember;

export default TaskComponent.extend(Select2Assignees, {
  restless: Ember.inject.service('restless'),
  selectedUser: null,
  composingEmail: false,

  hasInvitedInvitation: computed.equal('task.invitation.state', 'invited'),
  hasRejectedInvitation: computed.equal('task.invitation.state', 'rejected'),

  showEditorSelect: computed(
    'task.academicEditor', 'task.invitation', 'task.invitation.state', function() {
      if (this.get('task.academicEditor')) {
        return false;
      } else if (Ember.isEmpty(this.get('task.invitation'))) {
        return true;
      } else {
        return this.get('task.invitation.state') === 'accepted';
      }
    }
  ),

  select2RemoteSource: computed('select2RemoteUrl', function(){
    return {
      url: this.get('select2RemoteUrl'),
      dataType: 'json',
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

  select2RemoteUrl: computed('task.paper', function(){
    return '/api/filtered_users/editors/' + (this.get('task.paper.id')) + '/';
  }),

  setLetterTemplate: function() {
    const customTemplate = this.get('task.invitationTemplate').
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
      const promises = [],
            deleteUrl = '/api/papers/' + (this.get('task.paper.id')) + '/editor';

      promises.push(this.get('restless').delete(deleteUrl));

      if (this.get('task.invitation')) {
        promises.push(this.get('task.invitation').destroyRecord());
      }
      return Ember.RSVP.all(promises).then(() => {
        const editor = this.get('task')._relationships.academicEditor;
        return editor.setCanonicalRecord(null);
      });
    },

    setLetterBody() {
      this.set('task.body', [this.get('updatedTemplate')]);
      this.get('task').save();
      return this.send('inviteEditor');
    },

    inviteEditor() {
      const invitation = this.store.createRecord('invitation', {
        task: this.get('task'),
        email: this.get('selectedUser.email')
      });

      invitation.save();
      return this.set('composingEmail', false);
    },

    destroyInvitation() {
      return this.get('task.invitation').destroyRecord();
    }
  }
});
