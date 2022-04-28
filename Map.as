package  {

	import flash.display.*; 
	import flash.events.*; 
	import flash.text.*;
	import flash.geom.*;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.utils.*;
	import flash.xml.XMLDocument;
	import flashx.textLayout.formats.Float;
	
	public class Map extends Sprite {
		public static const BRICK = 0;
		public static const GLASS = 1;
		public static const WOOD = 2;
		public static const METAL = 3;
		
		public static const FADING = 3;
		public static const COLOR = 2;
		
		// затухание сигнала в материалах (Db)
		public static const MATERIAL = [[BRICK,"Кирпич", 0xCC1111, 7],
										[GLASS,"Стекло", 0x0011AA, 2],
										[METAL,"Метал", 0xCCCCCC, 12],
										[WOOD,"Дерево", 0x550000, 4]
										]
		
		var screenW:Number = 700; // ширина поля экрана для отображения карты
		var screenH:Number = 500; // высота поля экрана для отображения карты
		
		var scale:Number = 0.01;		// масштаб отображения карты в процентах
		var resolution:Number = 100; 		// разрешение карты (пиксели на метр)
		var W:Number = 10;		// ширина карты (метры)
		var H:Number = 10;		// высота карты (метры)
		var X:Number = 0;
		var Y:Number = 0;
		var objList:Array; 		// преграды
		var APList:Array; 		// точки доступа
		var rcvList:Array; 		// клиенты
		
	
		public function Map(W=70, H=50) {
			// constructor code
			this.objList = new Array();
			this.APList = new Array();
			this.rcvList = new Array();
			
			this.W = W;
			this.H = H;
			
			var s:Sprite = new Sprite();
			s.x=100;
			s.y=100;
			s.width = this.screenW; 
			s.height = this.screenH;

			var sW:Number = this.screenW / (this.W * this.resolution);
			var sH:Number = this.screenH / (this.H * this.resolution);
			
			if (sW < sH) this.scale = sW else this.scale = sH;
			//trace("sW="+sW +"sH="+ sH);
			
			// Создание объекта TextField 
			var t:TextField = new TextField( ); 
			t.text = "Click here"; 
			t.background = true; 
			t.border = true; 
			t.autoSize = TextFieldAutoSize.LEFT; 
			// Помещение объекта TextField в объект Sprite 
			s.addChild(t); 
			// Добавляем объект Sprite в иерархию отображения данного объекта 
			addChild(s); 
			// Регистрируем приемник для получения уведомлений об установке 
			// фокуса ввода на любой из потомков объекта Sprite (в данном случае 
			// существует только один потомок: объект TextField. t) 
			s.addEventListener(FocusEvent.FOCUS_IN, focusInListener); 
		
			//createAP("First AP", 15, 2, 5, 5);
			//createRcv("Client 1", 4, 2, 2);
			//createObj("Wall 1", BRICK, 1, 1, 2, 1);
		}

		// Приемник выполняется в том случае, когда любой из потомков объекта 
		// Sprite получает фокус ввода 
		public function focusInListener (e:FocusEvent):void { 
			// Выводит: Target of this event dispatch: [object TextField] 
			trace("Target of this event dispatch: " + e.target); 
			// Устанавливает красный цвет для фона текстового поля. Обратите 
			// внимание, что для обеспечения безопасности типов мы приводим 
			// значение переменной Event.target к типу TextField - фактическому 
			// типу данных объекта получателя. 
			TextField(e.target).backgroundColor = 0xFF0000; 
		}


		public function loadFromXML(xml='') 
		{
			// code
			var mFileReference:FileReference = new FileReference();
			mFileReference.addEventListener(Event.SELECT, onFileSelected);
			var swfTypeFilter:FileFilter = new FileFilter("XML Files","*.xml");
			var allTypeFilter:FileFilter = new FileFilter("All Files (*.*)","*.*");
			mFileReference.browse([swfTypeFilter, allTypeFilter]);
	
			// This function is called after user selected a file in the file browser dialog.
			function onFileSelected(event:Event):void
			{
				trace("onFileSelected");
				// This callback will be called when the file is uploaded and ready to use
				mFileReference.addEventListener(Event.COMPLETE, onFileLoaded);
	
				// This callback will be called if there's error during uploading
				mFileReference.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
	
				// Optional callback to track progress of uploading
				mFileReference.addEventListener(ProgressEvent.PROGRESS, onProgress);
	
				// Tells the FileReference to load the file
				mFileReference.load();
	
			}

			// This function is called to notify us of the uploading progress
			function onProgress(event:ProgressEvent):void
			{
				var percentLoaded:Number=event.bytesLoaded/event.bytesTotal*100;
				trace("loaded: "+percentLoaded+"%");
			}

			// This function is called after the file has been uploaded.
			function onFileLoaded(event:Event):void
			{
				var fileReference:FileReference=event.target as FileReference;
				var data:ByteArray=fileReference["data"];
				var xml:XML = new XML(data.toString());
				mFileReference.removeEventListener(Event.COMPLETE, onFileLoaded);
				mFileReference.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
				mFileReference.removeEventListener(ProgressEvent.PROGRESS, onProgress);	
				
				scale = xml.scale;
				resolution = xml.resolution;
				W = xml.w;
				H = xml.h;
				X = xml.x;
				Y = xml.y;
				
				for (var r:int = 0; r < rcvList.length; r++) 
					removeChild(rcvList[r]);

				for (var a:int = 0; a < APList.length; a++)
					removeChild(APList[a]);
				
				for (var b:int = 0; b < objList.length; b++)
					removeChild(objList[b]);

				objList = [];
				APList = [];
				rcvList = [];
				
				for each (var item:XML in xml.receiver)
				{
					createRcv(item.name, item.antGain, item.x, item.y, item.antType, item.sensitivity, item.reqSpeed);
				}

				for each (var item:XML in xml.ap)
				{
					createAP(item.name, item.power, item.antGain, item.x, item.y, item.maxSpeed);
				}
				
				for each (var item:XML in xml.obj)
				{
					createObj(item.name, item.material, item.x1, item.y1, item.x2, item.y2);
				}
				

				//trace(xml.ap.(@id=="0").name);
			}

			function onFileLoadError(event:Event):void
			{
				mFileReference.removeEventListener(Event.COMPLETE, onFileLoaded);
				mFileReference.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
				trace("File load error");
			} 
		}
		
		public function saveToXML() {
			// Сохранение карты на диске в виде XML-документа
			
			var file:FileReference = new FileReference();
			
			var xml:XML =  new XML(<map></map>);
			xml.w = W;
			xml.h = H;
			xml.x = X;
			xml.y = Y;
			xml.scale = scale;
			xml.resolution = resolution;
			
			// Клиенты
			for (var r:int = 0; r < this.rcvList.length; r++) {
				var rcv:XML = <receiver></receiver>;
				rcv.@id = r;
				rcv.x = rcvList[r].X;						// позиция X м
				rcv.y = rcvList[r].Y;						// позиция Y м
				rcv.name = rcvList[r].rcvName;				// наименование точки
				rcv.antType = rcvList[r].antType;			// тип антенны (круговая, секторная)
				rcv.antGain = rcvList[r].antGain;			// усиление антенны Db
				rcv.sensitivity = rcvList[r].sensitivity;	// чувствительность приемника Dbi
				rcv.reqSpeed = rcvList[r].reqSpeed;			// необходимая мин скорость Мбит
				
				xml.appendChild(rcv);				
			}
			
			// Точки доступа
			for (var a:int = 0; a < this.APList.length; a++) {
				var ap:XML = <ap></ap>;
				ap.@id = a;
				ap.x=APList[a].X;						// позиция X м
				ap.y=APList[a].Y;						// позиция Y м
				ap.name = APList[a].APName;				// наименование точки
				ap.power = APList[a].power;				// мощность передатчика
				ap.antGain = APList[a].antGain;			// усиление антенны Db
				ap.maxSpeed = APList[a].maxSpeed;			// макс скорость Мбит
				
				xml.appendChild(ap);
			}


			// Преграды
			for (var b:int = 0; b < this.objList.length; b++) {
				var obj:XML = <obj></obj>;
				obj.@id = b;
				obj.x1=objList[b].X1;						// точка X1 м
				obj.y1=objList[b].Y1;						// точка Y1 м
				obj.x2=objList[b].X2;						// точка X2 м
				obj.y2=objList[b].Y2;						// точка Y2 м
				obj.name = objList[b].objName;				// наименование преграды
				obj.material = objList[b].material;				// материал преграды
				
				xml.appendChild(obj);
			}

			file.save(decodeStringToWIN(xml),"map.xml");
		}
		
		
		public function isBarrier(ap, rcv, obj) {
			var s = false;
			//прямая (ap.X, ap.Y) - (rcv.X, rcv.Y) пересекает ли прямоуг. (obj.X1, obj.Y1, obj.X2, obj.Y2)
			if (intersection(ap.X, ap.Y, rcv.X, rcv.Y, obj.X1, obj.Y1, obj.X2, obj.Y1)) s = true
				else if (intersection(ap.X, ap.Y, rcv.X, rcv.Y, obj.X1, obj.Y1, obj.X1, obj.Y2)) s = true
					else if (intersection(ap.X, ap.Y, rcv.X, rcv.Y, obj.X2, obj.Y2, obj.X1, obj.Y2)) s = true
						else if (intersection(ap.X, ap.Y, rcv.X, rcv.Y, obj.X2, obj.Y2, obj.X2, obj.Y1)) s = true;
			return s;
		}
		
		public function intersection(start1x, start1y, end1x, end1y, start2x, start2y, end2x, end2y:Number){
        	//прямая (ap.X, ap.Y) - (rcv.X, rcv.Y) пересекает ли прямоуг. (obj.X1, obj.Y1, obj.X2, obj.Y2)
			var a1,b1,d1,a2,b2,d2,u:Number;
			var seg1_line2_start, seg1_line2_end:Number;
			var seg2_line1_start, seg2_line1_end:Number;
			
			var start1 = new Point(start1x, start1y);
			var end1 = new Point(end1x, end1y);
			var start2 = new Point(start2x, start2y);
			var end2 = new Point(end2x, end2y);
			
			var dir1 = new Point(end1.x, end1.y);
			dir1.x = dir1.x - start1.x //dir1.subtruct(start1);
			dir1.y = dir1.y - start1.y
			
			var dir2 = new Point(end2.x, end2.y);
			dir2.x = dir2.x - start2.x 
			dir2.y = dir2.y - start2.y //dir2.subtruct(start2);
        	


        	//считаем уравнения прямых проходящих через отрезки
        	a1 = -dir1.y;
        	b1 = +dir1.x;
        	d1 = -(a1*start1.x + b1*start1.y);

        	a2 = -dir2.y;
        	b2 = +dir2.x;
        	d2 = -(a2*start2.x + b2*start2.y);

        	//подставляем концы отрезков, для выяснения в каких полуплоскотях они
        	seg1_line2_start = a2*start1.x + b2*start1.y + d2;
        	seg1_line2_end = a2*end1.x + b2*end1.y + d2;

        	seg2_line1_start = a1*start2.x + b1*start2.y + d1;
        	seg2_line1_end = a1*end2.x + b1*end2.y + d1;

        	//если концы одного отрезка имеют один знак, значит он в одной полуплоскости и пересечения нет.
        	if (seg1_line2_start * seg1_line2_end >= 0 || seg2_line1_start * seg2_line1_end >= 0) 
            	return false;

        	u = seg1_line2_start / (seg1_line2_start - seg1_line2_end);
        	//*out_intersection =  start1 + u*dir1;

        	return true;
    	}
		
		

		public function calculate() {
			var file:FileReference = new FileReference();
			var txt:String="Calculate\n";
			const SOM = 10;
			var FSL:Number = 0;
			var signal:Number = 0;
			var fading:Number = 0;
			var distance:Number = 0;
			var speed:int = 0;
			
			for (var r:int = 0; r < this.rcvList.length; r++) {
				this.rcvList[r].signal = [];
				trace("Клиент: " + this.rcvList[r].rcvName);
				txt = txt + "\n\n" + "Клиент: " + this.rcvList[r].rcvName + "\n-----------------------------------";
				
				for (var i:int = 0; i < this.APList.length; i++) {
					
					// дистанция между ТД и Клиентом (метры)
					distance = Math.sqrt(Math.pow(this.rcvList[r].X - this.APList[i].X, 2)	
										 + Math.pow(this.rcvList[r].Y - this.APList[i].Y, 2)) 
					
					// суммарное затухание сигнала в преградах(Db)
					for (var o:int = 0; o < this.objList.length; o++) {
						if (isBarrier(this.APList[i], this.rcvList[r], this.objList[o])) {	// находится ли преграда на пути сигнала
							fading =+ MATERIAL[this.objList[o].material][FADING]	// 
						} 
					}
					
					// расчет сигнала (Dbm)
					// FSL = мощн_перед(Db) + усил_ант1(Db) + усил_ант2(Db) - чувств_приемн(Dbm) - преграды(Db)
					// FSL = 2 * расст(км) - 100.8
					// FSL = this.APList[i].power + this.APList[i].antGain + this.rcvList[r].antGain - fading
					signal = this.APList[i].power + this.APList[i].antGain + this.rcvList[r].antGain - fading - (2 * distance/1000) - 100.8 ;
					
					// расчет скорости
					if (signal < this.rcvList[r].sensitivity) {	
						speed = 0;
					}
					else if (signal < - 90) {
						speed = 2;
					}
					else if (signal < -87) {
						speed = 6;
					}
					else if (signal < -86) {
						speed = 9;
					}
					else if (signal < -85) {
						speed = 12;
					}
					else if (signal < -83) {
						speed = 18;
					}
					else if (signal < -80) {
						speed = 24;
					}
					else if (signal < -76) {
						speed = 36;
					}
					else if (signal < -71) {
						speed = 48;
					}
					else if (signal < -66) {
						speed = 54;
					}
					else {
						speed = 54;
					}
					
					
					// добавление в таблицу инф о сигнале от ТД
					this.rcvList[r].signal.push([this.APList[i], distance, signal, speed])
					trace([this.APList[i].APName, distance, signal, speed])
					
					txt = txt + "\n" + 
					"Точка доступа: " + this.APList[i].APName + "; " +
					"Расстояние:" + distance.toFixed(2) + "m; " +
					"Сигнал:" + signal.toFixed(2) + "db; " +
					"Скорость:" +  speed + "Mbps";
					
				}
				
			} 
			
			//запись результатов рассчета в файл					
			file.save(decodeStringToWIN(txt),"Calculate.txt"); // Initiates the save event and opens up a dialog box for user to enter filename and select a location. Once confirmed, it get saved
			//file.save(txt,"Calculate.txt"); // Initiates the save event and opens up a dialog box for user to enter filename and select a location. Once confirmed, it get saved

		}
	
		public function decodeStringToUTF(s:String):String {
			var ba:ByteArray = new ByteArray();
			ba.writeMultiByte(s, "windows-1251");
			ba.position = 0;
			return ba.readMultiByte(ba.length, "utf-8");
		}	

		public function decodeStringToWIN(s:String):String {
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(s);
			ba.position = 0;
			//return ba.readMultiByte(ba.length, "windows-1251");
			return ba.toString();
		}	
	
		public function createObj(objName="wall", material=0, X1=1, Y1=1, X2=1.5, Y2=1.5) {
			var newObj = new Barrier(this, objName, material, X1, Y1, X2, Y2);
			this.objList.push(newObj);
			addChild(newObj);
			trace("Create Barrier N" + this.objList.length + ":" + objName);
		}

		public function createAP(APName="AP", power=17, antGain=4, X=2, Y=3, maxSpeed=54) {
			var newAP = new AccessPoint(this, APName, power, antGain, X, Y, maxSpeed);
			this.APList.push(newAP);
			addChild(newAP);
			trace("Create AP N" + this.APList.length + ":" + APName);
		}

		public function createRcv(rcvName="Client", antGain=3, X=1, Y=3, antType=0, sensitivity=-96, reqSpeed=2) {
			var newRcv = new Reciever(this, rcvName, antGain, X, Y, antType, sensitivity, reqSpeed);
			this.rcvList.push(newRcv);
			addChild(newRcv);
			trace("Create Client N" + this.rcvList.length + ":" + rcvName);
		}

		public function resizeObj(obj) {
			// code
		}
		
		public function dragObj(obj) {
			// code
		}
	}
	
}
