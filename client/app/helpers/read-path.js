import Ember from 'ember';

export default Ember.Helper.helper(function([object, path]) {
  // TODO: When upgraded to Ember 2.0 this should be removed in
  // favor of the Handlebars `get` helper
  return Ember.get(object, path);
});
