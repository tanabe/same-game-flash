package {

  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.display.MovieClip;
  import flash.display.Sprite;
  import flash.geom.Point;
  import flash.text.TextFieldAutoSize;
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
    private static const BASE_BONUS:uint = 2000;
    private var pieces:Array;//map of pieces[x][y]
    private var pieceContainer:Sprite;
    private var removablePieces:Array = [];
    private var isBusy:Boolean = false;
    private var score:uint = 0;
    private var progressScore:uint = 0;

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
      score = 0;
      initScoreAsset();
      resetPieces();
      createPieceContainer();
      render();
    }

    /**
     *  update score view
     */
    private function updateScore():void {
      var scoreObject:Object = {};
      scoreObject.score = scoreAsset.score.text;
      Tweener.addTween(scoreObject, {score: score, time: 0.5, transition: "easeInExpo", 
        onUpdate: function():void {
          scoreAsset.score.text = Math.floor(scoreObject.score);
        },
        onComplete: function():void {
          scoreAsset.score.text = score;
        }
      });
    }

    /**
     *  initialize score asset
     */
    private function initScoreAsset():void {
      scoreAsset.score.autoSize = TextFieldAutoSize.CENTER;
      //scoreAsset.addEventListener(Event.ENTER_FRAME, scoreAssetEnterFrameHandler);
    }

    /**
     *  score asset enter frame handler
     *  @param event event
     */
    private function scoreAssetEnterFrameHandler(event:Event):void {
      //if (progressScore < score) {
      //  progressScore++;
      //  scoreAsset.score.text = progressScore;
      //}
    }

    /**
     *  create piece container
     */
    private function createPieceContainer():void {
      var containerWidth:uint = GRID_ROW * Piece.WIDTH + GRID_MARGIN;
      var containerHeight:uint = GRID_COLMN * Piece.HEIGHT + GRID_MARGIN;
      pieceContainer = new Sprite();
      pieceContainer.y = 85;
      pieceContainer.x = 5;
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
     *  move pieces
     */
    private function updatePieces():void {
      isBusy = true;
      //drop and shift
      dropPieces();
    }

    /**
     *  drop pieces
     */
    private function dropPieces():void {
      var i:int;
      var j:int;

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

      //update point
      var count:uint = 0;
      for (i = 0; i < GRID_ROW; i++) {
        for (j = 0; j < GRID_COLMN; j++) {
          var piece:Piece = pieces[i][j];
          var nextY:uint = Piece.HEIGHT * j + GRID_MARGIN;
          //animation
          Tweener.addTween(piece, {y: nextY, time: 0.3, onComplete: function():void {
            count++;
            //complete
            if (count >= GRID_ROW * GRID_COLMN) {
              //render and shift to left
              render();
              shiftPieces();
            }
          }});
          pieces[i][j].point = new Point(i, j);
        }
      }
    }

    /**
     *  shift to blank column
     */
    private function shiftPieces():void {
      //trace("shift");
      var i:int;
      var j:int;
      var piece:Piece;
      var blankRows:Array = [];
      var notBlankRows:Array = [];

      for (i = 0; i < GRID_ROW; i++) {
        if (pieces[i][GRID_COLMN - 1].color === -1) {
          blankRows.push(pieces[i]);
        } else {
          notBlankRows.push(pieces[i]);
        }
      }

      //exists blank rows
      if (blankRows.length > 0) {
        var rows:Array = notBlankRows.concat(blankRows);
        for (i = 0; i < GRID_ROW; i++) {
          pieces[i] = rows[i];
        }

        //update point
        var count:uint = 0;
        for (i = 0; i < GRID_ROW; i++) {
          for (j = 0; j < GRID_COLMN; j++) {
            piece = pieces[i][j];
            var nextX:uint = Piece.WIDTH * i + GRID_MARGIN;
            //animation
            Tweener.addTween(piece, {x: nextX, time: 0.3, onComplete: function():void {
              count++;
              //complete
              if (count >= GRID_ROW * GRID_COLMN) {
                isBusy = false;
                render();
                checkRemovablePiecesExists();
              }
            }});
            piece.point = new Point(i, j);
          }
        }
      //not exists blank rows
      } else {
        isBusy = false;
        for (i = 0; i < GRID_ROW; i++) {
          for (j = 0; j < GRID_COLMN; j++) {
            piece = pieces[i][j];
            piece.point = new Point(i, j);
          }
        }
        render();
        checkRemovablePiecesExists();
      }

    }

    /**
     *  piece click handler
     *  @param event event
     */
    private function pieceClickHandler(event:MouseEvent):void {
      if (!isBusy) {
        createRemovablePieces(event.currentTarget.point);
        if (isExistsRemovablePieces()) {
          for each (var piece in removablePieces) {
            piece.disable();
          }
          updatePieces();
          score += calculateScore(removablePieces.length);
          updateScore();
          //scoreAsset.score.text = score;
        }
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
      for (var i:uint = 0; i < GRID_ROW; i++) {
        for (var j:uint = 0; j < GRID_COLMN; j++) {
          pieces[i][j].normalize();
        }
      }

      hilightRemovablePieces(event.currentTarget.point);
    }

    /**
     *  hilight removable pieces
     *  @param point target
     */
    private function hilightRemovablePieces(point:Point):void {
      createRemovablePieces(point);
      if (isExistsRemovablePieces()) {
        //trace(calculateScore(removablePieces.length));
        for each (var piece in removablePieces) {
          piece.activate();
        }
      }
    }

    /**
     *  create removable pieces list
     *  @param point target
     */
    private function createRemovablePieces(point:Point):void {
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
    }

    /**
     *  search removable piece
     *  @param point target
     *  @param color color
     */
    private function searchRemovablePieces(point:Point, color:int):void {
      var right:Piece = (point.x < GRID_ROW - 1) ? pieces[point.x + 1][point.y] : null;
      var left:Piece = (point.x > 0) ? pieces[point.x - 1][point.y] : null;
      var top:Piece = (point.y > 0) ? pieces[point.x][point.y - 1] : null;
      var bottom:Piece = (point.y < GRID_COLMN - 1) ? pieces[point.x][point.y + 1] : null;

      var targets:Array = [top, right, left, bottom];
      for each (var piece:Piece in targets) {
        //searchable
        if (piece && !piece.searched && (piece.color > -1)) {
          if (piece.color === color) {
            removablePieces.push(piece);
            piece.searched = true;
            searchRemovablePieces(piece.point, color);
          }
        }
      }
    }

    /**
     *  check removable pieces are exists
     */
    private function checkRemovablePiecesExists():void {
      for (var i:uint = 0; i < GRID_ROW; i++) {
        for (var j:uint = 0; j < GRID_COLMN; j++) {
          createRemovablePieces(new Point(i, j));
          if (isExistsRemovablePieces()) {
            removablePieces = [];
            //trace("ok");
            return;
          }
        }
      }
      //trace("ng", removablePieces.length);
      //game over
      trace(calculateBonusScore());
      showGameOver();
    }

    /**
     *  exists removable pieces
     *  @return exists then true
     */
    private function isExistsRemovablePieces():Boolean {
      return (removablePieces.length > 1);
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
          piece.y = Piece.HEIGHT * j + GRID_MARGIN;
          pieceContainer.addChild(piece);
        }
      }
    }

    /**
     *  calculate piece score
     *  @param pieceNum number of pieces
     *  @return score
     */
    private function calculateScore(pieceNum:uint):uint {
      return (5 * pieceNum * pieceNum);
    }

    /**
     *  calculate bonus score
     *  @return bonus score
     */
    private function calculateBonusScore():uint {
      var bonus:int = BASE_BONUS;
      var leftPieceCount:uint = 0;
      for (var i:uint = 0; i < GRID_ROW; i++) {
        for (var j:uint = 0; j < GRID_COLMN; j++) {
          var piece:Piece = pieces[i][j];
          if (piece.color > -1) {
            leftPieceCount++;
          }
        }
      }
      bonus = bonus - (leftPieceCount * leftPieceCount * 10);
      return Math.max(bonus, 0);
    }

    /**
     *  show game over window
     */
    private function showGameOver():void {
    }

    /**
     *  show ranking window
     */
    private function showRanking():void {
    }

    /**
     *  close all windows
     */
    private function closeWindows():void {
    }

  }
}
