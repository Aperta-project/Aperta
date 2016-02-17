import Ember from 'ember';
var ParticipantSelectorComponent;

ParticipantSelectorComponent = Ember.Component.extend({

  classNames: ['participant-selector', 'select2-multiple'],

  init: function(){
    this._super(...arguments);
    this.set('selectedTemplate', this.getSelectedTemplate());
  },

  setupTooltips: (function() {
    return Ember.run.schedule('afterRender', this, function() {
      this.$('.select2-search-choice img').tooltip({
        placement: "bottom"
      });

      if (this.get('canManage')) {
        return this.$('.add-participant-button').tooltip({
          placement: "bottom"
        });
      }
    });
  }).on('didInsertElement').observes('currentParticipants.[]'),

  resultsTemplate: function(user) {
    var userInfo;
    userInfo = user.old_roles.length ? user.username + ", " + (user.old_roles.join(', ')) : user.username;
    return '<strong>' + user.full_name + '</strong><br><div class="suggestion-sub-value">' + userInfo + '</div>';
  },

  getSelectedTemplate: function() {
    return (user) => {
      var name, url;
      name = user.full_name || user.get('fullName');
      url = user.avatar_url || user.get('avatarUrl');
      if (this.get('canManage')) {
        return Ember.String.htmlSafe("<img alt='" + name + "' class='user-thumbnail-small' src='" + url + "' data-toggle='tooltip' title='" + name + "'/>");
      }
      else {
        return Ember.String.htmlSafe("<img alt='" + name + "' class='user-thumbnail-small' src='" + url + "' title='" + name + "'/>");
      }
    }
  },

  sortByCollaboration: function(a, b) {
    if (a.old_roles.length && !b.old_roles.length) {
      return -1;
    } else if (!a.old_roles.length && b.old_roles.length) {
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

  remoteSource: (function() {
    return {
      url: "/api/filtered_users/users/" + (this.get('paperId')) + "/",
      dataType: "json",
      quietMillis: 500,
      data: function(term) {
        return {
          query: term
        };
      },
      results: (function(_this) {
        return function(data) {
          data.filtered_users.sort(_this.sortByCollaboration);
          return {
            results: data.filtered_users
          };
        };
      })(this)
    };
  }).property(),

  actions: {
    addParticipant: function(newParticipant) {
      return this.attrs.onSelect(newParticipant.id);
    },
    removeParticipant: function(participant) {
      return this.attrs.onRemove(participant.id);
    },
    dropdownClosed: function() {
      this.$('.select2-search-field input').removeClass('active');
      return this.$('.add-participant-button').removeClass('searching');
    },
    activateDropdown: function() {
      this.$('.select2-search-field input').addClass('active').trigger('click');
      return this.$('.add-participant-button').addClass('searching');
    }
  }
});

export default ParticipantSelectorComponent;
