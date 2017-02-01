import Ember from 'ember';
import { filteredUsersPath } from 'tahi/lib/api-path-helpers';
import { task, timeout } from 'ember-concurrency';
import { mousedown as powerSelectFocus } from 'tahi/lib/power-select-event-trigger';
import { PropTypes } from 'ember-prop-types';

const {
  Component,
  computed,
  inject: {service},
  isPresent,
  run: {later, schedule}
} = Ember;

export default Component.extend({
  propTypes: {
    canManage: PropTypes.bool,
    currentParticipants: PropTypes.arrayOf(PropTypes.EmberObject).isRequired,
    displayEmails: PropTypes.bool,
    label: PropTypes.string,
    searching: PropTypes.bool,
    dropdownClass: PropTypes.string,
    // ember-power-select property
    afterOptionsComponent: PropTypes.string,

    // url OR paperId is required
    url: PropTypes.string,
    paperId: PropTypes.oneOfType([
      PropTypes.string,
      PropTypes.number
    ]),

    // actions:
    onRemove: PropTypes.func.isRequired,
    onSelect: PropTypes.func.isRequired,
    searchStarted: PropTypes.func.isRequired,
    searchFinished: PropTypes.func.isRequired
  },

  getDefaultProps() {
    return {
      currentParticipants: null,
      // display email of user in tooltip
      displayEmails: false,
      // used to toggle display of add button and search user field
      searching: false
    };
  },

  dropdownClass: 'aperta-select',
  classNames: ['participant-selector'],
  ajax: service(),

  participantUrl: computed('paperId', 'url', function() {
    return isPresent(this.get('url')) ?
      this.get('url') :
      filteredUsersPath(this.get('paperId'));
  }),

  canRemove: computed('canManage', 'currentParticipants.[]', function() {
    return this.get('canManage') && this.get('currentParticipants').length > 1;
  }),

  searchUsersTask: task(function* (term) {
    if(!Ember.testing) {
      yield timeout(250);
    }
    const { users } = yield this.get('ajax').request(this.get('participantUrl') + '?query=' + window.encodeURIComponent(term));
    const participantIds = this.get('currentParticipants').mapBy('id').map((num) => parseInt(num));
    return users.reject((user) => participantIds.includes(user.id));
  }),

  actions: {
    toggleSearching(newState) {
      if(newState) {
        this.get('searchStarted')(newState);
        schedule('afterRender', this, function() {
          powerSelectFocus(this.$('.ember-power-select-trigger'));
        });
        return;
      }

      // Give power-select a moment to hide dropdown component
      // Without this, set on undefined object error
      later(this, function() {
        this.get('searchFinished')(newState);
      }, 50);
    },

    handleInput(value) {
      if(value.length < 3) { return false; }
    },

    addParticipant(newParticipant) {
      return this.get('onSelect')(newParticipant);
    },

    removeParticipant(participant) {
      return this.get('onRemove')(participant.id);
    }
  }
});
