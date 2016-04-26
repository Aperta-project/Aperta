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
          results: data.users
        };
      }
    };
  }),

  resultsTemplate(user) {
    let email = (typeof(user.email) === 'string') ? user.email : user.get('email');

    if (user.full_name) {
      let fullName = user.full_name;
      return `${fullName} <span class="select2-assignee-email">[${email}]</span>`;
    } else {
      return `${email} <span class="select2-assignee-email">[${email}]</span>`;
    }
  }
});
