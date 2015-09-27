~oscar = ();

~oscar.mixerChannel = MixerChannel.new('oscar',s,2,2);
~oscar.mixerChannel.level_(1);

~oscar.player = RDSoundfilePlayer.new(s);
~oscar.player.setLoopMode(\loop);
~oscar.player.loadSoundfile("D:/MusikMachen/Tracks/julio/strasse/oscar2.wav");
~oscar.player.setRate(0.1);
~oscar.player.outBus_(~oscar.mixerChannel.asBus.index);
~oscar.playerGui = ~oscar.player.gui;

~oscar.player.play;

~oscar.player.setBoundaries(0,44100);

~oscar.playerGui.soundfileView.selection(~oscar.playerGui.soundfileView.currentSelection)






//~oscar.kernel.RDPartConvKernel(\x,,s)



~oscar.player.inspect

~oscar.playerGui.soundfileView.selection(~oscar.playerGui.soundfileView.currentSelection)[1]

true || false




		~oscar.playerGui.soundfileView.mouseUpAction = {arg soundfileView, x, y;
			var currentSelection, lowerBoundary, upperBoundary;
			soundfileView.currentSelection_(0);
			currentSelection = soundfileView.selection(soundfileView.currentSelection);
			lowerBoundary = currentSelection[0];
			upperBoundary = lowerBoundary + currentSelection[1];
			~oscar.player.setBoundaries(lowerBoundary,upperBoundary);
		};


~oscar.playerGui.soundfileView.mouseDownAction = {arg soundfileView, x, y;
	soundfileView.setSelectionColor(1,Color.red);
	soundfileView.currentSelection_(1);
};
