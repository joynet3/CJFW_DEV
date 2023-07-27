/**
* 알림 보내는 interface
*
*@group  Notification
*@author 진현욱
*@since 2023-07-24  생성
*/
public interface NotiAlert {
    void send(List<NotiTemplate> sendData);
}