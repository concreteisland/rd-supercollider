(
SynthDef(\ulvaConv, {arg outbus;
	var snd;
	snd = In.ar(outbus, 2);
	snd = SynthDef.wrap(Instr(\partconv).func, [\ar], [snd]);
	snd = snd * SynthDef.wrap(Instr(\envelopeASR).func);
	snd = SynthDef.wrap(Instr(\liveChannel).func, [\ar], [snd]);
	//DetectSilence.ar(snd,0.0001,0.1,doneAction:2);
	ReplaceOut.ar(outbus,snd);
}).add;

SynthDef(\ulvaPlayer, {arg outbus;
	var snd;
	snd = SynthDef.wrap(Instr(\ulvaPlayer).func);
	snd = snd * SynthDef.wrap(Instr(\envelopeASR).func);
	snd = SynthDef.wrap(Instr(\liveChannel).func, [\ar], [snd]);
	Out.ar(outbus,snd);
}).add;

)
(
~ulvaC = ();
~ulvaC.buffer = List.newClear(4);
~ulvaC.buffer2 = List.newClear(2);
)
(
Array.fill(~ulvaC.buffer.size, {|i| Platform.resourceDir +/+ "sounds/_live/island/"++i.asDigits(10,3).join++".wav"}).do({|path, index|
	RDBufferUtils.loadBuffer(path, s, ~ulvaC.buffer.at(index), {|b|
		~ulvaC.buffer.put(index, b.normalize);
	});
});
Array.fill(~ulvaC.buffer2.size, {|i| Platform.resourceDir +/+ "sounds/_live/blas"++(i+1)++".wav"}).do({|path, index|
	RDBufferUtils.loadBuffer(path, s, ~ulvaC.buffer2.at(index), {|b|
		~ulvaC.buffer2.put(index, b.normalize);
	});
});
RDPartConvUtils.createKernelBufferListFromPath(Platform.resourceDir+/+"sounds/_live/ulva_kernel2.wav",s,2.pow(14),{|bufferList|
	~ulvaC.kernelBuffers = bufferList;
});
)

(
~ulvaC !? { ~ulvaC.voicer !? { ~ulvaC.voicer.releaseAll } };
~ulvaC !? { ~ulvaC.voicerPlay !? { ~ulvaC.voicerPlay.releaseAll } };

~ulvaC.voicer = Voicer.new(1,\ulvaConv, [
	\irbufnum, ~ulvaC.kernelBuffers.collect({|b| b.bufnum}),
	\fftsize, 2.pow(14),
	\attack, 0.1,	\release,5, \amp,1,
	\gain, 1,
	\loFreq, 120, \loRs, 1.5, \loGain, -14,
	\peakFreq, 400, \peakRq, 0.5, \peakGain, -5,
	\hiFreq, 1000, \hiRs, 1.5, \hiGain, 8,
], target: ~live1.mixer.mixers[3].asMixer);

~ulvaC.voicerPlay = Voicer.new(4, \ulvaPlayer, [
	\bufnum, ~ulvaC.buffer[0].bufnum,
	\attack, 0.1,	\release,1, \amp,1,
], target: ~live1.mixer.mixers[3].asMixer, addAction: \addToHead);
)

(
var pad = ~qneo.elements.pad[12];
var pad2 = ~qneo.elements.pad[13];
var slider = ~qneo.elements.hSlider[0];
var slider2 = ~qneo.elements.hSlider[1];

pad.noteOn.action_({|e|
	var rate = slider.location.value.linlin(0,1,0,3-0.0000001).floor;
	var bufferIndex = slider2.location.value.linlin(0,1,0,~ulvaC.buffer.size-0.000001).floor;
	rate = [0.5,1,2].at(rate);


	if(not(~ulvaC.voicer.firstNodeFreq(0).isPlaying), {
		~ulvaC.voicer.trigger1(0);
	});

	~ulvaC.voicerPlay.trigger1(0, args: [\rate,rate,\bufnum, ~ulvaC.buffer[bufferIndex].bufnum]);
});

slider.location.action_({|e|
	var rate = e.value.linlin(0,1,0,3-0.0000001).floor;
	rate = [0.5,1,2].at(rate);
	"rate = %\n".postf(rate);
});

slider2.location.action_({|e|
	var bufferIndex = e.value;
	bufferIndex = bufferIndex.linlin(0,1,0,~ulvaC.buffer.size-0.000001).floor;
	"bufferIndex = %\n".postf(bufferIndex);
});

pad.pressure.action_({|e|
	~ulvaC.voicerPlay.set([\amp, e.value.lincurve(0,1,0.2,1,-1)]);
});
pad.noteOff.action_({|e|
	~ulvaC.voicerPlay.releaseAll;
});


pad2.noteOn.action_({|e|
	var rate = slider.location.value.linlin(0,1,0,3-0.0000001).floor;
	var bufferIndex = slider2.location.value.linlin(0,1,0,~ulvaC.buffer2.size-0.000001).floor;
	rate = [0.5,1,2].at(rate);

	if(not(~ulvaC.voicer.firstNodeFreq(0).isPlaying), {
		~ulvaC.voicer.trigger1(0);
	});

	~ulvaC.voicerPlay.trigger1(1, args: [\rate,rate,\bufnum, ~ulvaC.buffer2[bufferIndex].bufnum, \attack, 1]);
});


pad2.pressure.action_({|e|
	~ulvaC.voicerPlay.set([\amp, e.value.lincurve(0,1,0.2,1,-1)]);
});
pad2.noteOff.action_({|e|
	~ulvaC.voicerPlay.releaseAll;
});

)






