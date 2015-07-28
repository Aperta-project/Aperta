import Ember from 'ember';

export default Ember.Mixin.create({
  select2RemoteSource: function() {
    return {
      url: this.get('select2RemoteUrl'),
      dataType: 'json',
      quietMillis: 500,
      data: function(term) {
        return {
          query: term
        };
      },
      results: function(data) {
        return {
          results: data.filtered_users
        };
      }
    };
  }.property('select2RemoteUrl'),

  resultsTemplate(user) {
    /* Handle raw object or ember model */
    let email = (typeof(user.email) === 'string') ? user.email : user.get('email');
    return `${user.full_name || user.get('fullName')} <span class="select2-assignee-email">[${email}]</span>`;
  }
});
