package {

  import flash.events.Event;
  import flash.display.MovieClip;
  import flash.display.Sprite;
  import flash.events.MouseEvent;
  import flash.geom.Point;
  import caurina.transitions.Tweener;
  import caurina.transitions.properties.FilterShortcuts;

  /**
   *  piece
   *  @author Hideaki Tanabe
   */
  public class Piece extends MovieClip {

    public static const MIN_WIDTH:uint = 16;
    public static const MIN_HEIGHT:uint = 16;
    public static const WIDTH:uint = 20;
    public static const HEIGHT:uint = 20;
    public var color:int = -1;//-1..4
    public var point:Point;
    public var rect:Sprite;
    public var searched:Boolean = false;
    //blue, green, yellow, red, purple
    public static const COLORS:Array = [0x4169e1, 0x3cb371, 0xffd700, 0xb22222, 0x9400d3];

    /**
     *  constructor
     */
    public function Piece(color) {
      stage ? initialize() : addEventListener(Event.ADDED_TO_STAGE, initialize);
      this.color = color;
    }

    /**
     *  initialize
     *  @param event イベント
     */
    private function initialize(event:Event = null):void {
      FilterShortcuts.init();
      removeEventListener(Event.ADDED_TO_STAGE, initialize);
      if (this.color > -1) {
        render();
        initEvent();
      }
    }

    /**
     *  render
     */
    private function render():void {

      graphics.beginFill(0x000000, 0);
      graphics.drawRect(0, 0, WIDTH, HEIGHT);

      rect = new Sprite();
      var innerRect = new Sprite();
      innerRect.graphics.beginFill(COLORS[color]);
      innerRect.graphics.drawRect(0, 0, MIN_WIDTH, MIN_HEIGHT);
      innerRect.x = -(WIDTH - MIN_WIDTH) * 2;
      innerRect.y = -(HEIGHT - MIN_HEIGHT) * 2;
      rect.x = (WIDTH - MIN_WIDTH) * 2;
      rect.y = (HEIGHT - MIN_HEIGHT) * 2;
      rect.addChild(innerRect);
      addChild(rect);
    }

    /**
     *  initialize events
     */
    private function initEvent():void {
      buttonMode = true;
      addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
      addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
    }

    /**
     *  mouse over handler
     *  @param event mouse event
     */
    private function mouseOverHandler(event:MouseEvent):void {
      //activate();
    }

    /**
     *  mouse over handler
     *  @param event mouse event
     */
    private function mouseOutHandler(event:MouseEvent):void {
      //normalize();
    }

    /**
     *  set active state
     */
    public function activate():void {
      if (color > -1) {
        Tweener.addTween(rect, {width: 10, height: 10, time: 0.3});
      }
    }

    /**
     *  set normal state
     */
    public function normalize():void {
      if (color > -1) {
        Tweener.addTween(rect, {width: MIN_WIDTH, height: MIN_HEIGHT, time: 0.3});
      }
    }

    /**
     *  disable this piece
     */
    public function disable():void {
      visible = false;
      color = -1;
      //Tweener.addTween(rect, {width: 0, height: 0, time: 0.3, onComplete: function():void {
      //  visible = false;
      //}});
    }

  }
}
