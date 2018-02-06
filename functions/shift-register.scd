(
Instr(\shiftRegister, {arg size = 5, trigger, in;
	var buffer = LocalBuf(size);
	var index;
	index = Stepper.kr(trigger,0,0,size-1,1);
	Demand.kr(trigger, 0, Dbufwr(in, buffer, index));
	Demand.kr(trigger, 0, Dbufrd(buffer, index + (1..size))).reverse;
});
)

(
{
	var srSize, trigger, in, sr;
	srSize = 4;
	trigger = Dust.kr(10);
	in = LFNoise0.ar(150);
	sr = Instr(\shiftRegister).kr(srSize, trigger, in);
	[trigger]++sr;
}.plot(1)
)
