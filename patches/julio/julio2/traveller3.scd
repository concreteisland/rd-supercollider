(
Ndef(\xmod, {
	var startFreq = \startFreq.ar(704.24);
	var size = 7;
	var modFreqs = Array.geom(size,startFreq,2.3);
	var mods = Array(size);
	var prevMod = 0;
	modFreqs.do({|modFreq, i|
		var mod = (SinOsc.ar(modFreq + prevMod,0).tanh)*(modFreq/5);
		mods.add(mod);
		prevMod = mod;
	});
	mods[size-1];
});
)

(
Ndef(\x, {
	var freq = \freq.kr(60);
	var snd;
	var x = Ndef.ar(\xmod);

	snd = VarSaw.ar(freq+(x*0.8),0,0.2);
	snd = LeakDC.ar(snd);
	Pan2.ar(snd.tanh,0,1);
});
)

Ndef(\x).play
Ndef(\x).set(\freq,12);





