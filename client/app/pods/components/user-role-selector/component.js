import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['user-role-selector', 'select2-multiple'],

  actions: {
    assignOldRole(data) {
      this.sendAction('selected', data);
    },

    removeOldRole(data) {
      this.sendAction('removed', data);
    },

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
