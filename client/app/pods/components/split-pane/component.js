import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['split-pane'],

  minimumWidthPercent: 25,

  flexCss(value) {
    return {
      'flex': value,
      '-ms-flex': value,
      '-moz-flex': value,
      '-webkit-flex': value,
      'box-flex': value,
      '-webkit-box-flex': value
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

  _setupDragHandle() {
    const handle    = this.handle(),
          downEvent = 'mousedown.' + this.elementId,
          moveEvent = 'mousemove.' + this.elementId,
          upEvent   = 'mouseup.'   + this.elementId;

    handle.on(downEvent, (e)=> {
      e.preventDefault();

      const handleWidth  = handle.outerWidth(),
            handleX = handle.offset().left + handleWidth  - e.pageX,
            doc = $(document),
            minWidth = this.get('minimumWidthPercent'),
            firstPane = this.firstPane(),
            lastPane  = this.lastPane();

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
