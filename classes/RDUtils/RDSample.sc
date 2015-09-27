/*
RDSample {
	var name;
	var <>buffer;

	*new {arg name, path, server;
		var instance;
		var rdSampleInLibrary;

		rdSampleInLibrary = this.at(name);

		if(path.isNil,{
			format("path is nil, so return sample in Libary").debug("new");
			^rdSampleInLibrary;
		});

		if(rdSampleInLibrary.notNil,{
			rdSampleInLibrary.update(path, server);
			^rdSampleInLibrary;
		});

		format("create new sample").debug("new");

		instance = super.newCopyArgs(name, path, server);
		instance.initRDSample(name, path, server);
		^instance;
	}

	*at { arg  name;
		var key = [this.asSymbol];
		var search = Library.atList( key ++ name);

		format("searched in Library for \'%\' and found %",
			[this] ++ name,
			search
		).debug("at");
		^search;
	}

	initRDSample {arg newName, path, server;
		var key;

		name = newName;
		key = [this.class.asSymbol] ++ name;
		this.loadBuffer(path, server);
		Library.putList(key ++ this);
		format("put % in Library with key %",this,key).debug("initRDSample");
	}

	loadBuffer {arg path, server;
		if(buffer.notNil, {buffer.free});
		^buffer = Buffer.read(server, path);
	}

	bufnum {
		^(buffer !? buffer.bufnum);
	}

	update {arg path, server;
		format("update sample in Libary").debug("update");
		if(server.isNil, {
			server = buffer.server;
		});
		this.loadBuffer(path, server);
	}
}
*/

RDSample : RDLibraryItem {
	var path;
	var server;
	var <buffer;

	thisValue {
		^this;
	}

	*new {arg key, path, server;
		^super.new(key, path, server);
	}

	init {arg argKey, argPath, argServer;
		key = argKey;
		path = argPath;
		server = argServer;
		{
			if(buffer.notNil, {buffer.free});
			server.sync;
			buffer = Buffer.read(server, path);
			server.sync;
		}.forkIfNeeded;
		^this;
	}

	mustUpdate {arg argPath, argServer;
		if(and(argPath.isNil,argServer.isNil), {
			^false;
		});
		if(or(argPath != path,argServer != server), {
			^true;
		})
		^false;
	}

	update {arg argPath, argServer;
		^this.init(key, argPath, argServer);
	}

	bufnum {
		^(buffer !? buffer.bufnum);
	}
}


/*
RDChannelSample : RDSample {

	loadBuffer {arg path, server;
		var soundfile, numChannels;

		if(buffer.notNil, {
			buffer.do({arg item;
				item.free;
			})
		});

		soundfile = SoundFile.new;
		soundfile.openRead(path);
		numChannels = soundfile.numChannels;
		soundfile.close;

		buffer = Array.newClear(numChannels);
		buffer.do({arg item, i;
			buffer[i] = Buffer.readChannel(server,path,channels:i);
		});

		^buffer;
	}

	buffer {arg index;
		^buffer.at(index);
	}

	bufnum {arg index;
		^buffer.at(index).bufnum;
	}

}
*/
RDChannelSample : RDSample {

	init {arg argKey, argPath, argServer;
		var soundfile, numChannels;

		key = argKey;
		path = argPath;
		server = argServer;

		{
			if(buffer.notNil, {
				buffer.do({arg item;
					item.free;
				})
			});

			server.sync;

			soundfile = SoundFile.new;
			soundfile.openRead(path);
			numChannels = soundfile.numChannels;
			soundfile.close;

			buffer = Array.newClear(numChannels);
			buffer.do({arg item, i;
				buffer[i] = Buffer.readChannel(server,path,channels:i);
			});

		}.forkIfNeeded;
		^this;
	}

	buffer {arg index;
		^buffer.at(index);
	}

	bufnum {arg index;
		^buffer.at(index).bufnum;
	}

}


RDEnvelopeBuffer : RDLibraryItem {
	var env;
	var frames;
	var server;
	var <buffer;

	*new {arg argKey, argEnv, argFrames, argServer;
		var instance = super.new(argKey, argEnv, argFrames, argServer);
		^instance;
	}

	init {arg argKey, argEnv, argFrames, argServer;
		key = argKey;
		env = argEnv;
		frames = argFrames;
		server = argServer;
		this.env2Buffer;
		^this;
	}

	env2Buffer {
		var tmpEnv;
		tmpEnv = env.asSignal(frames);
		if((buffer.notNil.and({buffer.numFrames == frames})), {
			buffer.loadCollection(tmpEnv);
		}, {
			if(buffer.notNil, {
				buffer.free;
			});
			buffer = Buffer.loadCollection(server, tmpEnv);
		});
	}

	mustUpdate {arg argEnv, argFrames, argServer;
		if((argEnv.isNil and: argFrames.isNil and: argServer.isNil), {
			^false;
		});

		if(((argEnv != env) or: (argFrames != frames) or: (argServer != server)), {
			^true;
		});

		^false;
	}

	update {arg argEnv, argFrames, argServer;
		^this.init(key, argEnv, argFrames, argServer);
	}
}

RDSineEnvelopeBuffer : RDEnvelopeBuffer {
	var attack, release;

	*new {arg key, attack, release, frames, server;
		^super.new(key, attack, release, frames, server);
	}

	init {arg argKey, argAttack, argRelease, argFrames, argServer;
		var tmpEnv;

		key = argKey;
		attack = argAttack;
		release = argRelease;
		frames = argFrames;
		server = argServer;
		env = this.createEnv;
		this.env2Buffer;
		^this;
	}

	createEnv {
		var resultEnv;
		if(attack.notNil && release.notNil, {
			var sustain, asr;
			sustain = (1.0 - (attack + release)).clip(0,1);
			asr=[attack,sustain,release].normalizeSum;
			resultEnv = Env.linen(asr[0],asr[1],asr[2],curve:\sin);
		});
		^resultEnv;
	}

	mustUpdate {arg argAttack, argRelease, argFrames, argServer;
		if((argAttack.isNil and: argRelease.isNil and: argFrames.isNil and: argServer.isNil), {
			^false;
		});

		if(((argAttack != attack) or: (argRelease != release) or: (argFrames != frames) or: (argServer != server)), {
			^true;
		});

		^false;
	}

	update {arg argAttack, argRelease, argFrames, argServer;
		^this.init(key, argAttack, argRelease, argFrames, argServer);
	}
}





/*
RDEnvelopeBuffer {
	var <buffer;
	var env;

	*new {arg name, env, frames, server;
		var instance;
		var rdEnvelopeBufferInLibrary = this.at(name);

		if(env.isNil,{
			format("env is nil, so return buffer in Libary").debug("new");
			^rdEnvelopeBufferInLibrary;
		});

		if(rdEnvelopeBufferInLibrary.notNil,{
			rdEnvelopeBufferInLibrary.update(env, frames, server);
			^rdEnvelopeBufferInLibrary;
		});

		format("create new buffer").debug("new");

		instance = super.new;
		instance.init(name, env, frames, server);
		^instance;
	}

	*at {arg name;
		var key = [this.asSymbol];
		var search = Library.atList( key ++ name);

		format("searched in Library for \'%\' and found %",
			[this] ++ name,
			search
		).debug("at");
		^search;
	}

	init {arg name, env, frames, server;
		var key;
		key = [this.class.asSymbol] ++ name;
		this.loadBuffer(env, frames, server);
		Library.putList(key ++ this);
		format("put % in Library with key %",this,key).debug("init");
	}

	loadBuffer {arg env, frames, server;
		format("the buffer is %", buffer).debug("loadBuffer");
		env = env.asSignal(frames);
		if((buffer.notNil.and({buffer.numFrames == frames})), {
			buffer.loadCollection(env);
		}, {
			if(buffer.notNil, {
				buffer.free;
			});
			buffer = Buffer.loadCollection(server, env);
		});
		^buffer;
	}

	update {arg env, frames, server;
		format("update buffer in Libary").debug("update");
		if(server.isNil, {
			server = buffer.server;
		});
		this.loadBuffer(env, frames, server);
	}

	bufnum {
		^(buffer !? buffer.bufnum);
	}
}
*/
/*
RDSineEnvelopeBuffer : RDEnvelopeBuffer {
	*new {arg name, attack, release, frames, server;
		^super.new(name, this.createEnv(attack, release), frames, server);
	}

	*createEnv {arg attack, release;
		var env;
		if(attack.notNil && release.notNil, {
			var sustain, asr;
			sustain = (1.0 - (attack + release)).clip(0,1);
			asr=[attack,sustain,release].normalizeSum;
			env = Env.linen(asr[0],asr[1],asr[2],curve:\sin);
		});
		^env;
	}
}
*/





/*
RDAdsrEnvelopeBuffer : RDEnvelopeBuffer {
	*new {arg name,
		attackTime, decayTime,
		sustainLevel, sustainTime,
		releaseTime, frames, server;
		^super.new(
			name,
			this.createEnv(
				attackTime, decayTime,
				sustainLevel, sustainTime,
				releaseTime
			),
			frames,
			server
		);
	}

	*createEnv {arg attackTime, decayTime,
		sustainLevel, sustainTime,
		releaseTime;
		var env;
		if(
			attackTime.notNil &&
			decayTime.notNil &&
			sustainLevel.notNil &&
			releaseTime.notNil &&
			sustainTime.notNil, {
			var sustain, asr;

			env = Env.new(
					levels: [0,1,sustainLevel,sustainLevel,0],
					times: [attackTime,decayTime,sustainTime,releaseTime]
			);
		});
		^env;
	}
}
*/
