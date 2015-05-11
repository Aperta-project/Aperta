import Ember from 'ember';

export default Ember.Handlebars.makeBoundHelper(function(count, classString) {
  if (count > 0) {
    return new Ember.Handlebars.SafeString("<span class='badge " + classString + "'>" + count + "</span>");
  } else {
    return new Ember.Handlebars.SafeString("");
  }
});
