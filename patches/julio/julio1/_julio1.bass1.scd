(
~julio1.bass1 = ();
~julio1.bass1.busses = ();
~julio1.bass1.actions = ();
~julio1.bass1.mixerChannel = MixerChannel.new('julio1.bass1',s,2,2);


/* BUS ****************************/
~julio1.bass1.busses.toMixer = {~julio1.bass1.mixerChannel.asBus};


/* LAUNCHER ***********************/
~julio1.bass1.launcher = RDSynthLauncher.new;
~julio1.bass1.launcher.setConfig(\low,
	RDSynthConfig(\julio1Bass1, [
		\out, ~julio1.bass1.busses.toMixer.index,
		\freq, 36.midicps, \amp, 0.8,
		\ampAttackTime, 0.01, \ampDecayTime, 0.3,
		\ampSustainLevel, 0.5, \ampReleaseTime, 2,
		\lpFreqFac, 0.5, \lpRq, 0.5,
		\lpAttackTime, 0.01, \lpDecayTime, 0.1,
		\lpSustainLevel, 0.1, \lpReleaseTime, 3,
		\lpEnvDepth, 5,
	], {~julio1.groups.sndSrc.group}
	);
);
~julio1.bass1.launcher.setConfig(\mid,
	RDSynthConfig(\julio1Bass1, [
		\out, ~julio1.bass1.busses.toMixer.index,
		\freq, 48.midicps, \amp, 0.07,
		\ampAttackTime, 2.3, \ampDecayTime, 1,
		\ampSustainLevel, 0.5, \ampReleaseTime, 3,
		\lpFreqFac, 3.5, \lpRq, 1,
		\lpAttackTime, 1, \lpDecayTime, 1,
		\lpSustainLevel, 0.4, \lpReleaseTime, 3,
		\lpEnvDepth, 2,
	], {~julio1.groups.sndSrc.group}
	);
);
~julio1.bass1.launcher.setConfig(\high,
	RDSynthConfig(\julio1Bass1, [
		\out, ~julio1.bass1.busses.toMixer.index,
		\freq, 96.midicps, \amp, 0.01,
		\ampAttackTime, 2.3, \ampDecayTime, 1,
		\ampSustainLevel, 0.5, \ampReleaseTime, 3,
		\lpFreqFac, 1.5, \lpRq, 0.3,
		\lpAttackTime, 1, \lpDecayTime, 1,
		\lpSustainLevel, 0.4, \lpReleaseTime, 3,
		\lpEnvDepth, 5,
	], {~julio1.groups.sndSrc.group}
	);
);
~julio1.bass1.launcher.setConfig(\deepDrone,
	RDSynthConfig(\julio1Bass1, [
		\out, ~julio1.bass1.busses.toMixer.index,
		\freq, 32.midicps, \amp, 0.5,
		\ampAttackTime, 3, \ampDecayTime, 2,
		\ampSustainLevel, 0.5, \ampReleaseTime, 5,
		\lpFreqFac, 0.1, \lpRq, 0.5,
		\lpAttackTime, 5, \lpDecayTime, 1,
		\lpSustainLevel, 0.5, \lpReleaseTime, 3,
		\lpEnvDepth, 3,
	], {~julio1.groups.sndSrc.group}
	);
);
~julio1.bass1.launcher.setConfig(\midDrone,
	RDSynthConfig(\julio1Bass1, [
		\out, ~julio1.bass1.busses.toMixer.index,
		\freq, 47.midicps, \amp, 0.1,
		\ampAttackTime, 5, \ampDecayTime, 1,
		\ampSustainLevel, 0.5, \ampReleaseTime, 3,
		\lpFreqFac, 3.5, \lpRq, 2,
		\lpAttackTime, 1, \lpDecayTime, 1,
		\lpSustainLevel, 0.4, \lpReleaseTime, 3,
		\lpEnvDepth, 4,
	], {~julio1.groups.sndSrc.group}
	);
);












/* ACTIONS ***********************/
~julio1.bass1.actions.p1 = ();
~julio1.bass1.actions.p1.pattern = Pspawner({|sp|
	sp.par(
		Pbindef(\julio1Bass1OneNote,
			\instrument, \julio1Bass1,
			\degree, Pseq([0],1), \ctranspose, [-24,-12],
			\sustain, [0.5,3], \dur, 0.3,
			\out, Pfunc({~julio1.bass1.busses.toMixer.index}),
			\group, Pfunc({~julio1.groups.sndSrc.group}),
			\amp, [0.8,0.07],
			\ampAttackTime, [0.01,2.3], \ampDecayTime, [0.3,1],
			\ampSustainLevel, 0.5, \ampReleaseTime, [2,3],
			\lpFreqFac, [0.5,3.5], \lpRq, [0.5,1],
			\lpAttackTime, [0.01,1], \lpDecayTime, [0.1,1],
			\lpSustainLevel, [0.1,0.4], \lpReleaseTime, 3,
			\lpEnvDepth, [5,2]
		);
	);
	1.wait;
	(0.5).coin.if({
		sp.par(
			Pbindef(\julio1Bass1DmallNotes,
				\instrument, \julio1Bass1,
				\degree, Prand([3,7,0],3), \ctranspose, 36,
				\sustain, 1, \dur, Pwhite(0.5,1.2,inf),
				\out, Pfunc({~julio1.bass1.busses.toMixer.index}),
				\group, Pfunc({~julio1.groups.sndSrc.group}),
				\amp, 0.01,
				\ampAttackTime, 2.3, \ampDecayTime, 1,
				\ampSustainLevel, 0.5, \ampReleaseTime, 3,
				\lpFreqFac, 1.5, \lpRq, 0.3,
				\lpAttackTime, 1, \lpDecayTime, 1,
				\lpSustainLevel, 0.4, \lpReleaseTime, 3,
				\lpEnvDepth, Pseq([[4,6]],3)
			);
		);
	});
});
~julio1.bass1.actions.p1.playIt = {
	~julio1.bass1.actions.p1.player = ~julio1.bass1.actions.p1.pattern.play;
};
~julio1.bass1.actions.p1.stopIt = {
	~julio1.bass1.actions.p1.player.stop;
};


~julio1.bass1.actions.oneNote2 = (
	pattern: Pbindef(\julio1Bass1OneNote2,
		\instrument, \julio1Bass1,
		\degree, Pseq([[-4, -1]],inf), \ctranspose, [-24,-12],
		\sustain, [7,9], \dur, Pn(12,1),
		\out, Pfunc({~julio1.bass1.busses.toMixer.index}),
		\group, Pfunc({~julio1.groups.sndSrc.group}),
		\amp, [0.5,0.1],
		\ampAttackTime, [3,5], \ampDecayTime, [2,1],
		\ampSustainLevel, 0.5, \ampReleaseTime, [5,3],
		\lpFreqFac, [0.1,3.5], \lpRq, [0.5,2],
		\lpAttackTime, [5,1], \lpDecayTime, [1,1],
		\lpSustainLevel, [0.5,0.4], \lpReleaseTime, 3,
		\lpEnvDepth, [3,4]
	),
	playIt: {
		~julio1.bass1.actions.oneNote2.player = ~julio1.bass1.actions.oneNote2.pattern.trace.play;
	},
	stopIt: { ~julio1.bass1.actions.oneNote2.player.stop },
);



~julio1.bass1.actions.oneNote1 = ();
~julio1.bass1.actions.oneNote1.synthNode = Dictionary.new;
~julio1.bass1.actions.oneNote1.playIt = {arg self, note=60, amp=0.5,
	ampAttackTime, ampDecayTime, ampSustainLevel, ampReleaseTime,
	lpFreqFac, lpRq,
	lpAttackTime, lpDecayTime, lpSustainLevel, lpReleaseTime, lpEnvDepth;

	if(RDUtils.nodeExists(~julio1.bass1.actions.oneNote1.synthNode[note]).not, {
		~julio1.bass1.actions.oneNote1.synthNode[note] = Synth(\julio1Bass1,[
			\out, ~julio1.bass1.busses.toMixer.index,
			\freq, note.midicps,	\amp, amp, \gate, 1,
			\ampAttackTime, ampAttackTime, \ampDecayTime, ampDecayTime,
			\ampSustainLevel, ampSustainLevel, \ampReleaseTime, ampReleaseTime,
			\lpFreqFac, lpFreqFac, \lpRq, lpRq,
			\lpAttackTime, lpAttackTime, \lpDecayTime, lpDecayTime,
			\lpSustainLevel, lpSustainLevel, \lpReleaseTime, lpReleaseTime,
			\lpEnvDepth, lpEnvDepth
		],~julio1.groups.sndSrc.group).register;
	});
};
~julio1.bass1.actions.oneNote1.stopIt = {
	~julio1.bass1.actions.oneNote1.setParam(\gate, 0);
};
~julio1.bass1.actions.oneNote1.setParam = {|self, paramName, paramValue, note|
	if(note.notNil, {
		var node = ~julio1.bass1.actions.oneNote1.synthNode[note];
			if(RDUtils.nodeExists(node), {
				node.set(paramName.asSymbol, paramValue);
			});
	}, {
		~julio1.bass1.actions.oneNote1.synthNode.collect({|node|
			if(RDUtils.nodeExists(node), {
				node.set(paramName.asSymbol, paramValue);
			});
		});
	});
};









~julio1.bass1.actions.oneNote3 = ();
~julio1.bass1.actions.oneNote3.synthNode = Dictionary.new;
~julio1.bass1.actions.oneNote3.playIt = {|self, note=60, amp=0.5|
	if(RDUtils.nodeExists(~julio1.bass1.actions.oneNote3.synthNode[note]).not, {
		~julio1.bass1.actions.oneNote3.synthNode[note] = Synth(\julio1Bass1,[
			\out, ~julio1.bass1.busses.toMixer.index,
			\freq, note.midicps,	\amp, amp, \gate, 1,
			\ampAttackTime, 3, \ampDecayTime, 2,
			\ampSustainLevel, 0.5, \ampReleaseTime, 1,
			\lpFreqFac, 0.1, \lpRq, 0.5,
			\lpAttackTime, 5, \lpDecayTime, 1,
			\lpSustainLevel, 0.5, \lpReleaseTime, 1,
			\lpEnvDepth, 3
		],~julio1.groups.sndSrc.group).register;
	});
};
~julio1.bass1.actions.oneNote3.stopIt = {
	~julio1.bass1.actions.oneNote3.setParam(\gate, 0);
};
~julio1.bass1.actions.oneNote3.setParam = {|self, paramName, paramValue, note|
	if(note.notNil, {
		var node = ~julio1.bass1.actions.oneNote3.synthNode[note];
			if(RDUtils.nodeExists(node), {
				node.set(paramName.asSymbol, paramValue);
			});
	}, {
		~julio1.bass1.actions.oneNote3.synthNode.collect({|node|
			if(RDUtils.nodeExists(node), {
				node.set(paramName.asSymbol, paramValue);
			});
		});
	});
};




)



/* DO STUFF ***********************/
~julio1.bass1.launcher.on(\low, \low, [\freq, 36.midicps], 0.5);
~julio1.bass1.launcher.on(\mid, \mid, [\freq, 48.midicps]);
~julio1.bass1.launcher.off(\mid);

(
var offset = [0,3,7].choose;
var lpEnvDepth = rrand(4.0,6.0);
~julio1.bass1.launcher.on(\high++offset,
	\high, [\freq, (96+offset).midicps, \lpEnvDepth, lpEnvDepth], 1
);
)

(
~julio1.bass1.launcher.on(\deepDrone,\deepDrone,[],sustain:7);
~julio1.bass1.launcher.on(\midDrone,\midDrone,[],sustain:9);
)









~julio1.bass1.actions.p1.playIt;
~julio1.bass1.actions.p1.stopIt;

~julio1.bass1.actions.oneNote2.playIt;
~julio1.bass1.actions.oneNote2.stopIt;

~julio1.bass1.actions.oneNote3.playIt(50, 0.2);
~julio1.bass1.actions.oneNote3.playIt(100, 0.2);
~julio1.bass1.actions.oneNote3.stopIt;
~julio1.bass1.actions.oneNote3.setParam(\amp.asSymbol, 0.2);
~julio1.bass1.actions.oneNote3.setParam(\amp.asSymbol, 0.2, 50);
~julio1.bass1.actions.oneNote3.setParam(\amp.asSymbol, 0.1, 100);

~julio1.bass1.actions.oneNote3.synthNode.set(\amp, 0);


~julio1.bass1.synthConfig =















