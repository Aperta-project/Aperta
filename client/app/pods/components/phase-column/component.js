import Ember from 'ember';

const { computed } = Ember;

export default Ember.Component.extend({
  classNames: ['column'],
  phase: null,
  paper: null,

  nextPosition: computed('phase.position', function() {
    return this.get('phase.position') + 1;
  }),

  sortedTasks: computed('phase.tasks.[]', function() {
    return this.get('phase.tasks').sortBy('position');
  }),

  checkIfNewPhase: Ember.on('didInitAttrs', function() {
    if(this.get('phase.isNew')) {
      Ember.run.scheduleOnce('afterRender', this, function() {
        this.animateIn();
      });
    }
  }),

  animateIn() {
    const beginProps    = { overflow: 'hidden', opacity: 0, width: '0px' };
    const completeProps = { overflow: 'visible' };
    const el = this.$();
    const width = el.css('width');

    return $.Velocity.animate(this.$(), {
      opacity: 1,
      width: width
    }, {
      duration: 400,
      easing: [250, 20],
      begin:    function() { el.css(beginProps); },
      complete: function() { el.css(completeProps); }
    });
  },

  animateOut() {
    const el = this.$();

    return $.Velocity.animate(this.$(), {
      opacity: 0,
      width: '0px'
    }, {
      duration: 200,
      easing: [0.00, 0.00, 1.00, 0.02],
      begin: function() { el.css('overflow', 'hidden'); }
    });
  },

  actions: {
    chooseNewCardTypeOverlay(phase) {
      this.sendAction('chooseNewCardTypeOverlay', phase);
    },

    savePhase(phase)        { this.sendAction('savePhase', phase); },
    addPhase(position)      { this.sendAction('addPhase', position); },
    rollbackPhase(phase)    { this.sendAction('rollbackPhase', phase); },
    showDeleteConfirm(task) { this.sendAction('showDeleteConfirm', task); },

    removePhase(phase) {
      this.animateOut().then(()=> {
        this.sendAction('removePhase', phase);
      });
    }
  }
});
