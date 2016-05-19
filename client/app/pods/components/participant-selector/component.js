import Ember from 'ember';
import { filteredUsersPath } from 'tahi/lib/api-path-helpers';

let hasOldRoles = user => user.old_roles && user.old_roles.length;

export default Ember.Component.extend({
  classNames: ['participant-selector', 'select2-multiple'],

  //passed in
  paperId: null,
  url: null,
  currentParticipants: null,
  label: null,
  canManage: null,
  displayEmails: false,

  participantUrl: Ember.computed('paperId', 'url', function() {
    let url = this.get('url');
    if (Ember.isPresent(url)) {
      return url;
    } else {
      return filteredUsersPath(this.get('paperId'));
    }
  }),

  setupTooltips: (function() {
    return Ember.run.schedule('afterRender', this, function() {
      this.$('.select2-search-choice img').tooltip({
        placement: 'bottom'
      });

      if (this.get('canManage')) {
        this.$('.add-participant-button').tooltip({
          placement: 'bottom'
        });
      }
    });
  }).on('didInsertElement').observes('currentParticipants.[]'),

  // select2 uses this to show the actual autocomplete results
  resultsTemplate: function(user) {
    // This template accomodates user payloads from two kinds of serializers:
    // 1. SensitiveInformationUserSerializer (id, full_name, avatar_url, email)
    // 2. FilteredUserSerializer             (id, full_name, avatar_url, username, old_roles)
    let userInfo = hasOldRoles(user) ? user.email + ", " + (user.old_roles.join(', ')) : user.email;
    return `<strong>${user.full_name} @${user.username}</strong><br>
            <div class="suggestion-sub-value">${userInfo || ''}</div>`;
  },

  // select2 uses this to list the already-selected items
  // Return function resolved when "this" in the context of this component,
  // as opposed to resolving later in select-2 where "this" has a context
  // within the select-2 object.
  selectedTemplate: Ember.computed('displayEmails', 'canManage', function() {
    return (user) => {
      let name = user.full_name || user.get('fullName');
      let url = user.avatar_url || user.get('avatarUrl');
      var email = '';
      if (this.get('displayEmails')) {
        email = Ember.get(user, 'email');
      }
      let title = `${name} ${email || ''}`.trim();
      let toggle = this.get('canManage') ? `data-toggle='tooltip'` : '';
      return Ember.String.htmlSafe(
        `<img
            alt='${name}'
            class='user-thumbnail-small'
            src='${url}'
            ${toggle}
            title='${title}'/>`);
    };
  }),

  sortByCollaboration: function(a, b) {
    if (hasOldRoles(a) && !hasOldRoles(b)) {
      return -1;
    } else if (!hasOldRoles(a) && hasOldRoles(b)) {
      return 1;
    } else {
      if (a.full_name < b.full_name) {
        return -1;
      } else if (a.full_name > b.full_name) {
        return 1;
      } else {
        return 0;
      }
    }
  },

  //used to translate our participant into a full user later
  foundParticipants: null,

  remoteSource: Ember.computed('participantUrl', function () {
    return {
      url: this.get('participantUrl'),
      dataType: 'json',
      quietMillis: 500,
      data: function(term) {
        return {
          query: term
        };
      },
      results: (function(_this) {
        return function(data) {
          _this.set('foundParticipants', data.users);
          data.users.sort(_this.sortByCollaboration);
          return {
            results: data.users
          };
        };
      })(this)
    };
  }),

  actions: {
    addParticipant: function(newParticipant) {
      return this.attrs.onSelect(newParticipant, this.get('foundParticipants'));
    },
    removeParticipant: function(participant) {
      return this.attrs.onRemove(participant.id);
    },
    dropdownClosed: function() {
      this.$('.select2-search-field input').removeClass('active');
      this.$('.add-participant-button').removeClass('searching');
    },
    activateDropdown: function() {
      this.$('.select2-search-field input').addClass('active').trigger('click');
      this.$('.add-participant-button').addClass('searching');
    }
  }
});
