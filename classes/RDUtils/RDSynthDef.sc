RDSynthDef {
	var <synthDefName;
	var <>preCreationFunction;
	var <>postCreationFunction;
	var <>postFreeFunction;
	var <synthDefArguments;


	*new {arg synthDefName;
		var instance = super.new;
		instance.initRDSynthDef(synthDefName);
		^instance;
	}

	initRDSynthDef {arg argSynthDefName;
		synthDefName = argSynthDefName;
		synthDefArguments = Dictionary.new;
	}
}


RDSynthDefArgument {
	var <name;
	var <defaultValue;
	var <> preSetFunction;
	var <> postSetFunction;
	var <argumentStrategy;

	*new {arg defaultValue, name, argumentStrategy;
		var instance = super.new;
		instance.initRDSynthDefArgument(defaultValue, name, argumentStrategy);
		^instance;
	}

	initRDSynthDefArgument {arg argDefaultValue, argName, argArgumentStrategy;
		name = argName;
		defaultValue = argDefaultValue;
		argArgumentStrategy.isNil.if({
			argumentStrategy = RDSynthArgumentStrategy.new;
		}, {
			argumentStrategy = argArgumentStrategy;
		});

	}

	isNodeArg {
		^name.notNil;
	}
}

RDSynthArgumentStrategy {
	setValue {arg argument ... args;
		if(args.size > 1, {
			argument.attributes.put(\value, args);
		}, {
			argument.attributes.put(\value, args[0]);
		});
		^argument.attributes;
	}
	getValue {arg argument;
		^argument.attributes[\value];
	}
	getValueForSynth {arg argument;
		^argument.attributes[\value];
	}
}

//setting value [path, server]
RDSynthArgumentSampleStrategy : RDSynthArgumentStrategy {
	setValue {arg argument, path, server;
		if(path.notNil, {
			if(server.notNil, {
				var buffer = Buffer.read(server,path);
				argument.attributes.put(\value, buffer)
			});
		});
	}
	getValueForSynth {arg argument;
		^argument.attributes[\value].bufnum;
	}
}


