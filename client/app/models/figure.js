import Ember from 'ember';
import DS from 'ember-data';
import Snapshottable from 'tahi/mixins/snapshottable';

export default DS.Model.extend(Snapshottable, {
  restless: Ember.inject.service('restless'),
  paper: DS.belongsTo('paper', { async: false }),

  alt: DS.attr('string'),
  caption: DS.attr('string'),
  createdAt: DS.attr('date'),
  updatedAt: DS.attr('date'),
  detailSrc: DS.attr('string'),
  filename: DS.attr('string'),
  previewSrc: DS.attr('string'),
  src: DS.attr('string'),
  status: DS.attr('string'),
  title: DS.attr('string'),
  strikingImage: DS.attr('boolean'),
  rank: DS.attr('number'),

  saveDebounced() {
    return Ember.run.debounce(this, this.save, 2000);
  },

  save() {
    let paper = this.get('paper');
    return this._super().then(() => {
      return paper.reload();
    });
  },

  cancelUpload() {
    this.deleteRecord();
    return this.get('restless').put(`/api/figures/${this.get('id')}/cancel`);
  }
});
