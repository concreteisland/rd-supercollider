RDBufferUtils {
	*loadBuffer {arg path, server, buffer, callback;
		var condition;
		condition = Condition.new(false);
		{
			condition.wait;
			callback.value(buffer);
		}.fork;
		{
			if(buffer.isNil, {
				buffer = Buffer.read(server,path);
			}, {
				buffer = Buffer.read(server, path, bufnum: buffer.bufnum);
			});
			server.sync;
			condition.test = true;
			condition.signal;
		}.forkIfNeeded;
	}

	*allocateBuffer {arg server, buffer, numFrames, numChannels=1, callback;
		var condition;
		condition = Condition.new(false);
		{
			condition.wait;
			callback.value(buffer);
		}.fork;
		{
			if(buffer.isNil, {
				buffer = Buffer.alloc(server, numFrames, numChannels);
			}, {
				buffer = Buffer.alloc(server, numFrames, numChannels, bufnum: buffer.bufnum);
			});
			server.sync;
			condition.test = true;
			condition.signal;
		}.forkIfNeeded;
	}


	*createMonoBufferListFromPath {arg path, server, buffers, func;
		var numChannels, monoBuffers, condition;

		numChannels = RDBufferUtils.getNumChannels(path);
		condition = Condition.new(false);
		monoBuffers = List.new;

		{
			condition.wait;
			func.value(monoBuffers);
		}.fork;

		numChannels.do({arg channelIndex;
			var oldBuffer = buffers.tryPerform(\at, channelIndex);
			var bufnum = oldBuffer !? {oldBuffer.bufnum};
			Buffer.readChannel(server,path, channels: channelIndex, action: {arg buffer;
				"read audio buffer channel %: %\n".postf(channelIndex, buffer);
				monoBuffers.add(buffer);
				if(channelIndex == (numChannels-1), {
					condition.test = true;
				  condition.signal;
				});
			}, bufnum: bufnum);
		});
	}

	*getNumChannels {arg path;
		var numChannels, soundfile;

		soundfile = SoundFile.new;
		soundfile.openRead(path);
		numChannels = soundfile.numChannels;
		soundfile.close;
		^numChannels;
	}

	*createEnvelopeBuffer { arg envelope, numFrames, server, buffer, function;
		var signal;

		if(buffer.notNil, {
			signal = envelope.asSignal(buffer.numFrames);
			buffer.loadCollection(signal, action: {arg buffer;
				function.value(buffer);
			});
		}, {
			signal = envelope.asSignal(numFrames);
			Buffer.loadCollection(server, signal, 1, {arg buffer;
				function.value(buffer);
			});
		});
	}

	*createSineEnvelopeBuffer {arg attack, release, numFrames, server, buffer, function;
		var envelope, sustain, asr;
		sustain = (1.0 - (attack + release)).clip(0,1);
		asr=[attack,sustain,release].normalizeSum;
		envelope = Env.linen(asr[0],asr[1],asr[2],curve:\sin);
		RDBufferUtils.createEnvelopeBuffer(envelope, numFrames, server, buffer, function);
	}

	*createSignalBuffer{arg buffer, signal, server, asWavetable=false, callback;
		if(asWavetable, {
			signal = signal.asWavetableNoWrap;
		});
		if(buffer.notNil, {
			buffer.loadCollection(signal, action: {arg buffer;
				callback.value(buffer);
			});
		}, {
			Buffer.loadCollection(server, signal, 1, {arg buffer;
				callback.value(buffer);
			});
		});
	}

	*probabilitySignal {arg signal;
		var integrated, flipped, numFrames;
		signal = signal.normalize * signal.size;
		integrated = signal.integrate;
		integrated = integrated.normalize * signal.size;
		flipped = Signal.fill(signal.size, { arg i; integrated.indexInBetween(i) });
		flipped = flipped / signal.size;
		^flipped;
	}

	*envProbabilityBuffer{arg envelope, numFrames, server, buffer, asWavetable=false, callback;
		var envSignal;
		if(asWavetable, {
			numFrames = (numFrames+2)/2;
		});
		envSignal = RDBufferUtils.probabilitySignal(envelope.asSignal(numFrames));
		RDBufferUtils.createSignalBuffer(buffer, envSignal, server, asWavetable, callback);
	}
}