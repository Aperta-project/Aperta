import Ember from 'ember';

const { computed } = Ember;

export default Ember.Component.extend({
  classNames: ['column'],

  phase: null,
  paper: null,

  nextPosition: computed('phase.position', function() {
    return this.get('phase.position') + 1;
  }),

  commentLooks: null,

  sortedTasks: computed('phase.tasks.[]', function() {
    return this.get('phase.tasks').sortBy('position');
  }),

  noCards: computed.empty('sortedTasks'),

  checkIfNewPhase: Ember.on('didInitAttrs', function() {
    if(this.get('phase.isNew')) {
      Ember.run.scheduleOnce('afterRender', this, function() {
        this.animateIn();
      });
    }
  }),

  setupSortable: Ember.on('didInsertElement', function() {
    const phaseId = this.get('phase.id');
    const self = this;

    this.$('.sortable').sortable({
      items: '.card',
      scroll: false,
      containment: '.columns',
      connectWith: '.sortable',

      update(event, ui) {
        let updatedOrder      = {};
        const senderPhaseId   = phaseId;
        const receiverPhaseId = ui.item.parent().data('phase-id') + '';
        const task = self.getTaskByID(ui.item.find('.card-content').data('id'));

        if(senderPhaseId !== receiverPhaseId) {
          self.sendAction('changePhaseForTask', task, receiverPhaseId);
          Ember.run.scheduleOnce('afterRender', self, function() {
            ui.item.remove();
          });
        }

        $(this).find('.card-content').each(function(index) {
          updatedOrder[$(this).data('id')] = index + 1;
        });

        self.updateSortOrder(updatedOrder);
      },

      start(event, ui) {
        // class added to set overflow: visible;
        $(ui.item).addClass('card--dragging')
                  .closest('.column-content')
                  .addClass('column-content--dragging');
      },

      stop(event, ui) {
        $(ui.item).removeClass('card--dragging')
                  .closest('.column-content')
                  .removeClass('column-content--dragging');
      }
    });
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

  updateSortOrder(updatedOrder) {
    this.beginPropertyChanges();
    this.get('phase.tasks').forEach(function(task) {
      task.set('position', updatedOrder[task.get('id')]);
    });
    this.endPropertyChanges();
    this.get('phase.tasks').invoke('save');
  },

  getTaskByID(taskId) {
    return this.get('phase.tasks').find(function(t) {
      return t.get('id') === taskId.toString();
    });
  },

  actions: {
    chooseNewCardTypeOverlay(phase) {
      this.sendAction('chooseNewCardTypeOverlay', phase);
    },

    viewCard(task, queryParams) {
      this.sendAction('viewCard', task, queryParams);
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
