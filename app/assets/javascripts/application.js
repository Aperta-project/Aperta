// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-fileupload/basicplus
//= require underscore
//= require bootstrap
//= require scrollToFixed
//= require chosen-jquery
//= require jquery.dotdotdot
//= require jquery.timeago
//= require typeahead
//= require utils
//= require handlebars
//= require spin.js/spin
//= require ember
//= require ember-data
//= require_self
//= require e_tahi
//= require bootstrap-datepicker
//= require_tree .
//= require standard_tasks/application

(function(context) {
  context.ETahi = Ember.Application.create({
    rootElement: '#ember-app',

    // Ember
    LOG_STACKTRACE_ON_DEPRECATION  : true,
    LOG_BINDINGS                   : true,
    LOG_TRANSITIONS                : true,
    LOG_TRANSITIONS_INTERNAL       : false,
    LOG_VIEW_LOOKUPS               : false,
    LOG_ACTIVE_GENERATION          : false,
    // Tahi
    LOG_RSVP_ERRORS                : true,
    LOG_VIEW_RENDERING_PERFORMANCE : true
  });

  ETahi.ApplicationAdapter = DS.ActiveModelAdapter.extend({
    ajaxError: function(jqXHR) {
      var error = this._super(jqXHR);
      if (jqXHR && jqXHR.status === 401) {
        window.location.href = '/users/sign_in'
      }
      return error;
    }
  });

  ETahi.computed = {};
  ETahi.computed.all = function(hasMany, key, value){
    return Em.computed(hasMany+'.@each.'+key, function(){
      return this.get(hasMany).everyProperty(key, value);
    });
  };

  $(document).ajaxError(function(event, jqXHR, ajaxSettings, thrownError) {
    if (jqXHR.status === 401) {
      document.location.href = '/users/sign_in';
    }
  });
})(window);

$.extend($.easing, {
  easeInCubic: function (x, t, b, c, d) {
    return c*(t/=d)*t*t + b;
  }
});
