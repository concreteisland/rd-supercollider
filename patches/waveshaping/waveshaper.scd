
~wavetable = Buffer.alloc(s, 1024, 1);

~upper = Env.new([0,1], [1]).asSignal(256);
~lower = ~upper.copy;
~lower.invert.reverse;
~signal=~lower;
~signal = ~signal.add(0);
~signal = ~signal.addAll(~upper);
~wavetable.sendCollection(~signal.asWavetableNoWrap);
~signal.plot;

((~signal*2)-1).plot

~wavetable.plot

(
{
	var signal = SinOsc.ar(200);
	var shaped = Shaper.ar(~wavetable,signal);
	//[signal, shaped];
	shaped
}.scope
)

b = Buffer.alloc(s, 512, 1, { |buf| buf.chebyMsg([1,0,1,1,0,1])});
b.plot


n=101;
p = {arg noOfPoints;
	var step, points;
	noOfPoints.even.if({noOfPoints=noOfPoints+1});
	step = 1/(noOfPoints-1);
	points = Array.series(noOfPoints, 0, step);
}
d = {arg curve;
	c[b.index] = curve;
	b.curves = c;
}
e = {arg coordinates, curves;
	var env;
	#t, l = coordinates;
	env = Env( l, t.differentiate.drop(1), curves);
	env
}
g = {
	var env = e.value(b.value, c);
	var signal = env.asSignal(513);
	signal = (signal * 2)-1;
	signal;
}
~wavetable.sendCollection(g.value.asWavetableNoWrap);
~wavetable.plot


w = Window("envelope", Rect(150 , Window.screenBounds.height - 700, 500, 500)).front;
w.view.decorator = FlowLayout(w.view.bounds);
b = EnvelopeView(w, Rect(0, 0, 492, 492));
b.drawLines_(true)
b.selectionColor_(Color.red)
b.drawRects_(true)
b.resize_(5)
b.keepHorizontalOrder_(true)
b.step_(0.00005)
b.action_({arg b;
	//[b.index, b.value].postln;
	//e.value;
})
b.thumbSize_(5)
b.value_([p.value(n),p.value(n)]);
b.setEditable((p.value(n).size/2).floor.asInteger, false);
w.front;
c = Array.fill(n-1, {0});
b.curves = c;
d.value(-0.4)






e.value(b.value, c).asSignal(256).plot

Array.series(3, 0, 0.5).postln;


(p.value(5).size/2).floor.asInteger



e.value

















