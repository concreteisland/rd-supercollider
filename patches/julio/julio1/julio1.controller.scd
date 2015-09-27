MIDIMKtl.find;

~bcr = MIDIMKtl('bcr20000', 1, 3);
RDUtils.mapMixer2BCR(~julio1.mixer, ~bcr);


~quneo=MIDIMKtl('qn0');

(
// PAD-1
~quneo.elements.pad[1].noteOn.action_({|e|
	~julio1.bass1.launcher.on(\low, \low, [], 0.5);
	~julio1.bass1.launcher.on(\mid, \mid, []);
});
~quneo.elements.pad[1].noteOff.action_({|e|
	~julio1.bass1.launcher.off(\mid);
});

// PAD-2
~quneo.elements.pad[2].noteOn.action_({|e|
	var offset = [0,3,7].choose;
	var lpEnvDepth = rrand(4.0,6.0);
	~julio1.bass1.launcher.on(\high++offset,
		\high, [\freq, (96+offset).midicps, \lpEnvDepth, lpEnvDepth], 1
	);
});

// PAD-3
~quneo.elements.pad[3].noteOn.action_({|e|
	~julio1.schweb2.launcher.on(\chord0, \chord, [\rate, 0.5], sustain: 3);
	~julio1.schweb2.launcher.on(\chord1, \chord, [\rate, 1.02], sustain: 3);
	~julio1.schweb2.launcher.on(\chord2, \chord, [\rate, 0.25], sustain: 3);
	~julio1.schweb2.launcher.on(\grain0, \grain, [\grainPitch, 0.5, \pos2, 0.6, \releaseTime, 10]);
	~julio1.schweb2.launcher.on(\grain1, \grain, [\grainPitch, 1.02, \pos2, 0.6, \posRate, 0.075, \releaseTime, 10]);
});
~quneo.elements.pad[3].noteOff.action_({|e|
	~julio1.schweb2.launcher.off(\grain0);
	~julio1.schweb2.launcher.off(\grain1);
});

~quneo.elements.pad[7].noteOn.action_({|e|
	~julio1.schweb2.launcher.on(\grain2, \grain, [\grainPitch, 0.6, \pos2, 0.6, \attackTime, 2]);
	~julio1.schweb2.launcher.on(\grain3, \grain, [\grainPitch, 1.12, \pos2, 0.6, \posRate, 0.075, \attackTime, 2]);
});
~quneo.elements.pad[7].noteOff.action_({|e|
	~julio1.schweb2.launcher.off(\grain2);
	~julio1.schweb2.launcher.off(\grain3);
});






// PAD-4
~quneo.elements.pad[4].noteOn.action_({|e|
	var amp = \amp.asSpec.unmap(e.value);
	~julio1.bass1.launcher.on(\deepDrone, \deepDrone, [\amp, amp]);
	~julio1.bass1.launcher.on(\midDrone, \midDrone, [\amp, amp]);
});
~quneo.elements.pad[4].noteOff.action_({|e|
	~julio1.bass1.launcher.off(\deepDrone);
	~julio1.bass1.launcher.off(\midDrone);
});
~quneo.elements.pad[4].pressure.action_({|e|
	var	amp1 = e.value * (1-e.source.elements.pad[4].locationY.value);
	var amp2 = e.value * e.source.elements.pad[4].locationY.value;
	amp1 = \amp.asSpec.map(amp1.linlin(0,1,0.1,1));
	amp2 = \amp.asSpec.map(amp2.value.linlin(0,1,0.1,0.5));
	~julio1.bass1.launcher.setArg(\deepDrone, \amp, amp1);
	~julio1.bass1.launcher.setArg(\midDrone, \amp, amp2);
});
~quneo.elements.pad[4].locationX.action_({|e|
	var lpFreqFac1 = ControlSpec(0.1,2,\lin,0,0.5).asSpec.map(e.value);
	var lpFreqFac2 = ControlSpec(2,4,\lin,0,2).asSpec.map(e.value);
	var knackTriggerFreq = ControlSpec(0,15,\lin,0,0).asSpec.map(e.value);
	~julio1.bass1.launcher.setArg(\deepDrone, \lpFreqFac, lpFreqFac1);
	~julio1.bass1.launcher.setArg(\midDrone, \lpFreqFac, lpFreqFac2);
	~julio1.bass1.launcher.setArg(\deepDrone, \knackTriggerFreq, knackTriggerFreq);
	~julio1.bass1.launcher.setArg(\midDrone, \knackTriggerFreq, knackTriggerFreq);
});
~quneo.elements.pad[4].locationY.action_({|e|
});


// PAD-5
~quneo.elements.pad[5].noteOn.action_({|e|
	var amp = \amp.asSpec.unmap(e.value);
	~julio1.bass1.launcher.on(\deepDrone2, \deepDrone, [\freq, (32+5).midicps, \amp, amp]);
	~julio1.bass1.launcher.on(\midDrone2, \midDrone, [\freq, (47+5).midicps, \amp, amp]);
});
~quneo.elements.pad[5].noteOff.action_({|e|
	~julio1.bass1.launcher.off(\deepDrone2);
	~julio1.bass1.launcher.off(\midDrone2);
});
~quneo.elements.pad[5].pressure.action_({|e|
	var	amp1 = e.value * (1-e.source.elements.pad[4].locationY.value);
	var amp2 = e.value * e.source.elements.pad[4].locationY.value;
	amp1 = \amp.asSpec.map(amp1.linlin(0,1,0.1,1));
	amp2 = \amp.asSpec.map(amp2.value.linlin(0,1,0.1,0.5));
	~julio1.bass1.launcher.setArg(\deepDrone2, \amp, amp1);
	~julio1.bass1.launcher.setArg(\midDrone2, \amp, amp2);
});
~quneo.elements.pad[5].locationX.action_({|e|
	var lpFreqFac1 = ControlSpec(0.1,2,\lin,0,0.5).asSpec.map(e.value);
	var lpFreqFac2 = ControlSpec(2,4,\lin,0,2).asSpec.map(e.value);
	~julio1.bass1.launcher.setArg(\deepDrone2, \lpFreqFac, lpFreqFac1);
	~julio1.bass1.launcher.setArg(\midDrone2, \lpFreqFac, lpFreqFac2);
});

(
(8..15).do({|i|
	var offset = 8;
	var scale = Scale.murassah;
	var degreeIndex = i-offset;
	var octave = div(degreeIndex, scale.size);
	var degree = scale.at(degreeIndex) + (scale.pitchesPerOctave * octave);
	var freqLow = (36 + degree).midicps;
	var freqMid = (48 + degree).midicps;



	~quneo.elements.pad[i].noteOn.action_({|e|
		~julio1.bass1.launcher.on(\low++i, \low, [\freq, freqLow, \amp, 0.4], 0.5);
		~julio1.bass1.launcher.on(\mid++i, \mid, [\freq, freqMid, \amp, 0.035]);
	});
	~quneo.elements.pad[i].noteOff.action_({|e|
		~julio1.bass1.launcher.off(\mid++i);
	});
})
)

Scale.directory

s.makeGui


)




// VSLIDER-0
~quneo.elements.pad[0].noteOn.action_({|e|
	var amp = e.value.lincurve(0,1,0,1,-3);
	format("%:%", e.value, amp).postln;
	~julio1.ping.actions.sample.playIt(0.5, amp);
	~julio1.ping.actions.sample.playIt(2, amp);
});


~quneo.elements.vSlider[0].noteOn.action_({|e|
	~julio1.pfeif1.actions.p1.playIt;
});
~quneo.elements.vSlider[0].noteOff.action_({|e|
	~julio1.pfeif1.actions.p1.stopIt;
	~julio1.pfeif1.actions.amp.setAmp(0, 3);
	~julio1.schweb2.actions.p1attack.playIt;
});
~quneo.elements.vSlider[0].location.action_({|e|
	~julio1.pfeif1.actions.amp.setAmp(e.value, 1);
});










~quneo.elements.pad[2].noteOn.action_({|e|
	~julio1.bass1.actions.oneNote2.playIt;
});
~quneo.elements.pad[3].noteOn.action_({|e|
	~julio1.conv1.actions.sample.playIt(0.4,1);
	~julio1.conv1.actions.sample.playIt(0.9,1);
});


s.makeGui





