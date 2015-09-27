RDSynthConfig {
	var <name;
	var arguments;
	var <target;
	var <addAction;


	*new {arg name, arguments, target, addAction;
		var instance = super.new;
		instance.initRDSynthConfig(name, arguments, target, addAction);
		^instance;
	}

	initRDSynthConfig {arg argName, argArguments, argTarget, argAddAction;
		name = argName;
		arguments = Dictionary.newFrom(argArguments);
		target = argTarget;
		addAction = argAddAction ? \addToHead;
	}

	arguments {
		^arguments.getPairs;
	}

	arguments_ {arg argArguments, add=false;
		if(add, {
			arguments = Dictionary.newFrom(this.arguments ++ argArguments);
		}, {
			arguments = Dictionary.newFrom(argArguments);
		});
		^arguments;
	}

	argument {arg argName;
		^arguments[argName];
	}

	argument_ {arg argName, argValue;
		arguments[argName] = argValue;
		^this.argument(argName);
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

/*************************************/
/*
RDSynthLauncher {
	var <>synthConfigs;
	var <>tracks;

	*new {
		var instance = super.new;
		instance.initRDSynthLauncher;
		^instance;
	}

	initRDSynthLauncher {
		synthConfigs = Dictionary.new;
		tracks = Dictionary.new;
	}

	setConfig {arg key, config;
		synthConfigs[key] = config;
	}

	on {arg trackKey, configKey, arguments, sustain;
		var track = tracks[trackKey];
		var config = synthConfigs[configKey];

		if(track.isNil, {
			track = RDSynthTrack.new(config);
			tracks[trackKey] = track;
		});

		track.on(arguments, sustain);
	}

	off {arg trackKey, offArg=\gate, offValue=0;
		var track = tracks[trackKey];
		if(track.notNil, {
			track.off(offArg, offValue);
		})
	}

	forecOff {arg trackKey;
		var track = tracks[trackKey];
		if(track.notNil, {
			track.forceOff;
		})
	}

	setArg {arg trackKey, argName, argValue;
		var track = tracks[trackKey];
		if(track.notNil, {
			track.setArg(argName, argValue);
		})
	}
}
*/
/*************************************/

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


RDSynthLauncher {
	var <>synthConfigs;
	var <>synthNodes;

	*new {
		var instance = super.new;
		instance.initRDSynthLauncher;
		^instance;
	}

	initRDSynthLauncher {
		synthConfigs = Dictionary.new;
		synthNodes = Dictionary.new;
	}

	setConfig {arg key, config;
		synthConfigs[key] = config;
	}

	on {arg trackKey, configKey, arguments, sustain;
		var config = synthConfigs[configKey];
		var synthDefName = config.name;
		var target = config.target;
		var addAction = config.addAction;
		arguments = config.arguments ++ arguments;

		arguments.postln;

		if(target.notNil, { target = target.value });

		if(
			not(
				and(
					synthNodes[trackKey].notNil,
					synthNodes[trackKey].isPlaying
				)
			), {
				{
				synthNodes[trackKey] = Synth(
					synthDefName,
					arguments,
					target,
					addAction
				).register;

				if(sustain.notNil, {
					sustain.yield;
					this.off(trackKey)
				})
			}.fork;

		});
	}

	off {arg trackKey, offArg=\gate, offValue=0;
		this.setArg(trackKey, offArg, offValue);
		synthNodes[trackKey] = nil;
	}

	forecOff {arg trackKey;
		synthNodes[trackKey].free;
		synthNodes[trackKey] = nil;
	}

	setArg {arg trackKey, argName, argValue;
		if(and(synthNodes[trackKey].notNil,synthNodes[trackKey].isPlaying), {
				synthNodes[trackKey].set(argName, argValue);
		});
	}
}


