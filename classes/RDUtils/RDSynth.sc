RDSynth {
	var synthNode;
	var rdSynthConfig;
	var originalSynthConfig;
	var attributes;
	var statusPlaying = \playing;
	var statusPaused = \paused;
	var statusStopped = \stopped;
	var configController;

	*new {arg rdSynthConfig, arguments;
		var instance = super.new;
		instance.initRDSynth(rdSynthConfig, arguments);
		^instance;
	}

	initRDSynth {arg argRDSynthConfig, arguments;
		originalSynthConfig = argRDSynthConfig;
		//TODO controller for originalSynthCOnfig
		rdSynthConfig = RDSynthConfig.new(
			originalSynthConfig.rdSynthDef,
			originalSynthConfig.synthArgumentsValues.getPairs,
			originalSynthConfig.target,
			originalSynthConfig.addAction
		);
		configController = this.initConfigController(rdSynthConfig);
		this.performList(\set,arguments);
		attributes = ();
		this.play;
	}

	initConfigController {arg config;
		var controller = SimpleController.new(config);

		controller.put(\set, {arg theChanged, what, value;
			if(this.isPlaying || this.isPaused, {
				var keys = Dictionary.newFrom(value).keys.asArray;
				var arguments = rdSynthConfig.synthArgumentsValuesForSynth(*keys);
				synthNode.performList(\set,arguments.getPairs);
			});
		});

		^controller;
	}

	play {
		//TODO: possibility to schedule length of play
		if(this.isPaused, {
			{
				synthNode.run(true);
				synthNode.server.sync;
			}.forkIfNeeded;
		}, {
			if(this.isStopped, {
					this.createSynth;
			});
		});
	}

	stop {
		//TODO:
		if(not(this.isStopped), {
			synthNode.free;
		});
	}

	forceStop {
		if(not(this.isStopped), {
			synthNode.free;
		});
	}

	pause {
		if(this.isPlaying, {
			{
				synthNode.run(false);
				synthNode.server.sync;
			}.forkIfNeeded;
		});
	}

	status {
		if(synthNode.notNil, {
			if(synthNode.isPlaying, {
				if(synthNode.isRunning, {
					^statusPlaying;
				}, {
					^statusPaused;
				});
			}, {
				^statusStopped;
			})
		}, {
			^statusStopped;
		});
	}

	isPlaying {
		^(this.status == statusPlaying);
	}
	isPaused {
		^(this.status == statusPaused);
	}
	isStopped {
		^(this.status == statusStopped);
	}

	createSynth {
		if(rdSynthConfig.rdSynthDef.preCreationFunction.notNil, {
			rdSynthConfig.rdSynthDef.preCreationFunction.value(this);
		});

		synthNode = Synth(
			rdSynthConfig.rdSynthDef.synthDefName,
			rdSynthConfig.synthArgumentsValuesForSynth.getPairs,
			rdSynthConfig.target,
			rdSynthConfig.addAction
		);

		synthNode.register;

		if(rdSynthConfig.rdSynthDef.postCreationFunction.notNil, {
			rdSynthConfig.rdSynthDef.postCreationFunction.value(this);
		});

		synthNode.onFree({
			if(rdSynthConfig.rdSynthDef.postFreeFunction.notNil, {
				rdSynthConfig.rdSynthDef.postFreeFunction.value(this);
			});
		});
	}

	set {arg ... args;
		rdSynthConfig.performList(\set, args);
		rdSynthConfig.changed(\set, args);
	}
}


RDSynthArgument {
	var <>attributes;
	var rdSynthDefArgument;

	*new {arg rdSynthDefArgument;
		var instance = super.new;
		instance.initRDSynthArgument(rdSynthDefArgument);
		^instance;
	}

	initRDSynthArgument {arg argRDSynthDefArgument;
		rdSynthDefArgument = argRDSynthDefArgument;
		attributes = Dictionary.new;
		this.value_(*rdSynthDefArgument.defaultValue;)
	}

	name {
		^rdSynthDefArgument.name;
	}

	isNodeArg {
		^rdSynthDefArgument.isNodeArg;
	}

	value {
		^rdSynthDefArgument.argumentStrategy.getValue(this);
	}

	valueForSynth {
		^rdSynthDefArgument.argumentStrategy.getValueForSynth(this);
	}

	value_{arg ... args;
		rdSynthDefArgument.argumentStrategy.setValue(this, *args);
	}
}

















RDSynthTrack {
	var <>synthConfig;
	var <>synthNode;

	*new {arg argSynthConfig;
		var instance;
		instance = super.new;
		instance.initRDSynthTrack(argSynthConfig);
		^instance;
	}

	initRDSynthTrack {arg synthConfig;
		this.synthConfig_(synthConfig);
		this.synthNode_(nil);
		^this;
	}

	on {arg arguments, sustain;
		var synthDefName = this.synthConfig.name;
		var target = this.synthConfig.target;
		var addAction = this.synthConfig.addAction;
		arguments = this.synthConfig.arguments_(arguments, true);

		if(target.notNil, { target = target.value });

		if(
			not(
				and(this.synthNode.notNil,this.synthNode.isPlaying)
			), {
				{
					synthNode = Synth(synthDefName,arguments,target,addAction).register;
					if(sustain.notNil, {
						sustain.yield;
						this.off;
					})
				}.fork;
			}
		);
		^synthNode;
	}

	off {arg offArg=\gate, offValue=0;
		this.setArg(offArg, offValue);
		synthNode = nil;
	}

	forceOff {
		synthNode.free;
		synthNode = nil;
	}

	setArg {arg argName, argValue;
		this.synthConfig.argument_(argName, argValue);
		if(and(this.synthNode.notNil,this.synthNode.isPlaying), {
				this.synthNode.set(argName, argValue);
		});
	}
}

RDPatternLauncher {
	var <>patterns;
	var <>patternPlayers;

	*new {
		var instance;
		instance = super.new;
		instance.initRDPatternLauncher;
		^instance;
	}

	initRDPatternLauncher {
		patterns = Dictionary.new;
		patternPlayers = Dictionary.new;
	}

	setPattern {arg key, pattern;
		patterns[key] = pattern;
	}

	on {arg trackKey, patternKey;
		var pattern = patterns[patternKey];
		var player = patternPlayers[trackKey];

		if(pattern.notNil, {
			if((player.notNil.and(player.isPlaying)).not, {
				player = pattern.trace.play;
				patternPlayers[trackKey]=player;
			});
		});
	}

	off {arg trackKey;
		var player = patternPlayers[trackKey];
		if(player.notNil.and(player.isPlaying), {
			player.stop;
		});
		patternPlayers.removeAt(trackKey);
	}

}













