trigger daytimeTrigger on ISSUE__c (before insert, before update) {
 
 Datetime withBoth1;
 Datetime withBoth2;
 decimal withBoth;

// for(ISSUE__c s : Trigger.New){
//      // 발생일시,복구일시 모두 입력된 경우
//      if(s.DATE_FROM__C != null && s.TIME_FROM__C != null && s.DATE_TO__C != null && s.TIME_TO__C != null ){
//          system.debug(s.name);
//          withBoth1 = Datetime.newInstance(s.DATE_FROM__C, s.TIME_FROM__C);
//          withBoth2 = Datetime.newInstance(s.DATE_TO__C, s.TIME_TO__C);
//          withBoth = (withBoth2.getTime()/1000/60 - withBoth1.getTime()/1000/60);
//          system.debug('차이(분)' + withBoth);
//          if(withBoth != null ){
//              s.DAY_TIME__c = withBoth;
//          }
//      }
// }
}