import Ember from 'ember';

export default Ember.Helper.extend({
  notifications: Ember.inject.service(),

  onDataChange: Ember.observer('notifications.data.[]', function() {
    this.recompute();
  }),

  compute(params, hash) {
    const type = hash.type;
    const id   = parseInt(hash.id);

    const count = this.get('notifications').get('data').filter(n => {
      if(id && type && type === 'paper') {
        return n.paper_id === id;
      }

      if(type && id) {
        return n.target_id === id && n.target_type === type;
      }
    }).get('length');

    if(count) {
      return Ember.String.htmlSafe(
        '<span class="badge badge--red animation-scale-in">' + count + '</span>'
      );
    }

    return '';
  }
});
