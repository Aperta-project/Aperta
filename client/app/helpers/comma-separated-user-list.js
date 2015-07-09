import Ember from 'ember';

export default Ember.Handlebars.makeBoundHelper(function(users) {
  let string = users.map(function(u) {
    return `${u.first_name} ${u.last_name}`;
  }).join(', ');

  return new Ember.Handlebars.SafeString(string);
});
