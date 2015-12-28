import Ember from 'ember';
import DS from 'ember-data';

const { attr, belongsTo } = DS;

export default DS.Model.extend({
  paper: belongsTo('paper'),
  title: attr('string'),
  body: attr('string'),
  caption: attr('string'),
  createdAt: attr('date'),
  updatedAt: attr('date'),

  toHtml() {
    return `
    <figure itemscope data-id="${this.get('id')}" data-type="table">
      <h1 itemprop="title">${this.get('title')}</h1>
      ${this.get('body')}
      <figcaption>${this.get('caption')}</figcaption>
    </figure>
    `;
  },

  saveDebounced() {
    return Ember.run.debounce(this, this.save, 2000);
  }
});
