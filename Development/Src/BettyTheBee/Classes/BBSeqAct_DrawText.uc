class BBSeqAct_DrawText extends SequenceAction;

/** Text of frist line */
var () string text1;
/** Text of second line */
var () string text2;
/** Lenght of text */
var () int size;
/** Screen position X. Range of [0..1] */
var () float posX<ClampMin=0.0 | ClampMax=1.0>;
/** Sreen position Y. Range of [0..1] */
var () float posY<ClampMin=0.0 | ClampMax=1.0>;

Defaultproperties
{
	bCallHandler = true;
	HandlerName="DrawText"
	ObjName="DrawText"
	ObjCategory="GFx UI"

}