//Utility
//Hakoniwa 2.3と同じrandom 0〜(n-1)の整数乱数
export function random(n:number):number{
	return Math.floor(Math.random()*n);
}
//引数のどの位置にあてはまるかで数値を返す
export function rand(n:number,...ns:number[]):number{
	var ra=random(n);
	for(var i=0,l=ns.length;i<l;i++){
		if(ra<=ns[i]){
			return i;
		}
	}
	//あてはまらない
	return l;
}
//確率判定して返す p:0〜1
export function prob(p:number):boolean{
	return Math.random()<p;
}
//整数版p:0〜n
export function probb(p:number,n:number):boolean{
	return prob(p/n);
}
//配列シャッフル(破壊的)
export function shufflE<T>(arr:Array<T>):Array<T>{
	//なんとかかんとか法（後ろから確定させる）
	for(var l=arr.length-1;l>=0;l--){
		var idx=random(l+1);
		var tmp=arr[idx];
		arr[idx]=arr[l];
		arr[l]=tmp;
	}
	return arr;
}
