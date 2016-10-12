import PageObject, {
  clickable,
  collection,
  text
} from 'ember-cli-page-object';

let uploaderQuestion = (scope) => {
  return {
    scope: scope,
    check: clickable('input[type=checkbox]'),
    additionalData: {
      scope: '.question-dataset',
      questionText: text('.question-text'),
      attachmentName: text('.attachment-item .file-link')
    }
  };
};

export default PageObject.create({
  questions: collection({
    itemScope: '.question .item'
  }),
  systematicReviews: uploaderQuestion('li.item:nth(1)'),
  metaAnalyses: uploaderQuestion('li.item:nth(2)')

});
