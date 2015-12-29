import Ember from 'ember';
import resizeColumnHeaders from 'tahi/lib/resize-column-headers';

export default Ember.Component.extend({
  classNames: ['column-header'],
  classNameBindings: ['active'],

  active: false,
  previousContent: null,

  currentHeaderHeight: Ember.computed('phase.name', function() {
    return this.$().find('.column-title').height();
  }),

  focusIn(e) {
    this.set('active', true);
    if ($(e.target).attr('contentEditable')) {
      this.set('oldPhaseName', this.get('phase.name'));
    }
  },

  input() {
    if (this.get('currentHeaderHeight') <= 58) {
      return this.set('previousContent', this.get('phase.name'));
    } else {
      return this.set('phase.name', this.get('previousContent'));
    }
  },

  phaseNameDidChange: Ember.observer('phase.name', function() {
    return Ember.run.scheduleOnce('afterRender', this, resizeColumnHeaders);
  }),

  actions: {
    save() {
      this.set('active', false);
      this.sendAction('savePhase', this.get('phase'));
    },

    remove() {
      this.sendAction('removePhase', this.get('phase'));
    },

    cancel() {
      this.set('active', false);
      this.sendAction('rollbackPhase', this.get('phase'), this.get('oldPhaseName'));
      Ember.run.scheduleOnce('afterRender', this, resizeColumnHeaders);
    }
  }
});
