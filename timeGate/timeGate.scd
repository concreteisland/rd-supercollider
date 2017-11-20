(Instr(\timeGate, {arg in, time=0;
	var inOn, inOff, timer, out;
	inOn = in.abs > 0;
	timer = Sweep.ar(inOn,1)* inOn;
	out = Select.ar(timer > time, [DC.ar(0), DC.ar(1)]);
	out;
})
)
({
	var inGate, inGateOff,outGate, timer;
	var trigger;
	trigger = Impulse.ar(100);
	inGate = Trig1.ar(trigger, TRand.ar(0.0001,0.010,trigger));
	outGate = Instr(\timeGate).func.value(inGate, 0.001);
	[Decay.ar(trigger, 0.001), inGate, outGate]
}.plot(1/10)
)
({
	var sine, deriv, outGate;

	sine = SinOsc.ar(10).tanh.cubed.cubed;
	deriv = HPZ1.ar(sine,2);
	outGate = Instr(\timeGate).func.value(InRange.ar(deriv, -0.00005, 0.00005), 0.003);

	sine = sine + PinkNoise.ar(outGate * 0.1);

	[sine, deriv, outGate];
	sine;
}.plot(3/10)
)


