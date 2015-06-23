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

$.fn.redraw = function() {
  return $(this).each(function() {
    return this.offsetHeight;
  });
};

export default Ember.Mixin.create({
  out: function(options) {
    $(options.selector).hide().attr('class', 'overlay');

    return {
      then(callback) {
        if(callback) { callback(); }
      }
    };
  },

  'in': function(options) {
    let animationName = animationEventName();
    let overlayElement = $(options.selector).hide();

    // reset all classes on overlay
    overlayElement.attr('class', 'overlay');

    if(options.extraClasses) {
      overlayElement.addClass(options.extraClasses);
    }

    if(options.skipAnimation || Ember.testing || !animationName) {
      overlayElement.show().addClass('overlay--visible');

      return {
        then(callback) {
          if(callback) { callback();}
        }
      };
    }

    return new Ember.RSVP.Promise(function(resolve) {
      overlayElement.show()
                    .redraw()
                    .addClass('animation-fade-in')
                    .one(animationName, function() { resolve(); });
    });
  },

  animateOverlayIn: function(options={}) {
    if (!options.selector) { options.selector = '#overlay'; }

    Ember.run.later(function() { $('html').addClass('overlay-open'); }, 30);

    return this['in'](options);
  },

  animateOverlayOut: function(options={}) {
    if (!options.selector) { options.selector = '#overlay'; }
    $('html').removeClass('overlay-open');
    return this.out(options);
  }
});
