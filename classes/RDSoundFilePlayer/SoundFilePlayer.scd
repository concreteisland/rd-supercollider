(
SynthDef(\SoundFilePlayer, {arg out=0, bufnum = 0, amp = 1,pan = 0,rate=1, run=1;
	var vDiskIn;
	vDiskIn = VDiskIn.ar(2,bufnum,rate*run,0,1);
	Out.ar(out, Balance2.ar(vDiskIn[0],vDiskIn[1],pan,amp));
}).store;

(
SynthDef(\SoundFilePlayer1, {arg out=0, bufnum = 0, amp = 1,pan = 0,rate=1, run=1;
	var vDiskIn;
	vDiskIn = VDiskIn.ar(1,bufnum,rate*run,0,1);
	Out.ar(out, Balance2.ar(vDiskIn[0],vDiskIn[1],pan,amp));
}).store;
)
)