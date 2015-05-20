import Ember from 'ember';

export default Ember.Mixin.create({
  out: function(selector, speed) {
    let defer = new Ember.RSVP.defer();
    $(selector).hide();

    if(Ember.testing) {
      defer.resolve();
      return { then(hollaback) { hollaback.apply(this); } };
    }

    Ember.run.later(defer, function() {
      defer.resolve();
    }, speed);

    return defer.promise;
  },

  'in': function(selector, speed) {
    let defer = new Ember.RSVP.defer();
    $(selector).show();

    Ember.run.later(defer, function() {
      defer.resolve();
    }, speed);

    return defer.promise;
  },

  animateOverlayIn: function(selector) {
    if (selector == null) { selector = '#overlay'; }

    Ember.run.later(function() {
      $('html').addClass('overlay-open');
    }, 30);

    return this['in'](selector, 150);
  },

  animateOverlayOut: function(selector) {
    if (selector == null) { selector = '#overlay'; }
    $('html').removeClass('overlay-open');
    return this.out(selector, 150);
  }
});
