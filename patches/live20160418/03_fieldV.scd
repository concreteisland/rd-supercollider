(
SynthDef(\rdDiskIn3, { | bufnum, outbus, xFade=1 |
	var snd;
	snd = DiskIn.ar(2, bufnum);
	snd = SynthDef.wrap(Instr(\liveChannel).func, [\ar], [snd]);
	snd = SynthDef.wrap(Instr(\envelopeASR).func) * snd;
	XOut.ar(outbus, xFade.lag(3),snd);
}).add;
)


(
~loadSoundfile = {arg modelname, path, args=Dictionary.new, addAction=\addToTail;
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

~playSoundfile = {arg fileModel, start=0, args=[];
	{
	fileModel.buffer.cueSoundFile(fileModel.soundfile.path, fileModel.soundfile.numFrames * start);
	s.sync;
	fileModel.voicer.trigger1(fileModel.buffer.bufnum, args: args);
	}.forkIfNeeded;
};

~bcr.elements.kn[1][0].action_({|e|
	if(~live1.tfinal1.notNil, {
		if(~live1.tfinal1.voicer.notNil, {
			~live1.tfinal1.voicer.set([\xFade, e.value]);
		});
	});
});


~bcr.elements.kn[1][1].action_({|e|
	if(~live1.hafen1.notNil, {
		if(~live1.hafen1.voicer.notNil, {
			~live1.hafen1.voicer.set([\xFade, e.value]);
		});
	});
});
)


(
~loadSoundfile.value(\tfinal1, Platform.resourceDir +/+ "sounds/_live/done/t-flur01.wav", [\release, 5, \xFade, 0.5], \addToTail);
~loadSoundfile.value(\tfinal2, Platform.resourceDir +/+ "sounds/_live/done/t-flur02.wav", [\release, 5], \addToHead);
~loadSoundfile.value(\hafen1, Platform.resourceDir +/+ "sounds/_live/done/hafen01.wav", [\release, 5, \xFade, 0.5], \addToTail);
~loadSoundfile.value(\hafen2, Platform.resourceDir +/+ "sounds/_live/done/hafen02.wav", [\release, 5, \gain, 3], \addToHead);
~loadSoundfile.value(\ulva, Platform.resourceDir +/+ "sounds/_live/VOC_150802-0053_ulva_wind.wav", [\release, 5]);
~loadSoundfile.value(\trainrattle, Platform.resourceDir +/+ "sounds/_live/trainrattle_l.wav", [\release, 5, \gain, 2]);
)


/**************************/

/*PART 1*******/
(
~playSoundfile.value(~live1.tfinal1);
~playSoundfile.value(~live1.tfinal2, args: [\loFreq,100,\loRs,1,\loGain,-6]);
)
(
~live1.tfinal1.voicer.releaseAll;
~live1.tfinal2.voicer.releaseAll;
)

/*PART 2*******/
(
~playSoundfile.value(~live1.hafen1, 0.5);
~playSoundfile.value(~live1.hafen2, 0.5);
)
(
~live1.hafen1.voicer.releaseAll;
~live1.hafen2.voicer.releaseAll
)


/*PART 3*******/
(~playSoundfile.value(~live1.ulva, 0,[
	\xFade, 1, \gain, 1,
	\loFreq,100,\loRs,0.5,\loGain,2,
	\peakFreq,400,\peakRq,0.3,\peakGain,-6,
	\hiFreq,1200,\hiRs,1,\hiGain,0
]));
~live1.ulva.voicer.releaseAll;


/*PART 4*******/
(~playSoundfile.value(~live1.trainrattle, 0.25,[
	\xFade, 1, \gain, 1.5,
	\loFreq,100,\loRs,0.5,\loGain,3,
	\peakFreq,400,\peakRq,0.3,\peakGain,-6,
	\hiFreq,1000,\hiRs,3,\hiGain,12,
	]
));
~live1.trainrattle.voicer.releaseAll;













