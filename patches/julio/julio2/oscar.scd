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

~oscar.playerGui.soundfileView.mouseDownAction = {arg soundfileView, x, y;
	"mouseDown".postln;
	~oscar.playerGui.soundfileView.currentSelection_(2);
};




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



~oscar.playerGui.soundfileView.inspect

m = (~oscar.playerGui.soundfileView.scrollPos * ~oscar.playerGui.soundfileView.soundfile.numFrames);
n = (m - ~oscar.playerGui.soundfileView.viewFrames);

~zoom = ~oscar.playerGui.soundfileView.viewFrames / ~oscar.playerGui.soundfileView.soundfile.numFrames;

~framesPerPixel = ~oscar.playerGui.soundfileView.viewFrames / 362;

~xToFrame = {arg x;
	var framesPerPixel = ~oscar.playerGui.soundfileView.viewFrames /  ~oscar.playerGui.soundfileView.bounds.width;
	var zoom = ~oscar.playerGui.soundfileView.viewFrames / ~oscar.playerGui.soundfileView.soundfile.numFrames;
	var scrollRange = ~oscar.playerGui.soundfileView.soundfile.numFrames - ~oscar.playerGui.soundfileView.viewFrames;
	var frameLeft = ~oscar.playerGui.soundfileView.scrollPos * scrollRange;
	var framesFromLeft = x * framesPerPixel;
	var xFrame = frameLeft + framesFromLeft;

	xFrame;
}


~frameToX = {arg frame;
	var framesPerPixel = ~oscar.playerGui.soundfileView.viewFrames / ~oscar.playerGui.soundfileView.bounds.width;
	var zoom = ~oscar.playerGui.soundfileView.viewFrames / ~oscar.playerGui.soundfileView.soundfile.numFrames;
	var scrollRange = ~oscar.playerGui.soundfileView.soundfile.numFrames - ~oscar.playerGui.soundfileView.viewFrames;
	var frameLeft = ~oscar.playerGui.soundfileView.scrollPos * scrollRange;
	var framesFromLeft = frame - frameLeft;
	var x = framesFromLeft / framesPerPixel;
	x;
}

~xToFrame.value(0)
~oscar.playerGui.soundfileView.zoomToFrac(0.9)
~oscar.playerGui.soundfileView.scrollPos
~oscar.playerGui.soundfileView.scrollTo(0)

~frameToX.value(337635)




458029 - 379499.28262825


mouseDownAction = {arg soundfileView, x, y;
	soundfileView.setSelectionColor(1,Color.red);
	soundfileView.currentSelection_(1);
};
