package  {
	//import flash.display.MovieClip;
	import flash.display.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle; 
	import flash.net.*;
	
	public class App extends MovieClip {
		var map:Map;
		var tool:Object;
		var toolmode:int = 0;
		var tempRect:Sprite = null; 			//временный прямоугольник
		var material:int;						//материал нового обьекта
		var startX, startY, endX, endY : int; 	//координаты временного прямоугольника
		

		public function App() {
			// constructor code
			this.map = new Map();      //создание карты
			this.addChild(this.map)
			this.tempRect = new Sprite; //создание временного прямоугольника
			this.tempRect.graphics.beginFill(0xCCFF00);
			this.tempRect.graphics.drawRect(0, 0, 10, 10);
			add_brick.material = Map.BRICK; //добавление свойства "material" кнопкам с назв. материала
			add_metal.material = Map.METAL;
			add_window.material = Map.GLASS;
			add_door.material = Map.WOOD;
			//this.map.calculate();
			
			this.tool = arrowtool; // задать текущий инструмент - стрелка
			switch_to(arrowtool); // переключить на текущий инструмент
			
			// добавление обработчиков событий нажатия мышкой на кнопках панели инструментов
			arrowtool.addEventListener(MouseEvent.CLICK, click_btn); 
			add_base.addEventListener(MouseEvent.CLICK, click_btn);
			add_client.addEventListener(MouseEvent.CLICK, click_btn);
			add_brick.addEventListener(MouseEvent.CLICK, click_btn);
			add_metal.addEventListener(MouseEvent.CLICK, click_btn);
			add_door.addEventListener(MouseEvent.CLICK, click_btn);
			add_window.addEventListener(MouseEvent.CLICK, click_btn);
			loadmap.addEventListener(MouseEvent.CLICK, loadMap);
			savemap.addEventListener(MouseEvent.CLICK, saveMap);
			calc.addEventListener(MouseEvent.CLICK, calculate);

		}
		
		public function loadMap(event:MouseEvent):void {
			//code
			this.map.loadFromXML();
		}
		
		public function saveMap(event:MouseEvent):void {
			//code
			this.map.saveToXML();
		}
		
		public function calculate(event:MouseEvent):void {
			//code
			this.map.calculate();
		}
		
		
		public function reDraw() {
			// redraw map
		}
		
		//переключение на инструмент
		public function switch_to(obj:Object):void { 
			trace("switch from:", this.tool.name, "to:", obj.name);
			this.tool.alpha = 1;
			this.tool = obj;
			obj.alpha = 0.2;
		}
		
		//обработчик события нажатия на кнопки панели инструментов
		public function click_btn(event:MouseEvent):void {
			
			switch( this.tool.name ) {
				case 'add_brick':
				case 'add_door':
				case 'add_window':
				case 'add_metal':
					stage.removeEventListener(MouseEvent.CLICK, startPoint);
					stage.removeEventListener(MouseEvent.CLICK, endPoint);
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, resizeTemp);
					//this.map.removeChild(this.tempRect);
					this.tempRect.width = 0;
					this.tempRect.height = 0;
					break;
			}
			
			switch( event.target.name ){
				case 'arrowtool':
					//but.x+=40;
					break;
				case 'add_brick':
				case 'add_door':
				case 'add_window':
				case 'add_metal':
					this.material = event.target.material;
					stage.addEventListener(MouseEvent.CLICK, startPoint);
					//switch_to(event.target);
					break;
				
				case 'add_base':
					stage.addEventListener(MouseEvent.CLICK, adding_base);
					break;
				
				case 'add_client':
					stage.addEventListener(MouseEvent.CLICK, adding_client);
					break;
				

			}
			
			switch_to(event.target);
					
		}

		//зафиксировать первую точку
		public function startPoint(e:MouseEvent) {
			if (e.stageX > 100 && e.stageY > 100) {
				this.startX = e.stageX;
				this.startY = e.stageY;
				this.tempRect.x = this.startX;
				this.tempRect.y = this.startY;
				this.tempRect.width = 1;
				this.tempRect.height = 1;
				this.tempRect.graphics.beginFill(Map.MATERIAL[this.material][Map.COLOR]);
				this.tempRect.graphics.drawRect(0, 0, 10, 10);
				this.map.addChild(this.tempRect);
				stage.removeEventListener(MouseEvent.CLICK, startPoint);
				stage.addEventListener(MouseEvent.CLICK, endPoint);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, resizeTemp);
				trace("Start point:", this.startX, ",", this.startY);
			}
		}

		//при перемещении указателя мыши - изменение размеров прямоугольника
		public function resizeTemp(e:MouseEvent) {
			if (e.stageX > this.startX) {
				this.tempRect.width = e.stageX - this.startX;
				this.tempRect.x = this.startX;
			}
			else
			{
				this.tempRect.width = this.startX - e.stageX;
				this.tempRect.x = e.stageX;
			}
			
			if (e.stageY > this.startY) {
				this.tempRect.height = e.stageY - this.startY;
				this.tempRect.y = this.startY;
			}
			else
			{
				this.tempRect.height = this.startY - e.stageY;
				this.tempRect.y = e.stageY;
			}

		}

		//зафиксировать вторую точку и создать обьект
		public function endPoint(e:MouseEvent) {
			this.endX = e.stageX;
			this.endY = e.stageY;
			trace(this.startX, this.startY, this.endX, this.endY)
			stage.removeEventListener(MouseEvent.CLICK, endPoint);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, resizeTemp);
			this.map.removeChild(this.tempRect);
			this.map.createObj("Object"+this.map.objList.length.toString(), this.material, (this.startX / this.map.resolution / this.map.scale), (this.startY / this.map.resolution / this.map.scale), (this.endX / this.map.resolution / this.map.scale), (this.endY / this.map.resolution / this.map.scale) );
			//click_btn(event:MouseEvent)
			switch_to(arrowtool);
		}
		
		public function adding_base(e:MouseEvent) {
			if (e.stageX > 100 && e.stageY > 100) {
				var apname = "AP"+this.map.APList.length.toString();
				this.map.createAP(apname, 17, 2, (e.stageX / this.map.resolution / this.map.scale), (e.stageY / this.map.resolution / this.map.scale) );
				trace('adding_base');
				stage.removeEventListener(MouseEvent.CLICK, adding_base);
				switch_to(arrowtool);
			}
		}
		
		public function adding_client(e:MouseEvent) {
			if (e.stageX > 100 && e.stageY > 100) {
				var rcvname = "Client"+this.map.rcvList.length.toString();
				this.map.createRcv(rcvname, 2,(e.stageX / this.map.resolution / this.map.scale), (e.stageY / this.map.resolution / this.map.scale) );
				trace('adding_client');
				stage.removeEventListener(MouseEvent.CLICK, adding_client);
				switch_to(arrowtool);
			}
		}
		
		public function example() {
			stage.frameRate = 31;
			var currentDegrees:Number = 0;
			var radius:Number = 40; 
			var satelliteRadius:Number = 6; 
			var container:Sprite = new Sprite(); 
			container.x = stage.stageWidth / 2;
			container.y = stage.stageHeight / 2;
			addChild(container); 
			var satellite:Shape = new Shape(); 
			
			container.addChild(satellite);
			addEventListener(Event.ENTER_FRAME, doEveryFrame); 
			
			function doEveryFrame(event:Event):void { 
				currentDegrees += 4; 
				var radians:Number = getRadians(currentDegrees);
				var posX:Number = Math.sin(radians) * radius; 
				var posY:Number = Math.cos(radians) * radius; 
				satellite.graphics.clear(); 
				satellite.graphics.beginFill(0); 
				satellite.graphics.drawCircle(posX, posY, satelliteRadius); 
			} 
			
			function getRadians(degrees:Number):Number { 
				return degrees * Math.PI / 180;
			}
 
		}

	}
	
}
