(
SynthDef(\hundebass, {arg outbus=0;
	var snd;
	snd = SynthDef.wrap(Instr(\hundebass).func);
	snd = SynthDef.wrap(Instr(\liveChannel).func, [\ar], [snd]);
	snd = snd * SynthDef.wrap(Instr(\envelopeASR).func);
	Out.ar(outbus,snd);
}).add;
)


(
~hundebass = ();
~hundebass.buffer = List.newClear(4);
~hundebass.attackBuffer = List.newClear(2);
)
(
Array.fill(~hundebass.buffer.size, {|i| Platform.resourceDir +/+ "sounds/_live/hundebass"++(i+1)++".wav"}).do({|path, index|
	RDBufferUtils.loadBuffer(path, s, ~hundebass.buffer.at(index), {|b|
		~hundebass.buffer.put(index, b);
	});
});


Array.fill(~hundebass.attackBuffer.size, {|i| Platform.resourceDir +/+ "sounds/_live/attack"++(i+1)++".wav"}).do({|path, index|
	RDBufferUtils.loadBuffer(path, s, ~hundebass.attackBuffer.at(index), {|b|
		~hundebass.attackBuffer.put(index, b);
	});
});
)
(
if(~hundebass.voicer.notNil, {
	~hundebass.voicer.releaseAll(0);
});
~hundebass.voicer = Voicer(1, \hundebass, args: [
	\gain, 2,
	\release, 5
], target: ~live1.mixer.mixers[4].asMixer);
)
(
~qneo.elements.pad[15].noteOn.action_({|e|
	var pad = e.source.elements.pad[15];
	var x = pad.locationX.value.round;
	var y = pad.locationY.value.round;
	var bufferIndex = [y,x].convertDigits(2);
	~hundebass.voicer.trigger1(0, args: [
		\bufnumAttack,~hundebass.attackBuffer[2.rand].bufnum,
		\bufnum, ~hundebass.buffer[bufferIndex].bufnum
	])
});
~qneo.elements.pad[15].pressure.action_({|e|
	~hundebass.voicer.set([\amp, e.value.lincurve(0,1,0.5,1,3)]);
});
~qneo.elements.pad[15].locationX.action_({|e|
	~hundebass.voicer.set([\lpMod, e.value.lincurve(0,1,0,100,3)]);
});
~qneo.elements.pad[15].noteOff.action_({|e|
	~hundebass.voicer.release1(0);
});
)


/***************************************************/



~hundebass.voicer.releaseAll;
