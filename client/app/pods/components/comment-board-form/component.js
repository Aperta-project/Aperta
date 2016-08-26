import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

const {
  computed,
  isEmpty
} = Ember;

export default Ember.Component.extend({
  propTypes: {
    participants: PropTypes.array,
    atMentionableStaffUsers: PropTypes.array
  },

  getDefaultProps() {
    return {
      participants: [],
      atMentionableStaffUsers: []
    };
  },

  classNameBindings: ['editing', ':comment-board-form', 'form-group'],
  editing: false,
  comment: '',

  atMentionableUsersUnion: computed.union('participants', 'atMentionableStaffUsers'),

  atMentionableUsers: computed('atMentionableUsersUnion.[]', function() {
    const uniqueUsers = [];
    const currentUsername = this.get('currentUser.username');

    this.get('atMentionableUsersUnion').forEach(function(user) {
      if(!uniqueUsers.isAny('username', user.get('username'))
          && user.get('username') !== currentUsername){
        uniqueUsers.push(user);
      }
    });

    return uniqueUsers;
  }),

  clear() {
    this.set('comment', '');
    this.set('editing', false);
  },

  actions: {
    onChange(value) {
      const action = this.get('onChange');
      if(isEmpty(action)) { return; }
      action(value);
    },

    cancel() {
      this.clear();
      const action = this.get('onCancel');
      if(!isEmpty(action)) { action(); }
    },

    startEditing() {
      this.set('editing', true);
    },

    save() {
      if(isEmpty(this.get('comment'))) {
        return;
      }

      this.get('save')(this.get('comment'));
      this.clear();
    }
  }
});
