import Ember from 'ember';

// For Paper Tracker
export default Ember.Helper.helper(function(params, hash) {
  if (hash.users == undefined) return '';

  let string = hash.users.map(function(u) {
    return `${u.first_name} ${u.last_name}`;
  }).join(', ');

  return Ember.String.htmlSafe(string);
});
