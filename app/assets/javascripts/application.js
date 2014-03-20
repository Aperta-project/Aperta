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
//= require jquery.turbolinks
//= require jquery_ujs
//= require jquery-fileupload/basicplus
//= require underscore
//= require bootstrap
//= require scrollToFixed
//= require chosen-jquery
//= require jquery.dotdotdot
//= require jquery.timeago
//= require ./polyfills
//= require react
//= require react-chosen
//= require spin
//= require turbolinks
//= require namespace
//= require_tree .

$(document).ready(function() {
  Tahi.init()
});
