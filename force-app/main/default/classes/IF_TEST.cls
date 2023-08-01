public with sharing class IF_TEST {
    public IF_TEST() {


        
        Map<String, String> pMap = new Map<String, String>{
            'BatchClass' => 'Text/255/Batch Class',
'CalloutClass' => 'Text/255/Callout Class',
'ClassName' => 'Text/255/Class Name',
'ContentType' => 'Text/255/Content Type',
'Cycle' => 'Text/50/Cycle',
'deleteDays' => 'Date/200/deleteDays',
'Description' => 'Text/255/Description',
'DummyObject' => 'Text/255/DummyObject',
'EndPoint' => 'Text/255/EndPoint',
'ExampleBody' => 'LongTextArea/131072/Example Body',
'ExecuteCode' => 'LongTextArea/131072/Execute code',
'Header' => 'Text/255/Header',
'howmonth' => 'Text/255/howmonth',
'Interval' => 'Text/255/Interval',
'IsRealLogInsert' => 'Checkbox//Is Real Log Insert',
'isActive' => 'Checkbox//IsActive',
'LogArchiveDays' => 'Number/18/Log Archive Days',
'Manager' => 'Text/255/Manager',
'Method' => 'Text/255/Method',
'Object' => 'Text/100/Object',
'Param2' => 'LongTextArea/131072/Param2',
'Param3' => 'LongTextArea/131072/Param3',
'Param4' => 'LongTextArea/131072/Param4',
'ProgramNum' => 'Text/255/Program No.',
'TargetSystem' => 'Text/255/TargetSystem',
'WebServiceType' => 'Text/255/WebServiceType',
'DataCheckCriticalValue' => 'Number/18/데이터 체크 기준 수량',
'DataCheck' => 'Checkbox//데이터 체크 수행 여부',
'IFObject' => 'Text/255/데이터 체크 오브젝트',
'DataCheckQuery' => 'LongTextArea/131072/데이터 체크 쿼리',
'ExeInterval' => 'Number/10/모니터링 간격',
'MonitoringTargetYn' => 'Checkbox//모니터링 대상여부',
'RealtimeIfMonParam' => 'LongTextArea/131072/모니터링 파라메터',
'DataCheckInterval' => 'Number/18/수신 데이터 비교 시간 간격',
'LastDataChekDttm' => 'Date//수신 데이터 체크 시간',
'RealtimeIfMonTargetYn' => 'Checkbox//실시간IF모니터링대상',
'AlamRecverList' => 'Text/255/알람수신자 리스트',
'IfResponseDataSaveYn' => 'Checkbox//인터페이스데이터저장여부',
'LastExecChekDttm' => 'Date//프로그램 실행 체크 시간',
'HolidayCheckYN' => 'Checkbox//휴일수행여부'
        };

        UTIL_CreateObject.setVisibility('IF_Program',pMap); // 권한주는거
                
        UTIL_CreateObject.dynamicCreation('IF_Program','Text','{YYYY}{MM}-{00000000}','No','인터페이스 관련정보 (endpoint 등 관리)',pMap,'N'); // 테이블 만들기

        UTIL_CreateObject.setVisibility('IF_Program',pMap); // 권한주는거


    }



    public void testIf() {
        
    }
}