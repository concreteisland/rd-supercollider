RDSynthConfig {
	var <rdSynthDef;
	var <target;
	var <addAction;
	var properties;
	var synthArguments;

	*new {arg rdSynthDef, arguments, target, addAction;
		var instance = super.new;
		instance.initRDSynthConfig(rdSynthDef, arguments, target, addAction);
		^instance;
	}

	initRDSynthConfig {arg argRdSynthDef, argArguments, argTarget, argAddAction;
		rdSynthDef = argRdSynthDef;
		synthArguments = Dictionary.new;
		rdSynthDef.synthDefArguments.keysValuesDo({arg name, synthDefArgument;
			//TODO: types, use some kind of factory to create new synthArguments;
			synthArguments.put(name, RDSynthArgument.new(synthDefArgument));
		});
		this.set(*argArguments);
		target = argTarget;
		addAction = argAddAction ? \addToHead;
	}

	set {arg ... args;
		var argMap = Dictionary.newFrom(args);
		var setArgs = Dictionary.new;
		argMap.keysValuesDo({arg key, value;
			var argument = synthArguments.at(key);
			if(argument.notNil, {
				argument.value_(*value);
				setArgs.put(key, argument);
			});
		});
	}

	arguments {
		var arguments = Dictionary.new;
		synthArguments.keysValuesDo({arg name, argument;
			arguments.put(name, argument.value);
		});
		^arguments.getPairs;
	}

	synthArguments {arg ... args;
		var result;
		if(args.size > 0, {
			result = synthArguments.select({arg argument, key;
				args.indexOf(key).notNil;
			});
		}, {
			result = synthArguments;
		});
		^result
	}

	synthArgumentsValues {arg ... args;
		^this.synthArguments(*args).collect({arg argument, key;
			argument.value;
		});
	}

	synthArgumentsValuesForSynth {arg ... args;
		var nodeArguments = this.synthArguments(*args).select({arg argument, key;
			argument.isNodeArg;
		});
		var synthArgumentsValuesForSynth = Dictionary.new;
		nodeArguments.keysValuesDo({arg key, value;
			synthArgumentsValuesForSynth.put(value.name, value.valueForSynth);
			//TODO if names and values is more than one, then expand
		});
		^synthArgumentsValuesForSynth;
	}
}





