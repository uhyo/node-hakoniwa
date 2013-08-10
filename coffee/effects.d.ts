import lands=module('./lands');
import logs=module('../ts/logs');
import islands=module('../ts/islands');
export declare class Effect{
	private logs:logs.Log;
	constructor();
	on(hex:lands.Hex):void;
	appendLog(log:logs.Log):void;
}
export declare class Grow extends Effect{
}
export declare class Damage extends Effect{
	type:string;
	constructor(type:string);
}
