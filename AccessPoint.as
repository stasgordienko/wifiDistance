package  {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class AccessPoint extends Sprite{
		var parentMap:Map;
		var APName:String;		// Наименование ТД
		var antGain:int;		// усиление антенны Dbi
		var power:int;			// мощность передатчика Db
		var X:Number;		// позиция X м
		var Y:Number;		// позиция Y м
		var W,H,w,h:Number;
		var maxSpeed:int = 54;	// макс. скорость Мбит/сек

		public function AccessPoint(parentMap, APName="AP", power=17, antGain=2, posX=2, posY=3, maxSpeed=54) {
			// constructor code
			this.parentMap = parentMap;
			this.APName = APName;
			this.power = power;
			this.antGain  = antGain;
			this.maxSpeed = maxSpeed;
			this.X = posX;
			this.Y = posY;
			
			//this.H = 0.25; // размеры в метрах
			//this.W = 0.25;
			w = 10; // вычисляем размеры в пикселах
			h = 10;
		
			this.graphics.lineStyle(2,1);
			this.graphics.beginFill(2,0.5);
			this.graphics.drawCircle(-w/2, -h/2, w);
			

			this.x = ((this.X * parentMap.resolution) * parentMap.scale) + w/2;
			this.y = ((this.Y * parentMap.resolution) * parentMap.scale) + h/2;

			//trace(w,h,width, height)
			
			addEventListener(MouseEvent.MOUSE_DOWN, drag); 
			addEventListener(MouseEvent.MOUSE_UP, noDrag);
			addEventListener(MouseEvent.DOUBLE_CLICK, menu);
		}
			function drag(event:MouseEvent):void {
    			startDrag(false, new Rectangle(100,0,700,600));
				//trace("old values: x=" + x +" y="+ y);
			}

			function noDrag(event:MouseEvent):void {
    			stopDrag();
				this.X = ((x / parentMap.resolution) / parentMap.scale);
				this.Y = ((y / parentMap.resolution) / parentMap.scale);
				//trace("new values: x=" + x +" y="+ y);
    			//trace(this.dropTarget.name);
			}
			
			function menu(event:MouseEvent):void {
				//menu.visible = true;
			}
		

	}
	
}
