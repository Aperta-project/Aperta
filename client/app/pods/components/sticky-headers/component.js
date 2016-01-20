import Ember from 'ember';

export default Ember.Component.extend({
  eventBus: Ember.inject.service('event-bus'),
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
    this.get('eventBus').unsubscribe('split-pane-resize', this);
  }),

  _setup: Ember.on('didInsertElement', function() {
    const position = this._positionAll.bind(this);

    Ember.run.scheduleOnce('afterRender', ()=> {
      // Note: This element needs to be scrollable!
      this.$().on('scroll.' + this.elementId, function() {
        position();
      });

      $(window).on('resize.' + this.elementId, function() {
        position();
      });

      this.get('eventBus').subscribe('split-pane-resize', this, function() {
        position();
      });
    });
  }),

  _positionAll() {
    const sections = this.$(this.get('sectionSelector'));
    const position = this._positionSingle;
    const stickySelector = this.get('stickySelector');

    sections.each(function() {
      const stickyElement = $(this).find(stickySelector);
      position($(this), stickyElement);
    });
  },

  _positionSingle(section, stickyElement) {
    const amountAboveTop = section.position().top;

    if(amountAboveTop > 0) {
      stickyElement.css('top', '');
      return;
    }

    const top = amountAboveTop * -1,
          sectionHeight = section.outerHeight(),
          stickyHeight = stickyElement.outerHeight(),
          noRoomForSticky = (sectionHeight + amountAboveTop) < stickyHeight;

    stickyElement.css(
      'top',
      noRoomForSticky ? top - (top-sectionHeight) - stickyHeight : top
    );
  }
});
