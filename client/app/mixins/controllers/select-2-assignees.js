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
    return `${user.full_name} <span class="select2-assignee-email">[${user.email}]</span>`;
  },

  selectedTemplate(user) {
    return user.full_name || user.get('fullName');
  }
});
