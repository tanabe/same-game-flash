package {

  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.display.MovieClip;
  import flash.display.Sprite;
  import flash.geom.Point;
  import Piece;
  import caurina.transitions.Tweener;

  /**
   *  same-game
   *  @author Hideaki Tanabe
   *  This code is under the MIT license
   */
  public class SameGame extends MovieClip {

    private static const GRID_ROW:uint = 10;//yoko
    private static const GRID_COLMN:uint = 10;//tate
    private static const GRID_MARGIN:uint = 4;
    private var pieces:Array;//map of pieces[x][y]
    private var pieceContainer:Sprite;

    private var removablePieces:Array = [];

    /**
     *  constructor
     */
    public function SameGame() {
      stage ? initialize() : addEventListener(Event.ADDED_TO_STAGE, initialize);
    }

    /**
     *  initialize
     *  @param event event
     */
    private function initialize(event:Event = null):void {
      removeEventListener(Event.ADDED_TO_STAGE, initialize);
      resetPieces();
      createPieceContainer();
      render();
    }

    /**
     *  create piece container
     */
    private function createPieceContainer():void {
      var containerWidth:uint = GRID_ROW * Piece.WIDTH + GRID_MARGIN;
      var containerHeight:uint = GRID_COLMN * Piece.HEIGHT + GRID_MARGIN;
      pieceContainer = new Sprite();
      pieceContainer.graphics.beginFill(0x000000);
      pieceContainer.graphics.drawRect(0, 0, containerWidth, containerHeight);
      addChild(pieceContainer);
    }

    /**
     *  reset pieces
     */
    private function resetPieces():void {
      pieces = [];
      for (var i:uint = 0; i < GRID_ROW; i++) {
        pieces[i] = [];
        for (var j:uint = 0; j < GRID_COLMN; j++) {
          //var color:int = ((Math.random() * (Piece.COLORS.length + 1)) >> 0) - 1;//for debug
          var color:int = (Math.random() * (Piece.COLORS.length)) >> 0;
          var piece:Piece = new Piece(color);
          piece.addEventListener(MouseEvent.MOUSE_OVER, pieceMouseOverHandler);
          piece.addEventListener(MouseEvent.MOUSE_OUT, pieceMouseOutHandler);
          piece.addEventListener(MouseEvent.CLICK, pieceClickHandler);
          piece.point = new Point(i, j);
          pieces[i][j] = piece;
        }
      }
    }

    /**
     *  remap
     */
    private function updatePieces():void {
      var i:int;
      var j:int;

      //drop
      for (i = 0; i < GRID_ROW; i++) {
        var colorPieces:Array = [];
        var blankPieces:Array = [];
        for (j = 0; j < GRID_COLMN; j++) {
          if (pieces[i][j].color > -1) {
            colorPieces.push(pieces[i][j]);
          } else {
            blankPieces.push(pieces[i][j]);
          }
        }

        var column:Array = blankPieces.concat(colorPieces);
        for (j = GRID_COLMN - 1; j >= 0; j--) {
          pieces[i][j] = column[j];
        }
      }

      //shift left
      var blankRows:Array = [];
      var notBlankRows:Array = [];
      for (i = 0; i < GRID_ROW; i++) {
        if (pieces[i][GRID_COLMN - 1].color === -1) {
          blankRows.push(pieces[i]);
        } else {
          notBlankRows.push(pieces[i]);
        }
      }
      var rows:Array = notBlankRows.concat(blankRows);
      for (i = 0; i < GRID_ROW; i++) {
        pieces[i] = rows[i];
      }

      for (i = 0; i < GRID_ROW; i++) {
        for (j = 0; j < GRID_COLMN; j++) {
          pieces[i][j].point = new Point(i, j);
        }
      }

    }

    /**
     *  piece click handler
     *  @param event event
     */
    private function pieceClickHandler(event:MouseEvent):void {
      if (removablePieces.length > 1) {
        for each (var piece in removablePieces) {
          piece.disable();
        }
        updatePieces();
        render();
      }
    }

    /**
     *  piece mouse out handler
     *  @param event event
     */
    private function pieceMouseOutHandler(event:MouseEvent):void {
      if (removablePieces.length > 0) {
        for each (var piece in removablePieces) {
          piece.normalize();
        }
      }
    }

    /**
     *  piece mouse over handler
     *  @param event event
     */
    private function pieceMouseOverHandler(event:MouseEvent):void {
      hilightRemovablePieces(event.currentTarget.point);
    }

    /**
     *  hilight removable pieces
     *  @param point target
     */
    private function hilightRemovablePieces(point:Point):void {
      removablePieces = [];

      for (var i:uint = 0; i < GRID_ROW; i++) {
        for (var j:uint = 0; j < GRID_COLMN; j++) {
          pieces[i][j].searched = false;
        }
      }

      var targetPiece:Piece = pieces[point.x][point.y];
      targetPiece.searched = true;
      removablePieces.push(targetPiece);
      searchRemovablePieces(point, targetPiece.color); 

      if (removablePieces.length > 1) {
        for each (var piece in removablePieces) {
          piece.activate();
        }
      }
    }

    /**
     *  search removable piece
     *  @param point target
     */
    private function searchRemovablePieces(point:Point, color:int):void {
      var right:Piece = (point.x < GRID_ROW - 1) ? pieces[point.x + 1][point.y] : null;
      var left:Piece = (point.x > 0) ? pieces[point.x - 1][point.y] : null;
      var top:Piece = (point.y > 0) ? pieces[point.x][point.y - 1] : null;
      var bottom:Piece = (point.y < GRID_COLMN - 1) ? pieces[point.x][point.y + 1] : null;

      var targets:Array = [top, right, left, bottom];
      for each (var piece:Piece in targets) {
        //searchable
        if (piece && !piece.searched) {
          if (piece.color === color) {
            removablePieces.push(piece);
            piece.searched = true;
            searchRemovablePieces(piece.point, color);
          }
        }
      }
    }

    /**
     *  render
     */
    private function render():void {
      while (pieceContainer.numChildren > 0) {
        pieceContainer.removeChildAt(0);
      }
      for (var i:uint = 0; i < GRID_ROW; i++) {
        for (var j:uint = 0; j < GRID_COLMN; j++) {
          var piece:Piece = pieces[i][j];
          piece.x = Piece.WIDTH * i + GRID_MARGIN;
          piece.y = Piece.WIDTH * j + GRID_MARGIN;
          pieceContainer.addChild(piece);
        }
      }
    }
  }

}
