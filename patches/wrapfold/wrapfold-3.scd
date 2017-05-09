(
Instr(\duty, {arg freq=1;

	var seq, seq2;
	var durations, freqs;
	var pattern;
	var osc;

	seq   = [5,4];
	seq2 = [3,2,4];
	durations = [
		Dseq(seq*freq.reciprocal,inf),
		Dseq(seq2*freq.reciprocal,inf),
	];
	freqs        = [
		Dseq((seq*freq.reciprocal).reciprocal,inf),
		Dseq((seq2*freq.reciprocal).reciprocal,inf),
	];
	pattern     = Duty.ar(durations,0,freqs);


	osc = VarSaw.ar(pattern,0.75,0).range(0,1);
	osc = [osc[0], (1-osc[1])];


	[
		min(osc[0], osc[1]),
		max(osc[0], osc[1]),
		absdif(osc[0], osc[1]),
		osc[0]*osc[1],
		(osc[0]+osc[1])/2
	];
});
)

({Instr(\duty).func.value(48);}.plot(0.5))