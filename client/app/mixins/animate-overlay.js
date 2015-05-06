import Ember from 'ember';

let transitionEventName = function() {
  var t;
  var el = document.createElement('fakeelement');
  var transitions = {
    'transition':'transitionend',
    'OTransition':'oTransitionEnd',
    'MozTransition':'transitionend',
    'WebkitTransition':'webkitTransitionEnd'
  };

  for(t in transitions){
    if(el.style[t] !== undefined){
      return transitions[t];
    }
  }
};

export default Ember.Mixin.create({
  out: function() {
    let element   = $('.overlay');
    let eventName = transitionEventName();

    if(eventName) {
      let promise = new Ember.RSVP.Promise(function(resolve) {
        element.one(eventName, function() {
          resolve();
        });
      });

      $('html').removeClass('overlay-open');
      element.removeClass('animation-fade-in').addClass('animation-fade-out');

      return promise;
    } else {
      // NEEDED FOR IE9. Remove if statements when IE9 support is dropped!
      let defer = new Ember.RSVP.defer();

      $('.overlay').removeClass('animation-fade-in').addClass('animation-fade-out');
      Ember.run.later(defer, function() {
        defer.resolve();
      }, 230);

      return defer.promise;
    }
  },

  "in": function() {
    let element   = $('.overlay');
    let eventName = transitionEventName();

    if(eventName) {
      let promise = new Ember.RSVP.Promise(function(resolve) {
        element.one(eventName, function() {
          resolve();
        });
      });

      Ember.run.later(function() { $('html').addClass('overlay-open'); }, 30);
      element.addClass('animation-fade-in');

      return promise;
    } else {
      // NEEDED FOR IE9. Remove if statements when IE9 support is dropped!
      let defer = new Ember.RSVP.defer();

      $('.overlay').addClass('animation-fade-in');
      Ember.run.later(defer, function() {
        defer.resolve();
      }, 330);

      return defer.promise;
    }
  },

  animateOverlayIn:  function() { return this['in']();  },
  animateOverlayOut: function() { return this['out'](); }
});
