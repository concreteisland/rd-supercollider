SweepWithEnd {
	*ar {arg t_trig, start, end, rate;
		var offset,sweep, notInRange;
		offset = Latch.ar(start,t_trig);
		sweep = Sweep.ar(t_trig,rate)+offset;
		notInRange = (1- InRange.ar(sweep,min(start,end),max(start,end)));


		SendReply.ar(
			trig:Impulse.ar(1000),
			cmdName:'/SweepPosition',
			values:sweep,
			replyID: 0
		);

		//SendTrig.ar(notInRange,0,1);
		SendReply.ar(
			trig:notInRange,
			cmdName:'/SweepReachedEnd',
			values:sweep,
			replyID: 1
		);
		//FreeSelf.kr(notInRange);
		^sweep;
	}
}

