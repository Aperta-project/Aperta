import Ember from 'ember';
import PropTypeMixin, {PropTypes} from 'ember-prop-types'

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

  atMentionableUsersUnion: Ember.computed.union('participants', 'atMentionableStaffUsers'),

  atMentionableUsers: Ember.computed('atMentionableUsersUnion.[]', function() {
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

  _setupFocus: Ember.on('didInsertElement', function() {
    this.$('.new-comment-field').on('focus', ()=> {
      this.set('editing', true);
    });
  }),

  _teardownFocus: Ember.on('willDestroyElement', function() {
    this.$('.new-comment-field').off();
  }),

  clear() {
    this.set('comment', '');
    this.set('editing', false);
  },

  actions: {
    cancel() { this.clear(); },

    save() {
      if(Ember.isEmpty(this.get('comment'))) {
        return;
      }

      this.sendAction('save', this.get('comment'));
      this.clear();
    }
  }
});
