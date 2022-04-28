package  {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class Reciever extends Sprite {
		var parentMap:Map;
		var rcvName:String;			// наименование точки
		var antType:int;			// тип антенны (круговая, секторная)
		var antGain:int;			// усиление антенны Db
		var sensitivity:int = -96;	// чувствительность приемника Dbi
		var X:Number;	// позиция X м
		var Y:Number;	// позиция Y м
		var w,h:Number;
		var reqSpeed:int;	// необходимая мин скорость Мбит
		var signal:Array;	// таблица уровней сигнала от каждой базовой ТД 
							//(точкaДоступа, дистанция, сигнал, скорость)
		
		
		public function Reciever(parentMap, rcvName="unnamed", antGain=2, posX=1, posY=1, antType=0, sensitivity=-96, reqSpeed=2) {
			// constructor code
			this.parentMap = parentMap;
			this.antGain = antGain;
			this.rcvName = rcvName;
			this.antType = antType;
			this.sensitivity = sensitivity;
			this.reqSpeed = reqSpeed;
			X = posX;
			Y = posY;
			this.signal = new Array();
			
			w = 10; // вычисляем размеры в пикселах
			h = 10;
		
			this.graphics.lineStyle(1,3);
			this.graphics.beginFill(2,0.3);
			this.graphics.drawCircle(-w/2, -h/2, w);
			

			x = ((X * parentMap.resolution) * parentMap.scale) + w/2;
			y = ((Y * parentMap.resolution) * parentMap.scale) + h/2;

			//trace(w,h,width, height)
			this.name = "target1";
			
			addEventListener(MouseEvent.MOUSE_DOWN, drag) 
			addEventListener(MouseEvent.MOUSE_UP, noDrag);
		}
		
			function drag(event:MouseEvent):void {
    			startDrag(false, new Rectangle(100,0,700,600));
			}

			function noDrag(event:MouseEvent):void {
    			stopDrag();
				this.X = ((x / parentMap.resolution) / parentMap.scale);
				this.Y = ((y / parentMap.resolution) / parentMap.scale);
    			//trace(this.dropTarget.name);
			}

	}
	
}
