import Ember from 'ember';

export default Ember.Handlebars.makeBoundHelper(function(users) {
  let string = users.map(function(u) {
    return `${u.first_name} ${u.last_name}`;
  }).join(', ');

  return Ember.String.htmlSafe(string);
});
