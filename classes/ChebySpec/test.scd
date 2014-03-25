(
Instr(\foo, {arg freq,shaperBuffer;
	var snd, shaper;
	snd = SinOsc.ar(freq);
	shaper = Shaper.ar(shaperBuffer,snd);
	snd = shaper;
	snd;
},[
		\freq,
		ChebySpec.new(0,0,\lin,0,[0,0,0,0,0,0]);
]);
p = Patch(\foo);
p.gui;
)

p.gui


p.set(\shaperBuffer,[1,1,1,0,1,1])
p.shaperBuffer.value
p.shaperBuffer.dependants
