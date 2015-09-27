RDLibraryItem {
	var key;

	*new {arg key ... args;
		var instance;
		var instanceInLibrary;

		instanceInLibrary = this.at(key);

		if(instanceInLibrary.notNil, {
			if(instanceInLibrary.performList(\mustUpdate, args), {
				instanceInLibrary.performList(\update, args);
			});
			^instanceInLibrary.thisValue;
		});

		instance = super.new;
		instance.performList(\init, args.addFirst(key));
		instance.put;
		^instance.thisValue;
	}

	*at {arg key;
		var libKey = [this.asSymbol, key];
		^Library.atList(libKey);
	}

	put {
		var libKey = [this.class.asSymbol, key];
		Library.putList(libKey ++ this);
		^this;
	}

	/***************/

	thisValue {
		^this;
	}

	init {arg argKey;
		key	= argKey;
		^this;
	}

	mustUpdate {
		^false;
	}

	update {
		^this;
	}

}

RDTwoValues : RDLibraryItem {
	var value1;
	var value2;

	init {arg argKey, argValue1, argValue2;
		key	= argKey;
		value1 = argValue1;
		value2 = argValue2;
		^this;
	}

	mustUpdate {arg argValue1, argValue2;
		if(and(argValue1.isNil, argValue2.isNil), {
			^false;
		}, {
			^(or(argValue1==value1, argValue2==value2));
		});
	}

	update {arg argValue1, argValue2;
		^this.init(key, argValue1, argValue2);
	}
}