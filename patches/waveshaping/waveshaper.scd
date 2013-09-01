
~wavetable = Buffer.alloc(s, 1024, 1);

~upper = Env.new([0,1], [1]).asSignal(256);
~lower = ~upper.copy;
~lower.invert.reverse;
~signal=~lower;
~signal = ~signal.add(0);
~signal = ~signal.addAll(~upper);
~wavetable.sendCollection(~signal.asWavetableNoWrap);
~signal.plot;

~wavetable.plot

(
{
	var signal = SinOsc.ar(100);
	var shaped = Shaper.ar(~wavetable,signal);
	[signal, shaped];
}.plot(0.3)
)




(
// use shift-click to keep a node selected
w = Window("envelope", Rect(150 , Window.screenBounds.height - 250, 250, 100)).front;
w.view.decorator = FlowLayout(w.view.bounds);

b = EnvelopeView(w, Rect(0, 0, 230, 80))
    .drawLines_(true)
    .selectionColor_(Color.red)
    .drawRects_(true)
    .resize_(5)
    .step_(0.00005)
    .action_({arg b; [b.index, b.value].postln})
    .thumbSize_(5)
    .value_([[0.0, 0.1, 0.5, 1.0],[0.1,1.0,0.8,0.0]]);
w.front;
)

~curves = [-1,1,-6];
b.curves = ~curves
b.curves


//MAKE ENV FROM Envelope View

#t, l = b.value;
Env( l, t.differentiate.drop(1), ~curves).plot

t









