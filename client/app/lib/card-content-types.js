// Every kind of card-content has a type, a view component (this is
// how to render the content in when viewed on a manuscript) and a
// preview component (how to render it in the editor preview). Often,
// the view and preview components are the same component.

const CONTENT_TYPES = [
  {
    contentType: 'root',
    component: 'card-content/display-children'
  }
];

export default {
  forType(type) {
    const substitution = _.find(CONTENT_TYPES, t => t.contentType === type);
    if (substitution) return substitution;
    return {component: `card-content/${type}`};
  }
};
