MIDIMKtl.find;
(
Platform.case(
	\osx, {
		~qneo = MIDIMKtl('qn0', 93031802, -1377345544);  // QUNEO
		~bcr = MIDIMKtl('bcr20000', 1245204123, 1064082871);  // BCR2000
	},
	\windows, {
		~qneo = MIDIMKtl('qn0',1,3,'QUNEO');
		~bcr = MIDIMKtl('bcr',2,4,'BCR2000');
	}
);
)
/* TEST */
(
~bcr.verbose_(true);
~qneo.verbose_(true);
)
(
~bcr.verbose_(false);
~qneo.verbose_(false);
)
/*FAKE */
(
~qneo = MIDIMKtl.make(\qneo, \QUNEO);
~bcr = MIDIMKtl.make(\bcr20000, \BCR2000);
~bcr.gui;
)


/*MASTER MIXER********************************/
(
s.options.memSize = 2**21;
s.waitForBoot({
	~live1 = ();
	MixerChannel.freeAllOnServer(s);
	m = Array.fill(8, {|i|
		var c = MixerChannel.new("ch"+i,s,2,2,1);
		~bcr.elements.knUp[0][i].action_({|e|
			c.level_(e.value);
		});
		c;
	});
	s.sync;
	~live1.mixer = ~live1.mixer ?? MixingBoard.new(\live1);
	s.sync;
	m.do({|c|
		~live1.mixer.add(c);
	});
	s.plotTree;
	s.meter;
	s.makeGui;
	s.scope(2);
	MasterEQ.new;
});
)




























