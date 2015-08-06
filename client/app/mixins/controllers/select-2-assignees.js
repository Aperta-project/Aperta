import Ember from 'ember';

export default Ember.Mixin.create({
  select2RemoteSource: Ember.computed('select2RemoteUrl', function() {
    return {
      url: this.get('select2RemoteUrl'),
      dataType: 'json',
      quietMillis: 500,
      data(term) {
        return {
          query: term
        };
      },
      results(data) {
        return {
          results: data.filtered_users
        };
      }
    };
  }),

  resultsTemplate(user) {
    /* Handle raw object or ember model */
    let email = (typeof(user.email) === 'string') ? user.email : user.get('email');
    let fullName = user.full_name || user.get('fullName');
    return `${fullName} <span class="select2-assignee-email">[${email}]</span>`;
  }
});
