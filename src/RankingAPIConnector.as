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

    public var SEND_API_URL:String = "";
    public var RANKING_API_URL:String = "";

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
      urlLoader.addEventListener(Event.COMPLETE, urlLoaderSendCompleteHandler);
      urlLoader.load(request);
    }

    /**
     *  url loader send score complete handler
     *  @param event event
     */
    private function urlLoaderSendCompleteHandler(event:Event):void {
      dispatchEvent(new RankingAPIConnectorEvent(RankingAPIConnectorEvent.SEND_COMPLETE));
    }

    /**
     *  get ranking
     */
    public function getRanking():void {
      var urlLoader:URLLoader = new URLLoader();
      var request:URLRequest = new URLRequest(RANKING_API_URL);
      var variable:URLVariables = new URLVariables();
      variable.gameName = GAME_NAME;
      request.method = URLRequestMethod.POST;
      request.data = variable;

      urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
      urlLoader.addEventListener(Event.COMPLETE, urlLoaderGetRankingCompleteHandler);
      urlLoader.load(request);
    }

    /**
     *  url loader get ranking complete handler
     *  @param event event
     */
    private function urlLoaderGetRankingCompleteHandler(event:Event):void {
      var connectorEvent:RankingAPIConnectorEvent = new RankingAPIConnectorEvent(RankingAPIConnectorEvent.GET_RANKING_COMPLETE); 
      connectorEvent.result = XML(event.currentTarget.data);
      dispatchEvent(connectorEvent);
    }

  }
}
