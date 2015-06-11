export default function() {
  this.transition(
    this.fromRoute(function(routeName){ return (/paper\.[^.]*\.discussions\.index/).test(routeName);}),
    this.toRoute(function(routeName)  { return (/paper\.[^.]*\.discussions\.show/).test(routeName); }),
    this.use('slideToLeft',      { duration: 600, easing: [300, 25] }),
    this.reverse('slideToRight', { duration: 600, easing: [300, 25] })
  );

  this.transition(
    this.toRoute(function(routeName){ return (/paper\.[^.]*\.discussions\.new/).test(routeName); }),
    this.use('slideToLeft',      { duration: 600, easing: [300, 25] }),
    this.reverse('slideToRight', { duration: 600, easing: [300, 25] })
  );
}
