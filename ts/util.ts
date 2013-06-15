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
export function prob(p:number):bool{
	return Math.random()<p;
}
