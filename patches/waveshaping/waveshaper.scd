
~wavetable = Buffer.alloc(s, 1024, 1);

~upper = Env.perc.asSignal(256);
~lower = ~upper.copy;
~lower.invert.reverse;
~signal=~lower;
~signal = ~signal.add(0);
~signal = ~signal.addAll(~upper);
~wavetable.sendCollection(~signal.asWavetableNoWrap);
~signal.plot;

~wavetable.plot

{Shaper.ar(~wavetable,SinOsc.ar(440))}.scope;



