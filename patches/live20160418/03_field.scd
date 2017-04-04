(
SynthDef(\rdDiskIn2, { | bufnum, out, gate = 1, sustain, amp = 1, ar = 0, dr = 0.01, xFade=1 |
	var snd;
	snd = DiskIn.ar(2, bufnum);
	snd = SynthDef.wrap(Instr(\liveChannel).func, [\ar], [snd]);
	XOut.ar(
		out,
		xFade.lag(3),
		snd * Linen.kr(gate, ar, 1, dr, 2)
		    * EnvGen.kr(Env.linen(0, sustain - ar - dr max: 0 ,dr),1, doneAction: 2) * amp
	);
}).add;
)

(
~loadSoundfile = {arg modelname, path;
	SoundFile.use(path, {|file|
		~live1[modelname.asSymbol] = ();
		~live1[modelname.asSymbol].soundfile = file;
	});
};
~playSoundfile = {arg fileModel, bus, group, start=0, args =[];
	var ev, argsDict;
	fileModel.player.stop;
	ev = (
		out: bus,
		group: group,
		instrument: \rdDiskIn2,
		firstFrame: fileModel.soundfile.numFrames * start,
		release: 10
	);
	ev.putAll(args);
	fileModel.player = fileModel.soundfile.cue(ev, true);
};
~pauseSoundfile = {arg fileModel;
	fileModel.player.pause;
};
~resumeSoundfile = {arg fileModel;
	fileModel.player.resume;
};
~stopSoundfile = {arg fileModel;
	fileModel.player.stop;
};

~bcr.elements.kn[1][0].action_({|e|
	if(~live1.tfinal1.notNil, {
		if(~live1.tfinal1.player.notNil, {
			~live1.tfinal1.player.set(\xFade, e.value);
		});
	});
});
~bcr.elements.kn[1][1].action_({|e|
	if(~live1.hafen1.notNil, {
		if(~live1.hafen1.player.notNil, {
			~live1.hafen1.player.set(\xFade, e.value);
		});
	});
});
)

(
~loadSoundfile.value(\tfinal1, Platform.resourceDir +/+ "sounds/_live/done/t-flur01.wav");
~loadSoundfile.value(\tfinal2, Platform.resourceDir +/+ "sounds/_live/done/t-flur02.wav");
~loadSoundfile.value(\hafen1, Platform.resourceDir +/+ "sounds/_live/done/hafen01.wav");
~loadSoundfile.value(\hafen2, Platform.resourceDir +/+ "sounds/_live/done/hafen02.wav");
~loadSoundfile.value(\hafen2, Platform.resourceDir +/+ "sounds/_live/done/hafen02.wav");
~loadSoundfile.value(\ulva, Platform.resourceDir +/+ "sounds/_live/VOC_150802-0053_ulva_wind.wav");
~loadSoundfile.value(\trainrattle, Platform.resourceDir +/+ "sounds/_live/trainrattle_l.wav");
)



/**************/


(
SynthDef(\rdDiskIn3, { | bufnum, outbus, xFade=1 |
	var snd;
	snd = DiskIn.ar(2, bufnum);
	snd = SynthDef.wrap(Instr(\liveChannel).func, [\ar], [snd]);
	snd = SynthDef.wrap(Instr(\envelopeASR).func) * snd;
	XOut.ar(outbus, xFade.lag(3),snd);
}).add;
)

~x = Voicer.new(2, \rdDiskIn3, args: [\release, 10]);
~x.releaseAll;
(
~xloadSoundfile = {arg modelname, path, args=Dictionary.new, addAction=\addToTail;
	SoundFile.use(path, {|file|
		var voicerArgs = ();
		~live1[modelname.asSymbol] = ();
		~live1[modelname.asSymbol].soundfile = file;
		~live1[modelname.asSymbol].buffer = Buffer.alloc(s,32768,file.numChannels);
		voicerArgs = (\bufnum:~live1[modelname.asSymbol].buffer.bufnum);
		voicerArgs.putAll(args);
		~live1[modelname.asSymbol].voicer = Voicer.new(
			1,
			\rdDiskIn3,
			args:  voicerArgs.asKeyValuePairs,
			target: ~live1.mixer.mixers[0].asMixer,
			addAction: addAction
		);
	});
};

~xplaySoundfile = {arg fileModel, start=0;
	{
	fileModel.buffer.cueSoundFile(fileModel.soundfile.path, fileModel.soundfile.numFrames * start);
	s.sync;
	fileModel.voicer.trigger1(fileModel.buffer.bufnum);
	}.forkIfNeeded;
};
)

~xloadSoundfile.value(\tfinal1, Platform.resourceDir +/+ "sounds/_live/done/t-flur01.wav", [\release, 5, \xFade, 0.5], \addToTail);
~xloadSoundfile.value(\tfinal2, Platform.resourceDir +/+ "sounds/_live/done/t-flur02.wav", [\release, 5], \addToHead);

~xplaySoundfile.value(~live1.tfinal1);
~xplaySoundfile.value(~live1.tfinal2);


~bcr.elements.kn[1][0].action_({|e|
	if(~live1.tfinal1.notNil, {
		if(~live1.tfinal1.voicer.notNil, {
			~live1.tfinal1.voicer.set([\xFade, e.value]);
		});
	});
});

~live1.tfinal1.voicer.releaseAll;
~live1.tfinal2.voicer.releaseAll;





(1: 2).asKeyValuePairs























/*PART 1*******/
(~playSoundfile.value(~live1.tfinal1,
	~live1.mixer.mixers[0].asMixer.asBus,
	~live1.mixer.mixers[0].asMixer.synthgroup
));
~pauseSoundfile.value(~live1.tfinal1);
~resumeSoundfile.value(~live1.tfinal1);
~stopSoundfile.value(~live1.tfinal1);
/**************/
(~playSoundfile.value(~live1.tfinal2,
	~live1.mixer.mixers[0].asMixer.asBus,
	~live1.mixer.mixers[0].asMixer.synthgroup
));
~pauseSoundfile.value(~live1.tfinal2);
~resumeSoundfile.value(~live1.tfinal2);
~stopSoundfile.value(~live1.tfinal2);
/*PART 2*******/
(~playSoundfile.value(~live1.hafen1,
	~live1.mixer.mixers[0].asMixer.asBus,
	~live1.mixer.mixers[0].asMixer.synthgroup,
	0.5, [\xFade, 0.5]
));
~pauseSoundfile.value(~live1.hafen1);
~resumeSoundfile.value(~live1.hafen1);
~stopSoundfile.value(~live1.hafen1);
/**************/
(~playSoundfile.value(~live1.hafen2,
	~live1.mixer.mixers[0].asMixer.asBus,
	~live1.mixer.mixers[0].asMixer.synthgroup,
	0.5,
	[\xFade, 1, \gain, 2]
));
~pauseSoundfile.value(~live1.hafen2);
~resumeSoundfile.value(~live1.hafen2);
~stopSoundfile.value(~live1.hafen2);



/*PART 3*******/
(~playSoundfile.value(~live1.ulva,
	~live1.mixer.mixers[0].asMixer.asBus,
	~live1.mixer.mixers[0].asMixer.synthgroup,
	0,
	[
		\xFade, 1, \gain, 1,
		\loFreq,100,\loRs,0.5,\loGain,6,
		\peakFreq,400,\peakRq,0.3,\peakGain,-6,
		\hiFreq,1200,\hiRs,1,\hiGain,0
	]
));
~pauseSoundfile.value(~live1.ulva);
~resumeSoundfile.value(~live1.ulva);
~stopSoundfile.value(~live1.ulva);


(
~live1.ulva.player.group.set(
	\loFreq,100,\loRs,0.5,\loGain,6,
	\peakFreq,400,\peakRq,0.3,\peakGain,-6,
	\hiFreq,1200,\hiRs,1,\hiGain,0,
	\gain, 1
);
)

/*PART 4*******/
(~playSoundfile.value(~live1.trainrattle,
	~live1.mixer.mixers[0].asMixer.asBus,
	~live1.mixer.mixers[0].asMixer.synthgroup,
	0.25,
	[
		\xFade, 1, \gain, 1.5,
	\loFreq,100,\loRs,0.5,\loGain,3,
	\peakFreq,400,\peakRq,0.3,\peakGain,-6,
	\hiFreq,1000,\hiRs,3,\hiGain,12,
	]
));
~pauseSoundfile.value(~live1.trainrattle);
~resumeSoundfile.value(~live1.trainrattle);
~stopSoundfile.value(~live1.trainrattle);





~live1.ulva.soundfile.duration






