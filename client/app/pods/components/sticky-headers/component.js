import Ember from 'ember';

export default Ember.Component.extend({
  /**
   *  jquery selector for elements that should be sticky
   *
   *  @property stickySelector
   *  @type String
   *  @default null
   *  @required
  **/
  stickySelector: null,

  /**
   *  jquery selector for containers that contain a sticky element
   *
   *  @property sectionSelector
   *  @type String
   *  @default null
   *  @required
  **/
  sectionSelector: null,

  init() {
    this._super(...arguments);

    Ember.assert('sticky-headers requires a stickySelector property',
                 this.get('stickySelector'));

    Ember.assert('sticky-headers requires a sectionSelector property',
                 this.get('sectionSelector'));
  },

  _teardown: Ember.on('willDestroyElement', function() {
    this.$().off('scroll.' + this.elementId);
    $(window).off('resize.' + this.elementId);
  }),

  _setup: Ember.on('didInsertElement', function() {
    const sectionSelector = this.get('sectionSelector');
    const stickySelector  = this.get('stickySelector');
    const position = this._position;
    const handleEvent = function(sections) {
      sections.each(function() {
        const section = $(this);
        const sticky  = section.find(stickySelector);
        position(section, sticky);
      });
    };

    Ember.run.scheduleOnce('afterRender', ()=> {
      const sections = this.$().find(sectionSelector);

      // Note: This element needs to be scrollable!
      this.$().on('scroll.' + this.elementId, function() {
        handleEvent(sections);
      });

      $(window).on('resize.' + this.elementId, function() {
        handleEvent(sections);
      });
    });
  }),

  _position(section, sticky) {
    const amountAboveTop = section.position().top;

    if(amountAboveTop > 0) {
      sticky.css('top', '');
      return;
    }

    const top = amountAboveTop * -1,
          height = section.outerHeight(),
          stickyHeight = sticky.outerHeight(),
          noRoomForSticky = (height + amountAboveTop) < stickyHeight,
          Y = (noRoomForSticky ? top - (top-height) - stickyHeight : top);

    sticky.css('top', Y);
  }
});
