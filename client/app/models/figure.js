import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  paper: DS.belongsTo('paper'),

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

  updatePaperFigures: function() {
    let paperFigures = this.get('paper.figures');
    paperFigures.addObject(this);
  }.on('didLoad'),

  isStrikingImage: false,

  strikingImageDidChange: function() {
    this.set('isStrikingImage', this.get('paper.strikingImageId') === this.get('id'));
  }.observes('paper.strikingImageId').on('didLoad'),

  saveDebounced() {
    return Ember.run.debounce(this, this.save, 2000);
  },

  toHtml() {
    return "<figure itemscope data-id=\"" + (this.get('id')) + "\">\n  <h1 itemprop=\"title\">" + (this.get('title')) + "</h1>\n  <img src=\"" + (this.get('src')) + "\">\n  <figcaption>" + (this.get('caption')) + "</figcaption>\n</figure>";
  }
});
