import Ember from 'ember';

export default Ember.View.extend({
  didInsertElement() {
    this._super();
    return Ember.run.scheduleOnce('afterRender', this, this.afterRenderEvent);
  },

  afterRenderEvent() {
    $('#card-overlays > a').click(function() {
      return $(this).next().removeClass('hide');
    });
    $('*[overlay]').children().hide();
    $('.toggle-link').click(function() {
      return $(this).parents('.ui-element').find('*[element-name]').children().show();
    });
    $('.overlay .overlay-close-button, .overlay-close-x').click(function() {
      return $(this).parents('.ui-element').find('*[element-name]').children().hide();
    });
    $('.control-bar').css('position', 'relative');
    $('.columns').css('position', 'initial');
    $('.columns').css('height', '450px');
    $('#toggle-all-source').click(function() {
      return $('.collapse').toggle();
    });
    let setScrollWindow = function() {
      $('.col-md-10').height(function() {
        return $(window).height() - 125;
      });
      return $('.col-md-10').css('overflow-y', 'scroll');
    };

    $('#auto-suggest-input').on('keyup', (event)=> {
      const input = $(event.target);
      if(Ember.isEmpty(input.val())) {
        this.set('controller.showAutoSuggest', false);
      } else {
        this.set('controller.showAutoSuggest', true);
      }
    });

    $(window).resize(setScrollWindow());
    $('.show-child-mmt-thumbnail .mmt-thumbnail .mmt-thumbnail-overlay--edit-options').show();
    $('.show-child-confirm-destroy .mmt-thumbnail-overlay--confirm-destroy').show();
  }
});
