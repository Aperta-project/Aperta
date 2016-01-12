import Ember from 'ember';

export default Ember.Helper.extend({
  notifications: Ember.inject.service(),

  onDataChange: Ember.observer('notifications._data.[]', function() {
    this.recompute();
  }),

  compute(params, hash) {
    const count = this.get('notifications')
                      .count(hash.type, hash.id, hash['is-parent']);

    if(count) {
      return Ember.String.htmlSafe(
        '<span class="badge badge--red animation-scale-in">' + count + '</span>'
      );
    }

    return '';
  }
});
