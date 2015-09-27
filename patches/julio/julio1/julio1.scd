(
~julio1 = ();
~julio1.path = PathName("C:/Users/Felix/rd-supercollider/patches/julio/julio1/");

s.options.memSize_(2**18);
s.waitForBoot({
	~julio1.mixer = MixingBoard.new(\julio1);
	s.plotTree;
	s.scope(2);
	s.latency_(0.02);

	(~julio1.path +/+ "julio1.conv1.scd").fullPath.openTextFile;
	(~julio1.path +/+ "julio1.bass1.scd").fullPath.openTextFile;
	(~julio1.path +/+ "julio1.ping.scd").fullPath.openTextFile;
	(~julio1.path +/+ "julio1.schweb1.scd").fullPath.openTextFile;
	(~julio1.path +/+ "julio1.schweb2.scd").fullPath.openTextFile;
	(~julio1.path +/+ "julio1.bad1.scd").fullPath.openTextFile;
	(~julio1.path +/+ "julio1.controller.scd").fullPath.openTextFile;
	(~julio1.path +/+ "julio1.synthdefs.scd").fullPath.openTextFile;


	/* GROUPS *************************/
	~julio1.groups = ();
	~julio1.groups.main = RDGroup(\julio1Main, s);
	~julio1.groups.sndSrc = RDGroup(\julio1SndSrc, \julio1Main);
	~julio1.groups.fx1 = RDGroup(\julio1Fx1, \julio1SndSrc, \addAfter);
	~julio1.groups.fx2 = RDGroup(\julio1Fx2, \julio1Fx1, \addAfter);
	~julio1.groups.fx2.group;

});
)



~julio1.mixer.add(~julio1.schweb1.mixerChannel);
~julio1.mixer.add(~julio1.schweb2.mixerChannel);
~julio1.mixer.add(~julio1.ping.mixerChannel);
~julio1.mixer.add(~julio1.bass1.mixerChannel);
~julio1.mixer.add(~julio1.conv1.mixerChannel);
~julio1.mixer.add(~julio1.pfeif1.mixerChannel);
~julio1.mixer.add(~julio1.bad1.mixerChannel1);


(
Ndef(\x, {
	RLPF.ar(
	WeaklyNonlinear.ar(
		SinOsc.ar(1200,0,0.1),
		Dust.kr(15).ceil,
		0.11,0.3,[401,402],0.00000001,1,0.00000002,1.3,0,4.2
	) * 0.1
		,[40,5150],[0.05,0.7]);
})
)
Ndef(\x).play
s.scope(1)


