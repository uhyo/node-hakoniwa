import lands=module('./lands');
export class Effect{
	constructor();
	on(hex:lands.Hex):void;
}
export class Grow extends Effect{
}
export class Damage extends Effect{
	type:string;
	constructor(type:string);
}
