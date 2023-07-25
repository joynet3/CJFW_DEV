/************************************************************************************
 * File Name   		: CommonUtil.cls
 * Author	  		: 안태진
 * Date				: 2022-05-25
 * Tester	  		: CommonUtil_test.cls
 * Description 		: 유틸성으로 사용할 수 있는 기능로직들만 여기에 정리
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2022-05-25     tg.ahn          Create
   1.1      2022-08-19     mj.kim          FieldSet의 Field 추출 기능 추가 (getFieldSet(), getFieldSetForAPIName())
*************************************************************************************/
public class CommonUtil {
    /**
     * Field Set 을 이용하여 Dynamic 하게 화면 구성할 시 사용 (Table, 등등)
     * 
     * @param strObjectAPIName : Object Api Name
     * @param strFieldSetAPIName : FieldSet Api Name
     * @return List<Map<String, Object>>
     *         
    **/
    public static List<Map<String, Object>> getFieldSet(String strObjectAPIName, String strFieldSetAPIName) {
        List<Map<String, Object>> listReturnFieldSet = new List<Map<String, Object>>();
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(strObjectAPIName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(strFieldSetAPIName);
        if(fieldSetObj != null) {
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetObj.getFields()) {
                listReturnFieldSet.add(new Map<String, Object>{
                    'apiName' => fieldSetMemberObj.getFieldPath()
                    , 'type' => String.valueOf(fieldSetMemberObj.getType())
                    , 'label' => fieldSetMemberObj.getLabel()
                    , 'required' => fieldSetMemberObj.getRequired()
                });
            }
        } 
        return listReturnFieldSet;
    }
    
    /**
     * Field Set 에 들어있는 Field API 만 가져올시 사용
     * 
     * @param strObjectAPIName : Object Api Name
     * @param strFieldSetAPIName : FieldSet Api Name
     * @return List<String>
     *         
    **/
    public static List<String> getFieldSetForAPIName(String strObjectAPIName, String strFieldSetAPIName) {
        List<String> listReturnFieldSetApi = new List<String>();
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(strObjectAPIName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(strFieldSetAPIName);

        if(fieldSetObj != null) {
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetObj.getFields()) {
                listReturnFieldSetApi.add(fieldSetMemberObj.getFieldPath());
            }
        }
        return listReturnFieldSetApi;
    }
    
    /**
     * Picklist Label, Value 리스트 조회
     * 
     * @param objectType : Object Api Name
     * @param selectedField : Picklist Field Api Name
     * @param isNone : none 추가여부
     * @return List<Map<String, Object>>
     *         
    **/
    public static List<Map<String, String>> getPickListValues(String objectType, String selectedField, Boolean isNone) {
        List<Map<String, String>> pickListValuesList = new List<Map<String, String>>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        if(isNone) {
            pickListValuesList.add(new Map<String, String>{
                    'label' => Label.SelectNone,
                    'value' => 'none'
            });
        }
        
        for(Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.add(new Map<String, String>{
                    'label' => pickListVal.getLabel(),
                    'value' => pickListVal.getValue()
            });
        }
        return pickListValuesList;
    }
    
    /**
     * Picklist Value 리스트 조회
     * 
     * @param objectType : Object Api Name
     * @param selectedField : Picklist Field Api Name     
     * @return Map<String, String> : key(value), value(label)
     *         
    **/
    public static Map<String, String> getMapPickList(String objectType, String selectedField) {
        Map<String, String> mapPicklist = new Map<String, String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple) {
            mapPicklist.put(pickListVal.getValue(), pickListVal.getValue());
        }
        return mapPicklist;
    }

    /**
     * Picklist Value 리스트 조회
     * 
     * @param objectType : Object Api Name
     * @param selectedField : Picklist Field Api Name     
     * @return Map<String, String> : key(value), value(value)
     *         
    **/
    public static Map<String, String> getMapPickListActive(String objectType, String selectedField) {
        Map<String, String> mapPicklist = new Map<String, String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple) {
            if( pickListVal.isActive() == true)
            mapPicklist.put(pickListVal.getValue(), pickListVal.getValue());
        }
        return mapPicklist;
    }
    
    /**
     * Picklist Value Label 조회
     * 
     * @param objectType : Object Api Name
     * @param selectedField : Picklist Field Api Name     
     * @return Map<String, String> : key(value), value(Label)
     *         
    **/
    public static Map<String, String> getMapPickListLabel(String objectType, String selectedField) {
        Map<String, String> mapPicklist = new Map<String, String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple) {
            mapPicklist.put(pickListVal.getValue(), pickListVal.getLabel());
        }
        return mapPicklist;
    }
    
    /**
     * Picklist Label Value 조회(Key : Label, value : value)
     * 
     * @param objectType : Object Api Name
     * @param selectedField : Picklist Field Api Name     
     * @return Map<String, String> : key(label), value(value)
     *         
    **/
    public static Map<String, String> getMapPickListLabeltoValue(String objectType, String selectedField) {
        Map<String, String> mapPicklist = new Map<String, String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple) {
            mapPicklist.put(pickListVal.getLabel(), pickListVal.getValue());
        }
        return mapPicklist;
    }
    
    /**
     * Picklist Label Value 조회(Key : Label, value : value)
     * 
     * @param objectType : Object Api Name
     * @param selectedField : Picklist Field Api Name     
     * @return Map<String, String> : key(value), value(label)
     *         
    **/
    public static Map<String, String> getMapPickListValuetoLabel(String objectType, String selectedField) {
        Map<String, String> mapPicklist = new Map<String, String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple) {
            mapPicklist.put(pickListVal.getValue(), pickListVal.getLabel());
        }
        return mapPicklist;
    }

    public class WrapperPicklistEntry {
        @AuraEnabled public string active {get; set;}
        @AuraEnabled public string defaultValue {get; set;}
        @AuraEnabled public string label {get; set;}
        @AuraEnabled public string value {get; set;}
        @AuraEnabled public string validFor {get; set;}

        public WrapperPicklistEntry() {}
    }

    /**
     * Picklist Label Value 조회(종속성 포함)
     * 
     * @param dependToken : Picklist Api Name
     * @return Map<String,List<Map<String, String>>>
     *         
    **/
    public static Map<String,List<Map<String, String>>> getDependentPicklistValues(Schema.sObjectField dependToken) {
        
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String,List<Map<String, String>>>();
        }
     
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
     
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<Map<String, String>>> dependentPicklistValues = new Map<String,List<Map<String, String>>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getValue() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<Map<String, String>>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(new Map<String, String>{
                        'label' => entry.getLabel(),
                        'value' => entry.getValue()
                    });
                }
            }
        }
        return dependentPicklistValues;
    }


    /**
     * Decimal 콤마 추가
     * 
     * @param d : input Decimal
     * @return String
     *         
    **/
    public static String getDecimalCommaFormat(Decimal d){
        List<String> args = new String[]{'0','number','###,###,##0.00'};
        String s = String.format(d.format(), args);
        return String.format(d.format(), args);
    }
    
    /**
     * Object Name 조회
     * 
     * @param recordIdOrPrefix : Object Record Id
     * @return String
     *         
    **/
    public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        try{
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
            for(Schema.SObjectType stype : gd.values()){

                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                //System.debug('Prefix is ' + prefix);
        
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    //System.debug('Object Name! ' + objectName);
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }
    
    /*
    public static List<String> subset(List<String> aList, Integer count) {
        return subset(aList, 0, count);
    }

    public static List<String> subset(List<String> list1, Integer startIndex, Integer count) {
        List<String> returnList = new List<String>();
        if(list1 != null && list1.size() > 0 && startIndex >= 0 && startIndex <= list1.size()-1 && count > 0){
            for(Integer i = startIndex; i < list1.size() && i - startIndex < count; i++){
                returnList.add(list1.get(i));
            }
        }
        return returnList;
    }

    public static List<Object> subset(List<Object> aList, String objName, Integer count) {
        return subset(aList, objName, 0,count);
    }

    public static List<Object> subset(List<Object> list1, String objName, Integer startIndex, Integer count) {
        List<Object> returnList = new List<Object>();
        if(list1 != null && list1.size() > 0 && startIndex >= 0 && startIndex <= list1.size()-1 && count > 0){
            for(Integer i = startIndex; i < list1.size() && i - startIndex < count; i++){
                returnList.add(list1.get(i));
            }
        }
        return returnList;
    }
    
    public static List<SObject> subset(List<SObject> aList, String objName, Integer count) {
        return subset(aList, objName, 0,count);
    }

    public static List<SObject> subset(List<SObject> list1, String objName, Integer startIndex, Integer count) {
        List<SObject> returnList = null;
        if(list1 != null && list1.size() > 0 && startIndex <= list1.size()-1 && count > 0){
            returnList = createEmptySObjectList(objName);
            for(Integer i = startIndex; i < list1.size() && i - startIndex < count; i++){
                returnList.add(list1.get(i));
            }
        }
        return returnList;
    }
    
    public static List<SObject> createEmptySObjectList(String objName){
        return Database.query(
            'select Id from ' 
            + objName
            + ' where Id = \'0015000000Mrr40\' LIMIT 0'); // use dummy Id to ensure no return
    }
    */

    /**
	 * 전화, 팩스 포맷 변환
	 * @param  target   변환할 문자열
	 * @param  asterisk 가운데자리 * 표기
	 * @return          변환된 문자열
	 */
	public static String getPhoneFormat(String target, Boolean asterisk) {
		String returnData = target.replaceAll('-', '');
		
		String regex;
		Matcher matcher;

		if(target.length() == 11) {
			regex = '^(\\d{3})(\\d{4})(\\d{4})$';
			matcher = Pattern.compile(regex).matcher(target);

			if(matcher.find()) {
				if(asterisk) returnData = target.replaceAll(regex, '$1-****-$3');
				else returnData = target.replaceAll(regex, '$1-$2-$3');
			}
		} 
		else if(target.length() == 8) {
			regex = '^(\\d{4})(\\d{4})$';
			matcher = Pattern.compile(regex).matcher(target);

			if(matcher.find()) {
				returnData = target.replaceAll(regex, '$1-$2');
			}
		}
		else {
			if(target!=null && target.length()>2 && target.left(2)=='02') {
				regex = '^(\\d{2})(\\d{3,4})(\\d{4})$';
				matcher = Pattern.compile(regex).matcher(target);

				if(matcher.find()) {
					if(asterisk) returnData = target.replaceAll(regex, '$1-****-$3');
					else returnData = target.replaceAll(regex, '$1-$2-$3');
				}
			}
			else {
				regex = '^(\\d{3})(\\d{3})(\\d{4})$';
				matcher = Pattern.compile(regex).matcher(target);

				if(matcher.find()) {
					if(asterisk) returnData = target.replaceAll(regex, '$1-***-$3');
					else returnData = target.replaceAll(regex, '$1-$2-$3');
				}
			}
		}

		return returnData;
	}

    /**
     * String null check
     * 
     * @param strKey : input String
     * @return String
     *         
    **/
    public static String nulltoBlank(String strKey) {
        String strReturn = '';

        if(strKey <> null) {
            strReturn = String.valueOf(strKey);
        }
        return strReturn;
    }

    /**
     * Date null check
     * 
     * @param strKey : input String
     * @return String
     *         
    **/
    public static String nulltoBlank(Date strKey) {
        String strReturn = '';

        if(strKey <> null) {
            strReturn = String.valueOf(strKey);
        }
        return strReturn;
    }

    /**
     * Decimal null check
     * 
     * @param strKey : input String
     * @return String
     *         
    **/
    public static String nulltoBlank(Decimal strKey) {
        String strReturn = '';

        if(strKey <> null) {
            strReturn = String.valueOf(strKey);
        }
        return strReturn;
    }

    /**
     * Integer null check
     * 
     * @param strKey : input String
     * @return String
     *         
    **/
    public static String nulltoBlank(Integer strKey) {
        String strReturn = '';

        if(strKey <> null) {
            strReturn = String.valueOf(strKey);
        }
        return strReturn;
    }

    /**
     * html parsing
     * 
     * @param html : html String
     * @param parentTag : 
     * @return String
     *         
    **/
    static public String HTMLparse(String html, String parentTag) {
		// if child tag attributes set, extract the corresponding attribute value instead of the tag value 
		// TODO: requirement: a given child tag can be parsed multiple times (value vs. attribute value) 
		// System.debug('@@@ parent tag: ' + parentTag);
		List<Map<String,List<String>>> objects = new List<Map<String,List<String>>>();
		integer idx = 0; // tracks the current position in the file (cursor position)
		integer eof = html.length();
		// System.debug('@@@ eof: ' + eof);
        String result = '';
		integer parentTagLen = parentTag.length();
		// System.debug('@@@ parent tag length: ' + parentTagLen);
		// a parent tag defines the start of an object
		// to check for nested tags, identify the tag fragment w/o any attributes
		// find the first blank space within (1) or a contiguous closure (2) else assume a fragment is provided
		integer parentTagFragmentEnd = parentTag.indexOf(' ');
		if (parentTagFragmentEnd < 0) {
			parentTagFragmentEnd = parentTag.indexOf('>');
            if (parentTagFragmentEnd < 0) parentTagFragmentEnd = parentTag.length();
		}
		// System.debug('@@@ parent tag fragment ends at: ' + parentTagFragmentEnd);
		String parentTagFragment = parentTag.left(parentTagFragmentEnd);
		// System.debug('@@@ parent tag fragment: ' + parentTagFragment);
		String parentTagClose = parentTagFragment.replace('<','</') + '>';
		// System.debug('@@@ parent tag close: ' + parentTagClose);
		integer parentTagCloseLen = parentTagClose.length();
		// System.debug('@@@ parent tag close length: ' + parentTagCloseLen);
		while (idx <= eof) {
			idx = html.indexOf(parentTag,idx);
			// System.debug('@@@ parent tag found at index: ' + idx);
			if (idx == -1) {
				break;
			}
			integer objectEndIdx;
			// handle nesting: check for the next tag starting index and compare against end
			// keep seeking until no nested tags are found
			integer nextParentTagFragment = html.indexOf(parentTagFragment,idx + 1);
			// System.debug('next parent tag fragment found?: ' + nextParentTagFragment);
			integer nextCloseTag = html.indexOf(parentTagClose,idx + 1);
			// System.debug('next close tag found?: ' + nextCloseTag);
			if (nextParentTagFragment > 0 
					&& nextCloseTag > 0 
					&& nextParentTagFragment < nextCloseTag) {
				// System.debug('@@@ nested tags detected');
				// System.debug('@@@ next parent tag fragment found at: ' + nextParentTagFragment);
				// System.debug('@@@ next parent close tag found at: ' + nextCloseTag);
				while (nextParentTagFragment > 0 
						&& nextCloseTag > 0
							&& nextParentTagFragment < nextCloseTag) {
					nextCloseTag = html.indexOf(parentTagClose,nextCloseTag + 1);
					// System.debug('@@@ next close tag found at: ' + nextCloseTag);
					nextParentTagFragment = html.indexOf(parentTagFragment,nextParentTagFragment + 1);
					// System.debug('@@@ next parent tag found at: ' + nextParentTagFragment);
				} // end while
			} // end if
			objectEndIdx = (nextCloseTag + parentTagCloseLen);
			// System.debug('@@@ object is closed at index: ' + objectEndIdx);
			String parentTagEnclosure = html.substring(idx,objectEndIdx);
			result = html.substring(idx,objectEndIdx);
			// System.debug('@@@ parent tag enclosure (object): ' + parentTagEnclosure);
			idx = objectEndIdx;
			// System.debug('@@@ index incremented to: ' + idx);
		} // end while
		return result;
	}
}