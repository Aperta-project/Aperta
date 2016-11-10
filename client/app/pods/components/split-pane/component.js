import Ember from 'ember';

export default Ember.Component.extend({
  eventBus: Ember.inject.service('event-bus'),
  classNames: ['split-pane'],

  minimumWidthPercent: 25,

  flexCss(value) {
    return {
      'flex': value
    };
  },

  handle()    { return this.$('.split-pane-drag-handle'); },
  firstPane() { return this.$('.split-pane-element:first'); },
  lastPane()  { return this.$('.split-pane-element:last'); },

  _go: Ember.on('didInsertElement', function() {
    Ember.run.scheduleOnce('afterRender', ()=> {
      this._setInitialWidths();
      this._setupDragHandle();
    });
  }),

  _setInitialWidths() {
    this.firstPane().css(
      this.flexCss((0.6).toString())
    );

    this.lastPane().css(
      this.flexCss((0.4).toString())
    );
  },

  _setupTouchEvents(handle) {
    const touchStart = 'touchstart.' + this.elementId;
    const touchMove  = 'touchmove.'  + this.elementId;
    const touchEnd   = 'touchend.'   + this.elementId;

    handle.on(touchStart, (e)=> {
      this.simulateMouseEvent(e, 'mouseover');
      this.simulateMouseEvent(e, 'mousemove');
      this.simulateMouseEvent(e, 'mousedown');
    }).on(touchMove, (e)=> {
      this.simulateMouseEvent(e, 'mousemove');
    }).on(touchEnd, (e)=> {
      this.simulateMouseEvent(e, 'mouseup');
      this.simulateMouseEvent(e, 'mouseout');
    });
  },

  simulateMouseEvent(event, simulatedType) {
    // Ignore multi-touch events
    if (event.originalEvent.touches.length > 1) {
      return;
    }

    event.preventDefault();

    const touch = event.originalEvent.changedTouches[0];
    const simulatedEvent = document.createEvent('MouseEvents');

    // Initialize the simulated mouse event using the touch event's coordinates
    simulatedEvent.initMouseEvent(
      simulatedType, // type
      true,          // bubbles
      true,          // cancelable
      window,        // view
      1,             // detail
      touch.screenX, // screenX
      touch.screenY, // screenY
      touch.clientX, // clientX
      touch.clientY, // clientY
      false,         // ctrlKey
      false,         // altKey
      false,         // shiftKey
      false,         // metaKey
      0,             // button
      null           // relatedTarget
    );

    // Dispatch the simulated event to the target element
    event.target.dispatchEvent(simulatedEvent);
  },

  _setupDragHandle() {
    const handle    = this.handle();
    const downEvent = 'mousedown.'  + this.elementId;
    const moveEvent = 'mousemove.'  + this.elementId;
    const upEvent   = 'mouseup.'    + this.elementId;

    if('ontouchend' in document) {
      this._setupTouchEvents(handle);
    }

    handle.on(downEvent, (e)=> {
      e.preventDefault();

      const handleWidth  = handle.outerWidth();
      const handleX = handle.offset().left + handleWidth  - e.pageX;
      const doc = $(document);
      const minWidth = this.get('minimumWidthPercent');
      const firstPane = this.firstPane();
      const lastPane  = this.lastPane();

      doc.on(moveEvent, (e)=> {
        const total = firstPane.outerWidth() + lastPane.outerWidth();

        const leftPercentage = (
          (e.pageX - firstPane.offset().left) +
          (handleX - handleWidth / 2)
        ) / total;
        const rightPercentage = 1 - leftPercentage;

        const leftTooSmall  = leftPercentage  * 100 < minWidth;
        const rightTooSmall = rightPercentage * 100 < minWidth;
        if(leftTooSmall || rightTooSmall) { return; }

        this.get('eventBus').publish('split-pane-resize');
        firstPane.css(this.flexCss(leftPercentage.toString()));
        lastPane.css(this.flexCss(rightPercentage.toString()));
      });

      doc.on(upEvent, ()=> {
        doc.off(moveEvent);
        doc.off(upEvent);
      });
    });
  },

  _teardownDragHandle: Ember.on('willDestroyElement', function() {
    this.$('.split-pane-drag-handle').off();
  })
});
