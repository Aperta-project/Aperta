import Ember from 'ember';

export default Ember.Handlebars.makeBoundHelper(function(text) {
  return new Ember.Handlebars.SafeString(text.replace(/\n/g, '<br>'));
});
