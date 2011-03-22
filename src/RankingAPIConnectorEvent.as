package {

  import flash.events.Event;

  /**
   *
   *  @author Hideaki Tanabe
   */
  public class RankingAPIConnectorEvent extends Event {

    public static const SEND_COMPLETE:String = "sendComplete";
    public static const GET_RANKING_COMPLETE:String = "getRankingComplete";

    /**
     *  コンストラクタ
     *  @param type イベントタイプ
     */
    public function RankingAPIConnectorEvent(type:String) {
      super(type);
    }
  }
}
