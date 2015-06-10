export default function() {
  this.transition(
    this.toRoute('paper.workflow.discussions.show'),
    this.use('slideToLeft',      { duration: 600, easing: [300, 25] }),
    this.reverse('slideToRight', { duration: 600, easing: [300, 25] })
  );

  this.transition(
    this.toRoute('paper.workflow.discussions.new'),
    this.use('slideToLeft',      { duration: 600, easing: [300, 25] }),
    this.reverse('slideToRight', { duration: 600, easing: [300, 25] })
  );
}
