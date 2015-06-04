export default function() {
  this.transition(
    this.fromRoute('paper.workflow.discussions.index'),
    this.toRoute('paper.workflow.discussions.show'),
    this.use('toLeft',      { duration: 600, easing: [300, 25] }),
    this.reverse('toRight', { duration: 600, easing: [300, 25] })
  );

  this.transition(
    this.fromRoute('paper.workflow.discussions.index'),
    this.toRoute('paper.workflow.discussions.new'),
    this.use('toLeft',      { duration: 600, easing: [300, 25] }),
    this.reverse('toRight', { duration: 600, easing: [300, 25] })
  );

  this.transition(
    this.fromRoute('paper.workflow.discussions.new'),
    this.toRoute('paper.workflow.discussions.show'),
    this.use('toLeft',      { duration: 600, easing: [300, 25] }),
    this.reverse('toRight', { duration: 600, easing: [300, 25] })
  );
}
