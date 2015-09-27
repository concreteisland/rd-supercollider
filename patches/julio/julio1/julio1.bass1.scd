(
~julio1.bass1 = ();
~julio1.bass1.busses = ();
~julio1.bass1.actions = ();
~julio1.bass1.mixerChannel = MixerChannel.new('julio1.bass1',s,2,2);


/* BUS ****************************/
~julio1.bass1.busses.toMixer = {~julio1.bass1.mixerChannel.asBus};


/* LAUNCHER CONFIGS  **************/
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
		\knackTriggerFreq, 0,
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
		\knackTriggerFreq, 0,
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
		\knackTriggerFreq, 0,
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
		\knackTriggerFreq, 0,
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
		\knackTriggerFreq, 0,
	], {~julio1.groups.sndSrc.group}
	);
);

)



/* DO STUFF ***********************/
~julio1.bass1.launcher.on(\low, \low, [], 0.5);
~julio1.bass1.launcher.on(\mid, \mid, []);
~julio1.bass1.launcher.off(\mid);

(
var offset = [0,3,7].choose;
var lpEnvDepth = rrand(4.0,6.0);
~julio1.bass1.launcher.on(\high++offset,
	\high, [\freq, (96+offset).midicps, \lpEnvDepth, lpEnvDepth], 1
);
)
(
~julio1.bass1.launcher.on(\deepDrone,\deepDrone,[\knackTriggerFreq,5],sustain:7);
~julio1.bass1.launcher.on(\midDrone,\midDrone,[\knackTriggerFreq,15],sustain:9);
)



















