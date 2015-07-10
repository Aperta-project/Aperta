import Ember from 'ember';

export default Ember.Handlebars.makeBoundHelper(function(string) {
  if(arguments[1].hash.count !== 1) {
    return Ember.String.pluralize(string);
  }

  return string;
});
