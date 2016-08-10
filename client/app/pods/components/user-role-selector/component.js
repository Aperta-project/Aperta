import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['user-role-selector', 'select2-multiple'],

  selectOptions: Ember.computed.mapBy('journalRoles', 'selectItem'),
  selectSelected: Ember.computed.mapBy('userJournalRoles', 'selectItem'),

  actions: {
    dropdownClosed() {
      this.$('.select2-search-field input').removeClass('active');
      this.$('.assign-role-button').removeClass('searching');
    },

    activateDropdown() {
      this.$('.select2-search-field input').addClass('active').trigger('click');
      this.$('.assign-role-button').addClass('searching');
    }
  }
});
