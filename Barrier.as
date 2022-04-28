package  {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	//import Map.*;
	
	public class Barrier extends Sprite {
		var parentMap;
		var color = 0;
		var material = 0;
		var X1,X2,Y1,Y2 = 0;
		var objName:String;
		

		//конструктор 
		public function Barrier(parentMap, objName, material, X1, Y1, X2, Y2) {
			// constructor code
			this.parentMap = parentMap;
			this.objName = objName;
			this.material = material;
			this.X1 = X1;	// размеры в метрах
			this.Y1 = Y1;
			this.X2 = X2; 
			this.Y2 = Y2;
			
			var w = (((X2 - X1) * parentMap.resolution) * parentMap.scale); // вычисляем размеры в пикселах
			var h = (((Y2 - Y1) * parentMap.resolution) * parentMap.scale);
		
			this.graphics.beginFill(Map.MATERIAL[material][Map.COLOR]);
			this.graphics.drawRect(0, 0, w, h);
			
			width = w;
			height = h;
			
			x = ((X1 * parentMap.resolution) * parentMap.scale);
			y = ((Y1 * parentMap.resolution) * parentMap.scale);

			//trace(w,h,width, height)
			//this.name = "target2";
			
			addEventListener(MouseEvent.MOUSE_DOWN, drag) 
			addEventListener(MouseEvent.MOUSE_UP, noDrag);
		}
			function drag(event:MouseEvent):void {
    			startDrag(false, new Rectangle(100,0,700,600));
			}

			function noDrag(event:MouseEvent):void {
    			stopDrag();
				this.X1 = ((x / parentMap.resolution) / parentMap.scale);
				this.Y1 = ((y / parentMap.resolution) / parentMap.scale);
				this.X2 = this.X1 + ((width / parentMap.resolution) / parentMap.scale);
				this.Y2 = this.Y1 + ((height / parentMap.resolution) / parentMap.scale);
    			//trace(this.dropTarget.name);
			}


	}
	
}
