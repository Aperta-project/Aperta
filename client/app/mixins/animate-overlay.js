import Ember from 'ember';

let animationEventName = function() {
  var a;
  var el = document.createElement('fakeelement');
  var animations = {
    'animation': 'animationend',
    'OAnimation': 'oanimationend',
    'MSAnimation': 'msAnimationEnd',
    'WebkitAnimation': 'webkitAnimationEnd'
  };

  for(a in animations){
    if(el.style[a] !== undefined){
      return animations[a];
    }
  }
};

export default Ember.Mixin.create({
  out: function() {
    let element   = $('.overlay');
    let eventName = animationEventName();

    if(eventName) {
      return new Ember.RSVP.Promise(function(resolve) {
        $('html').removeClass('overlay-open');
        element.removeClass('animation-fade-in')
               .addClass('animation-fade-out')
               .one(eventName, function() { resolve(); });
      });
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
    let eventName = animationEventName();

    if(eventName) {
      return new Ember.RSVP.Promise(function(resolve) {
        Ember.run.later(function() { $('html').addClass('overlay-open'); }, 30);
        element.addClass('animation-fade-in')
               .one(eventName, function() { resolve(); });
      });
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
