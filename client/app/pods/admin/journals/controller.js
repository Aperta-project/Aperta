import Ember from 'ember';

export default Ember.Controller.extend({
  sortProperties: ['createdAt'],
  sortAscending: false,
  placeholderText: 'Need to find a user? Search for them here.',
  searchQuery: '',
  detailsForUser: null,
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
      const q = {query: this.get('searchQuery')};
      this.store.find( 'admin-journal-user', q).then((users) => {
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
