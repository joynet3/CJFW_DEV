public class UTIL_CreateObject {

    /**
     * parameter : 
     *  - objectName : object 명
     *  - NameFldType : Name 필드 타입(Text,Autonumber)
     *  - NameFldFmt : Name 필드가 Autonumber 일 경우 포맷
     *  - NameFldLabel : Name 필드 라벨
     *  - objectDesc : object Description
     *  - fieldMap : 필드 리스트
     */
    public static void dynamicCreation(String objectName,String NameFldType, String NameFldFmt,String NameFldLabel,String objectDesc, Map<String, String> fieldMap,String updateYn)
    {


        try{

            // Define Metadata item to create a Custom Object
            MetadataService.CustomObject customObject = new MetadataService.CustomObject();
            customObject.fullName = objectName + '__c';
            customObject.label = objectName;
            customObject.description = objectDesc;
            customObject.pluralLabel = objectName+'s';
            customObject.nameField = new MetadataService.CustomField();
            customObject.nameField.type_x = NameFldType;
            
            if(NameFldType.equals('AutoNumber')) {            
                customObject.nameField.displayFormat = NameFldFmt;
                customObject.nameField.startingNumber = 1;
            }
            
            customObject.nameField.label = NameFldLabel;

            
            customObject.deploymentStatus = 'Deployed';
            customObject.sharingModel = 'ReadWrite';
            
            List<MetadataService.CustomField> fields = new List<MetadataService.CustomField>();
            
            for(String key : fieldMap.KeySet()) {
                String value = fieldMap.get(key);
                String[] info =  value.split('/');
                String filedNme = key;
                String typex = info[0];
                // Define Metadata item to create a Custom Field on the above object
                MetadataService.CustomField customField = new MetadataService.CustomField();
                customField.fullName = objectName+'__c.'+filedNme+'__c';
                customField.label = filedNme;
                if(typex.equals('datetime')) {
                    customField.type_x = 'Date/Time';
                } else {
                    customField.type_x = typex;
                }
                
                if(!typex.equals('Date') && !typex.equals('datetime') && !typex.equals('PickList') && !typex.equals('Checkbox')) {
                    if(typex.equals('Number')) {
                        
                        if(info[1].indexOf(',')>-1) {
                            String[] numberinfo =  info[1].split(',');
                            customField.scale = Integer.valueOf(numberinfo[1]);
                            customField.precision = Integer.valueOf(numberinfo[0]);
                        } else {
                            customField.scale = 0;
                            customField.precision = Integer.valueOf(info[1]);
                        }
                    } else if(typex.equals('LongTextArea')) {
                        customField.visibleLines = 10;
                        customField.length = Integer.valueOf(info[1]);                    

                    } else {
                        customField.length = Integer.valueOf(info[1]);
                    }     
                }
                if(info.size()>2) {
                    customField.description = info[2];
                }
                
                customField.unique = false;        
                
                fields.add(customField);
            }


            MetadataService.MetadataPort service = createService();
            List<MetadataService.SaveResult> results;
            // Create components in the correct order
            if(updateYn.equals('N')) {
                
                results = service.createMetadata(new MetadataService.Metadata[] { customObject });
                handleSaveResults(results[0]);
        
            }

            Integer i = 1;
            List<MetadataService.Metadata> fields2 = new List<MetadataService.Metadata>();
            for(MetadataService.Metadata itm : fields) {

                if(math.mod(i, 8) ==0) {
                    results = service.createMetadata(fields2);
                    fields2.clear();
                }
                fields2.add(itm);
                i=i+1;
            }

            if(fields2.size() >0) {
                results = service.createMetadata(fields2);
            }


        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }


       
    }


    public static void setVisibility(String objectName, Map<String, String> fieldMap) {

        String objectNameFull = objectName+'__c';

        List<FieldPermissions> delflsList = [Select Id from FieldPermissions  where  SobjectType =:objectName];
        delete delflsList;

        List<FieldPermissions> insflsList = new List<FieldPermissions>();
        List<FieldPermissions> flsList = [Select Id,ParentId,SobjectType,Field,PermissionsEdit,PermissionsRead 
                                        from FieldPermissions 
                                        where Field = 'IF_SFDC_CRCT_REQ_CENTER_INFO__c.crabldt__c'];


        for(String key : fieldMap.KeySet()) {
            String filedNme = key +'__c';
            String filedNmeFull = objectNameFull+'.'+filedNme;
            for (FieldPermissions fls : flsList) {
                FieldPermissions insfls = new FieldPermissions();
                insfls.ParentId = fls.ParentId;
                insfls.SobjectType = objectNameFull;
                insfls.Field = filedNmeFull;
                insfls.PermissionsEdit = true;
                insfls.PermissionsRead = true;
                insflsList.add(insfls);
            }
        }

        insert insflsList;



    }





    public class MetadataServiceExamplesException extends Exception { }

    public static MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }


    
    /**
     * Example helper method to interpret a SaveResult, throws an exception if errors are found
     **/
    public static void handleSaveResults(MetadataService.SaveResult saveResult)
    {
        // Nothing to see?
        if(saveResult==null || saveResult.success)
            return;
        // Construct error message and throw an exception
        if(saveResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!saveResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }



        /**
     * Example helper method to interpret a SaveResult, throws an exception if errors are found
     **/
    public static void handleDeleteResults(MetadataService.DeleteResult deleteResult)
    {
        // Nothing to see?
        if(deleteResult==null || deleteResult.success)
            return;
        // Construct error message and throw an exception
        if(deleteResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (deleteResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + deleteResult.fullName + '.');
            for(MetadataService.Error error : deleteResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!deleteResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }

    /**
     * Example helper method to interpret a UpsertResult, throws an exception if errors are found
     **/
    public static void handleUpsertResults(MetadataService.UpsertResult upsertResult)
    {
        // Nothing to see?
        if(upsertResult==null || upsertResult.success)
            return;
        // Construct error message and throw an exception
        if(upsertResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (upsertResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + upsertResult.fullName + '.');
            for(MetadataService.Error error : upsertResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!upsertResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }


}