package {

  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.net.URLLoader;
  import flash.net.URLVariables;
  import flash.net.URLRequest;
  import flash.net.URLRequestMethod;
  import flash.net.URLLoaderDataFormat;
  import com.adobe.crypto.MD5;
  import RankingAPIConnectorEvent;

  /**
   *  API connector
   *  @author Hideaki Tanabe
   */
  public class RankingAPIConnector extends EventDispatcher {

    private static const GAME_NAME:String = "samegame";
    private static const SECRET:String = "hogehoge";
    private static const SEND_API_URL:String = "http://localhost/ranking/ranking.php?action=add";
    private static const RANKING_API_URL:String = "http://localhost/ranking/ranking.php?action=ranking";

    /**
     *  constructor
     */
    public function RankingAPIConnector() {
    }

    /**
     *  send score
     *  @param userName user name
     *  @param score score
     */
    public function sendScore(userName:String, score:uint):void {
      var urlLoader:URLLoader = new URLLoader();
      var request:URLRequest = new URLRequest(SEND_API_URL);
      var variable:URLVariables = new URLVariables();
      variable.gameName = GAME_NAME;
      variable.userName = userName;
      variable.score = score;
      variable.token = MD5.hash(GAME_NAME + userName + score + SECRET);
      request.method = URLRequestMethod.POST;
      request.data = variable;

      urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
      urlLoader.addEventListener(Event.COMPLETE, urlLoaderCompleteHandler);
      urlLoader.load(request);
    }

    /**
     *  url loader complete handler
     *  @param event event
     */
    private function urlLoaderCompleteHandler(event:Event):void {
      dispatchEvent(new RankingAPIConnectorEvent(RankingAPIConnectorEvent.SEND_COMPLETE));
    }

    /**
     *  get ranking
     */
    public function getRanking():void {
    }

  }
}
