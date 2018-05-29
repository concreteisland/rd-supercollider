Instr(\latchInit, {arg in, trigger, initValue = 0, init = 0;
	var isInit, latch, out;
	isInit = (1 - SetResetFF.kr(trigger, init));
	latch = Latch.kr(in, trigger);
	latch.poll;
	out = Select.kr(isInit, [latch, initValue]);
	out.poll;
	out;
});

Ndef(\latchInit, {arg in, trigger, initValue = 0, init = 0;
	var latch;
	latch = Instr(\latchInit).func.value(in, trigger, initValue, init);
	latch;
})


Ndef(\latchInit).set(\in, 0.3)
Ndef(\latchInit).set(\in, 0)
Ndef(\latchInit).set(\trigger, 0)
Ndef(\latchInit).set(\trigger, 1)
Ndef(\latchInit).set(\initValue, 0.6)
Ndef(\latchInit).set(\init, 0)
Ndef(\latchInit).set(\init, 1)

