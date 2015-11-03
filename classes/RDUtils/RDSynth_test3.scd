(
SynthDef(\test, {arg freq=100, amp=0.5, pan=0;
	Out.ar(0, Pan2.ar(SinOsc.ar(freq,0,amp),pan));
}).add;
)

~def = RDSynthDef.new(\test);
~def.synthDefArguments.put(\FREQ, RDSynthDefArgument.new(100,\freq));
~def.synthDefArguments.put(\AMP, RDSynthDefArgument.new(0.5,\freq));
~def.synthDefArguments.put(\PAN, RDSynthDefArgument.new(0,\pan));
~def.synthDefArguments.put(\FOO, RDSynthDefArgument.new(0));
~def.synthDefArguments.put(\SAMPLE, RDSynthDefArgument.new(nil,\bufnum,RDSynthArgumentSampleStrategy.new));


~conf = RDSynthConfig(~def, [\AMP, 0.1]);
~conf.set(\FREQ, 111, \AMP, 0.333, \PAN, 0.1, \FOO, 666, \SAMPLE, ["D:/MusikMachen/Samples/10000.wav", s]);

~conf.synthArguments(\AMP, \FOO, \SAMPLE)
~conf.synthArgumentsValues(\AMP, \FOO, \SAMPLE)
~conf.synthArgumentsValuesForSynth(\AMP, \FOO, \SAMPLE)

~s1 = RDSynth(~conf, [\FREQ, 200]);
~s1.set(\FREQ,100)
~s1.inspect

s.scope


//---------------------------



(
SynthDef(\wasserknurschpelSynth, {arg out=0, bufnum, balancePos=0;
	var snd, balance;
	snd = DiskIn.ar(2,bufnum,0);
	balance = Balance2.ar(snd[0], snd[1], balancePos);
	snd = balance;
	Out.ar(out,snd);
}).add;

~wasserknurschpelSynthDef = RDSynthDef.new;
~wasserknurschpelSynthDef.synthDefName_(\wasserknurschpelSynth);

SynthDef(\wasserknurschpelFx, {arg in=0, out=0, freq=1200;
	var snd, bp;
	snd = In.ar(in,2);

	bp = BBandPass.ar(snd,freq,1);
	snd = bp;

	Out.ar(out,snd);
}).add;

~wasserknurschpelFxDef = RDSynthDef.new;
~wasserknurschpelFxDef.synthDefName_(\wasserknurschpelFx);
)

~wasserknurschpel = ();
~wasserknurschpel.buffer = Buffer.cueSoundFile(s, "D:/MusikMachen/Tracks/julio/samples/wasserknurschpel01.wav");
~wasserknurschpel.fxBus = Bus.audio(s,2);
~wasserknurschpel.x = Group.new;


~wasserknurschpel.sourceSynthConf = RDSynthConfig.new(~wasserknurschpelSynthDef,[
	\out, ~wasserknurschpel.fxBus.index,
	\bufnum, ~wasserknurschpel.buffer.bufnum
],~wasserknurschpel.x, \addToHead);

~wasserknurschpel.fxSynthConf = RDSynthConfig.new(~wasserknurschpelFxDef,[
	\in, ~wasserknurschpel.fxBus.index,
	\out, 0,
	\freq,1200
],~wasserknurschpel.x, \addToTail);

~wasserknurschpel.sourceSynth = RDSynth.new(~wasserknurschpelSynthDef,~wasserknurschpel.sourceSynthConf);
~wasserknurschpel.fxSynth = RDSynth.new(~wasserknurschpelFxDef,~wasserknurschpel.fxSynthConf, [\freq, 100]);

~wasserknurschpel.fxSynth.set(\freq, 1100)


~wasserknurschpel.fxSynth.stop
~wasserknurschpel.fxSynth.play

s.plotTree;

f = {arg ... args;
	args.postln;
}

f.value(*[])

x = Dictionary.newFrom([1,2,3,4]);
y = Dictionary.new;

x.keysValuesDo({arg key, value;
	y.put([key*2, key**2], [value*2, value**2]);
});



f.value(*1);



w = z.collect({arg value, key;
	value * value
});

w
x.do({})

[1,2,[3,4],[5,6]].lace



Dictionary.newFrom([1,2,3,4]).keys.asArray

d = (a: "hello", b: "robot", c: [1, 2, 3]);
d.associationsDo { |assoc| postln("the association: " ++ assoc) };







