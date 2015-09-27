RDPartConvKernel : RDChannelSample {

	/*
	loadBuffer { arg path, server;
		var soundfile, numChannels, audioBuffer, spectralBuffer, spectralBufferSize;
		{
			if(buffer.notNil, {
				buffer.do({arg item;
					item.free;
				})
			});

			soundfile = SoundFile.new;
			soundfile.openRead(path);
			numChannels = soundfile.numChannels;
			soundfile.close;

			audioBuffer = Array.newClear(numChannels);
			audioBuffer.do({arg item, i;
				audioBuffer[i] = Buffer.readChannel(server,path,channels:i);
			});

			server.sync;

			spectralBufferSize = PartConv.calcBufSize(16384, audioBuffer[0]);

			spectralBuffer = Array.newClear(numChannels);
			spectralBuffer.do({arg item, i;
				spectralBuffer[i] = Buffer.alloc(server, spectralBufferSize,1);
			});

			server.sync;

			spectralBuffer.do({arg item, i;
				spectralBuffer[i].preparePartConv(audioBuffer[i], 16384);
			});

			server.sync;

			audioBuffer.do({arg item, i;
				audioBuffer[i].free;
			});

			buffer = spectralBuffer;
		}.forkIfNeeded;
	}
	*/

	init {arg argKey, argPath, argServer;
		var soundfile, numChannels, audioBuffer, spectralBuffer, spectralBufferSize;

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

			audioBuffer = Array.newClear(numChannels);
			audioBuffer.do({arg item, i;
				audioBuffer[i] = Buffer.readChannel(server,path,channels:i);
			});

			server.sync;

			spectralBufferSize = PartConv.calcBufSize(16384, audioBuffer[0]);

			spectralBuffer = Array.newClear(numChannels);
			spectralBuffer.do({arg item, i;
				spectralBuffer[i] = Buffer.alloc(server, spectralBufferSize,1);
			});

			server.sync;

			spectralBuffer.do({arg item, i;
				spectralBuffer[i].preparePartConv(audioBuffer[i], 16384);
			});

			server.sync;

			audioBuffer.do({arg item, i;
				audioBuffer[i].free;
			});

			buffer = spectralBuffer;

		}.forkIfNeeded;
		^this;
	}
}


/*
~lotti.fftSize = 16384;
~lotti.irAudioBufferPath = "D:/MusikMachen/Field_Recordings/_normalized/muskernel.wav";
~lotti.irAudioBufferL = Buffer.readChannel(s,~lotti.irAudioBufferPath,channels:0);
~lotti.irAudioBufferR = Buffer.readChannel(s,~lotti.irAudioBufferPath,channels:1);
~lotti.irSpectralBufferSize = PartConv.calcBufSize(~lotti.fftSize, ~lotti.irAudioBufferL);
~lotti.irSpectralBufferL = Buffer.alloc(s, ~lotti.irSpectralBufferSize, 1);
~lotti.irSpectralBufferR = Buffer.alloc(s, ~lotti.irSpectralBufferSize, 1);

~lotti.irSpectralBufferL.preparePartConv(~lotti.irAudioBufferL, ~lotti.fftSize);
~lotti.irSpectralBufferR.preparePartConv(~lotti.irAudioBufferR, ~lotti.fftSize);

~lotti.irAudioBufferL.free
~lotti.irAudioBufferR.free
*/