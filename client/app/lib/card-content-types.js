// Every kind of card-content has a type, a view component (this is
// how to render the content in when viewed on a manuscript) and a
// preview component (how to render it in the editor preview). Often,
// the view and preview components are the same component.

const CONTENT_TYPES = [
  {
    contentType: 'text',
    viewComponent: 'card-content/text/view',
    previewComponent: 'card-content/text/view'
  },
  {
    contentType: 'root',
    viewComponent: 'card-content/display-children/view',
    previewComponent: 'card-content/display-children/preview'
  }
];

export default {
  forType(type) {
    return _.find(CONTENT_TYPES, t => t.contentType === type);
  },

  types() {
    return CONTENT_TYPES;
  }
};
