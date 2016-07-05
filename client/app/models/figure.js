import Ember from 'ember';
import DS from 'ember-data';
import SnapshotSource from 'tahi/models/snapshot-source';

export default SnapshotSource.extend({
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

  saveDebounced() {
    return Ember.run.debounce(this, this.save, 2000);
  },

  toHtml() {
    return "<figure itemscope data-id=\"" + (this.get('id')) + "\">\n  <h1 itemprop=\"title\">" + (this.get('title')) + "</h1>\n  <img src=\"" + (this.get('detailSrc')) + "\">\n  <figcaption>" + (this.get('caption')) + "</figcaption>\n</figure>";
  },

  reloadPaper() {
    return this.get('paper').reload();
  },

  save() {
    return this._super().then(() => {
      return this.reloadPaper();
    });
  }
});
