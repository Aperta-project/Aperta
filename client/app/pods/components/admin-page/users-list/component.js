import Ember from 'ember';

export default Ember.Component.extend({
  store: Ember.inject.service(),
  classNames: ['admin-users-list'],
  placeholderText: 'Need to find a user? Search for them here.',
  searchQuery: '',
  showUserDetailsOverlay: false,

  resetSearch() {
    this.set('adminJournalUsers', null);
    this.set('placeholderText', null);
  },

  displayMatchNotFoundMessage() {
    this.set('placeholderText', 'No matching users found');
  },

  actions: {
    searchUsers() {
      this.resetSearch();
      this.get('store').query('admin-journal-user', {query: this.get('searchQuery')}).then((users) => {
        this.set('adminJournalUsers', users);
        if(Ember.isEmpty(users)) { this.displayMatchNotFoundMessage(); }
      });
    },

    showUserDetailsOverlay(user) {
      this.set('detailsForUser', user);
      this.set('showUserDetailsOverlay', true);
    },

    hideUserDetailsOverlay() {
      this.set('showUserDetailsOverlay', false);
    }
  }
});
