({
    // init
	doInit : function(component, event, helper) {
		component.set("v.showSpinner", true);
		component.set("v.selectedHeadOffice", 'none');
		component.set("v.selectedSU", 'none');

        let action = component.get("c.doInit");

        action.setCallback(this, function(response) {
            let state = response.getState();

            if(state === "SUCCESS") {
                let returnValue = response.getReturnValue();

				let objUser = returnValue.objUser;
				let mapSelectSU = returnValue.mapSelectSU; 
				// let mapSelectTeam = returnValue.mapSelectTeam; 

				component.set("v.mapSelectSU", mapSelectSU);
				// component.set("v.mapSelectTeam", mapSelectTeam);
				component.set("v.listSelectHeadOffice", returnValue.listSelectHeadOffice);
				component.set("v.listSelectSU", mapSelectSU[objUser.HeadOffice__c]);
				// component.set("v.listSelectTeam", mapSelectTeam[objUser.SU__c]);

	
				if(!(helper.isNullCheck(objUser.HeadOffice__c))) {
					let listSelectHeadOffice = component.get("v.listSelectHeadOffice");
					// if( userType == 'IT'){
					// 	component.set("v.isDisableTeam", true);	
					// }
					for ( let i in listSelectHeadOffice){
						if(listSelectHeadOffice[i].value == objUser.HeadOffice__c) {                            
                            listSelectHeadOffice[i].selected = true;

                            if(objUser.HeadOffice__c == '3000') {
                                component.set("v.isFS", true);
                            }
                        }							
						else {
                            listSelectHeadOffice[i].selected = false;
                        }
					}
					component.set("v.selectedHeadOffice", objUser.HeadOffice__c);
				}

				if(!(helper.isNullCheck(objUser.SU__c))) {
					let listSelectSU = component.get("v.listSelectSU");
					// if( userType == 'AS' || userType == 'IT'){
					// 	component.set("v.selectedSU", 'none');
					// }
					// else {
                    for ( let i in listSelectSU){
                        if(listSelectSU[i].value == objUser.SU__c)
                            listSelectSU[i].selected = true;
                        else
                            listSelectSU[i].selected = false;
                    }
                    component.set("v.selectedSU", objUser.SU__c);	
					// }
				}

                // let selectedSU = component.get("v.selectedSU");
                // component.set("v.listSelectTeam", mapSelectTeam[selectedSU]);
                // component.set("v.selectedTeam", 'none');

				// if(!(helper.isNullCheck(objUser.Team__c))) {
				// 	let listSelectTeam = component.get("v.listSelectTeam");
				// 	if( userType == 'AS' || userType == 'IT'){
				// 		component.set("v.selectedTeam", 'none');
				// 	}
				// 	else {
				// 		for ( let i in listSelectTeam){
				// 			if(listSelectTeam[i].value == objUser.Team__c)
				// 				listSelectTeam[i].selected = true;
				// 			else
				// 				listSelectTeam[i].selected = false;
				// 		}
				// 		if(  objUser.Team__c == null){
				// 			component.set("v.selectedTeam", 'none');
				// 		}
				// 		else{
				// 			component.set("v.selectedTeam", objUser.Team__c);
				// 		}
				// 	}
				// }
            }
            else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            }
            else if (state === "ERROR") {
                let errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        helper.showToast('ERROR', errors[0].message);
                        console.log("Error message: " + errors[0].message);
                    }
                }
                else {
                    console.log("Unknown error");
                }
            }
			component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
    
    // 업로드한 엑셀 파일을 읽고 테이블로 출력
    doXlsxRead : function(component, objExcelImport, file, helper) {
        var fileReader = new FileReader();

        fileReader.addEventListener("load", $A.getCallback(function(e) {
            helper.showSpinner(component);        
            var workbook = null;

            try {
                // var data = new Uint8Array(e.target.result);
                var data = new Uint8Array(e.currentTarget.result);
                var arry = new Array();

                for(var i = 0; i < data.length; i++) arry[i] = String.fromCharCode(data[i]);
                var bstr = arry.join("");
                workbook = XLSX.read(bstr, {type: "binary", cellDates: true, cellNF: false, cellText: false});

                var firstSheet = workbook.SheetNames[0];
                var workSheet  = workbook.Sheets[firstSheet];                
                
                // 데이터 범위 설정
                var range = XLSX.utils.decode_range(workbook.Sheets[firstSheet]['!ref']);
                range.s.r = objExcelImport.StartRow;
                range.s.c = objExcelImport.StartColumn;
                var new_range = XLSX.utils.encode_range(range);

                // 엑셀 헤더 리스트 생성
                var xlsx_headers = objExcelImport.FieldName;

                console.log('============> xlsx_headers JSON : '+JSON.stringify(xlsx_headers));
                
                // 엑셀 헤더 리스트를 컬럼으로 JSON 생성
                var resultJSON = XLSX.utils.sheet_to_json(workSheet, {header: xlsx_headers, range: new_range, dateNF: "YYYY-MM-DD", raw: false});
                var objHeader = resultJSON[0];                
                
                console.log('============> resultJSON JSON : '+JSON.stringify(resultJSON));
                console.log('============> objHeader JSON : '+JSON.stringify(objHeader));
                
                
                // 테이블 헤더, 바디 리스트 생성
                var listHeader = Object.values(objHeader);

                console.log('============> xlsx_headers.length : '+xlsx_headers.length);
                console.log('============> listHeader.length : '+listHeader.length);

                if(xlsx_headers.length !== listHeader.length) {
                    var errorMessage = $A.get("$Label.c.ExcelFormatNotMatch");
                    helper.showToast('Error', errorMessage);
                }
                
                resultJSON.splice(0, 1);
				
                helper.fnCheckFile(component, resultJSON, file, helper);
            } catch(e) {
                console.log(e);
                helper.showToast("error", $A.get("$Label.c.ErrorMessage"));
                // self.showToast("error", e);                
                helper.hideSpinner(component);
            }
        }));

        fileReader.readAsArrayBuffer(file);
    },
    // 파일체크
    fnCheckFile : function(component, resultJSON, file, helper) {
        helper.showSpinner(component);
        
        var reader = new FileReader();

        reader.onload = $A.getCallback(function() {
            var fileContents = reader.result;  
            //console.log(fileContents);
            /*
            var base64 = 'base64,';
            
            var dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart);
            */

            // InComeDetail__c 생성 메소드
            var action = component.get("c.doCheckFile");

            action.setParams({
                recordId : component.get("v.recordId"),                
                strItemDetail : JSON.stringify(resultJSON)
                /*
                fileName : file.name,
                fileContents : encodeURIComponent(fileContents)
                */
            });
            action.setCallback(this, function(response) {
                var state = response.getState();

                if(state === "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    console.log(returnValue);

                    component.set("v.listSuccessWrapper", returnValue.listSuccessWrapper);
                    component.set("v.listErrorWrapper", returnValue.listErrorWrapper);
                    component.set("v.totalSize", returnValue.totalSize);
                    component.set("v.successSize", returnValue.successSize);
                    component.set("v.errorSize", returnValue.errorSize);

					console.log('===========> returnValue.errorSize : '+returnValue.errorSize);
					console.log('===========> returnValue.successSize : '+returnValue.successSize);

                    if(returnValue.errorSize == 0 && returnValue.successSize > 0) {
                        helper.showToast("success", "오류건수가 존재하지 않습니다. 업로드를 진행해주세요.");                        
						console.log('===========> isDisabled false');
                        component.set("v.isDisabled", false);
                    }else {
                        helper.showToast("error", "오류건수가 존재합니다. 파일을 확인해주세요.");                        
						console.log('===========> isDisabled true');
                        component.set("v.isDisabled", true);
                    }
                    
                } else if(state === "ERROR") {
                    var errors = response.getError();
                    if(errors) {
                        if(errors[0] && errors[0].message) helper.showToast("error", errors[0].message);
                    } else {
                        helper.showToast("error", "Unknown error");
                    }
                }
                helper.hideSpinner(component);
            });

            $A.enqueueAction(action); 
		});

        reader.readAsDataURL(file);
    },
    // 샘플 엑셀 생성
    doGetExportTarget : function(component, event, helper) {
        var action = component.get("c.doGetExportTarget");

        let selectedHeadOffice = component.get("v.selectedHeadOffice");
        let selectedSU = component.get("v.selectedSU");

		action.setParams({
            selectedHeadOffice : selectedHeadOffice,
            selectedSU : selectedSU
		});
		action.setCallback(this, function(response) {
            let state = response.getState();

            if(state === "SUCCESS") {
                let returnValue = response.getReturnValue();
                console.log(JSON.stringify(returnValue));
                component.set("v.listDownloadWrapper", returnValue);
                this.doExcelExport(component);
			} else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    // 샘플 액셀 다운로드
    doExcelExport : function(component, event, helper) {

        // if ( component.get("v.listDownloadWrapper") == '' ){
        //     helper.showToast("error","출력할 대상이 없습니다.");
        //     return;
        // }

        let Today = new Date;
        let year  = Today.getFullYear();
        let month = Today.getMonth() + 1;
        let day = Today.getDate();

        month = (month > 9 ) ? month : "0"+month;
        day   = (day > 9 ) ? day : "0"+day;

        let fullDate = year+'-'+month+'-'+day;
        let isFS = component.get("v.isFS");
        
        let columns = [];
        try{
            columns.push({label: "본부", fieldName: "HeadOfficeName", type: "text"});
            columns.push({label: "본부코드", fieldName: "HeadOfficeCode", type: "text"});
            columns.push({label: "SU", fieldName: "SUName", type: "text"});
            columns.push({label: "SU코드", fieldName: "SUCode", type: "text"});
            columns.push({label: "팀", fieldName: "TeamName", type: "text"});
            columns.push({label: "팀코드", fieldName: "TeamCode", type: "text"});
            columns.push({label: "사번", fieldName: "UserNumber", type: "text"});
            columns.push({label: "MA명", fieldName: "UserName", type: "text"});
            columns.push({label: "년도", fieldName: "Year", type: "text"});
            columns.push({label: "월", fieldName: "Month", type: "text"});
            columns.push({label: "신규처/기존처(MDM상)", fieldName: "Dummy1", type: "text"});
            columns.push({label: "매출계획(원)", fieldName: "Dummy2", type: "text"});
            columns.push({label: "매출이익(원)", fieldName: "Dummy3", type: "text"});
            if (isFS){
                columns.push({label: "수주매출(원)", fieldName: "Dummy4", type: "text"});
                columns.push({label: "발생매출(원)", fieldName: "Dummy5", type: "text"});
                columns.push({label: "발생매출이익(원)", fieldName: "Dummy6", type: "text"});
            }
            

            var exportDataList = [];
            // Get Header
            var columnsList = [];
            for(var columnsIndex in columns) {
                columnsList.push(columns[columnsIndex].label);
                console.log('columns[columnsIndex].label' + columns[columnsIndex].label );
            }

            exportDataList.push(columnsList);
            console.log("export::::"+exportDataList);
            // Get Data
            var data = component.get("v.listDownloadWrapper");
            var dataList = [];
            for(var dataIndex in data) {
                dataList = [];
                // dataList.push(Number(dataIndex)+1);
                dataList.push(data[dataIndex].HeadOfficeName);
                dataList.push(data[dataIndex].HeadOfficeCode);
                dataList.push(data[dataIndex].SUName);
                dataList.push(data[dataIndex].SUCode);
                dataList.push(data[dataIndex].TeamName);
                dataList.push(data[dataIndex].TeamCode);
                dataList.push(data[dataIndex].UserNumber);
                dataList.push(data[dataIndex].UserName);
                dataList.push(data[dataIndex].Year);
                dataList.push(data[dataIndex].Month);
                dataList.push(data[dataIndex].Dummy1);
                dataList.push(data[dataIndex].Dummy2);
                dataList.push(data[dataIndex].Dummy3);
                if (isFS){
                    dataList.push(data[dataIndex].Dummy4);
                    dataList.push(data[dataIndex].Dummy5);
                    dataList.push(data[dataIndex].Dummy6);
                }
                exportDataList.push(dataList);
            }
            console.log("export::::"+exportDataList);

            var excelHandler = {
                getExcelFileName : function(){
                    return "경영계획_엑셀업로드_양식_"+fullDate+".xlsx";
                },
                getSheetName : function(){
                    return "Sheet1";
                },
                getExcelData : function(){
                    return exportDataList;
                },
                getWorksheet : function(){
                    return XLSX.utils.aoa_to_sheet(this.getExcelData());
                }
            }

            var excelHandler = {
                getExcelFileName : function(){
                    return "경영계획_엑셀업로드_양식_"+fullDate+".xlsx";
                },
                getSheetName : function(){
                    return "Sheet1";
                },
                getExcelData : function(){
                    return exportDataList;
                },
                getWorksheet : function(){
                    return XLSX.utils.aoa_to_sheet(this.getExcelData());
                }
            }

            var saveAs = saveAs || (function(view) {
                "use strict";
                // IE <10 is explicitly unsupported
                if (typeof view === "undefined" || typeof navigator !== "undefined" && /MSIE [1-9]\./.test(navigator.userAgent)) {
                    return;
                }
                var
                        doc = view.document
                        // only get URL when necessary in case Blob.js hasn"t overridden it yet
                    , get_URL = function() {
                        return view.URL || view.webkitURL || view;
                    }
                    , save_link = doc.createElementNS("http://www.w3.org/1999/xhtml", "a")
                    , can_use_save_link = "download" in save_link
                    , click = function(node) {
                        var event = new MouseEvent("click");
                        node.dispatchEvent(event);
                    }
                    , is_safari = /constructor/i.test(view.HTMLElement) || view.safari
                    , is_chrome_ios =/CriOS\/[\d]+/.test(navigator.userAgent)
                    , throw_outside = function(ex) {
                        (view.setImmediate || view.setTimeout)(function() {
                            throw ex;
                        }, 0);
                    }
                    , force_saveable_type = "application/octet-stream"
                    // the Blob API is fundamentally broken as there is no "downloadfinished" event to subscribe to
                    , arbitrary_revoke_timeout = 1000 * 40 // in ms
                    , revoke = function(file) {
                        var revoker = function() {
                            if (typeof file === "string") { // file is an object URL
                                get_URL().revokeObjectURL(file);
                            } else { // file is a File
                                file.remove();
                            }
                        };
                        setTimeout(revoker, arbitrary_revoke_timeout);
                    }
                    , dispatch = function(filesaver, event_types, event) {
                        event_types = [].concat(event_types);
                        var i = event_types.length;
                        while (i--) {
                            var listener = filesaver["on" + event_types[i]];
                            if (typeof listener === "function") {
                                try {
                                    listener.call(filesaver, event || filesaver);
                                } catch (ex) {
                                    throw_outside(ex);
                                }
                            }
                        }
                    }
                    , auto_bom = function(blob) {
                        // prepend BOM for UTF-8 XML and text/* types (including HTML)
                        // note: your browser will automatically convert UTF-16 U+FEFF to EF BB BF
                        if (/^\s*(?:text\/\S*|application\/xml|\S*\/\S*\+xml)\s*;.*charset\s*=\s*utf-8/i.test(blob.type)) {
                            return new Blob([String.fromCharCode(0xFEFF), blob], {type: blob.type});
                        }
                        return blob;
                    }
                    , FileSaver = function(blob, name, no_auto_bom) {
                        if (!no_auto_bom) {
                            blob = auto_bom(blob);
                        }
                        // First try a.download, then web filesystem, then object URLs
                        var
                                filesaver = this
                            , type = blob.type
                            , force = type === force_saveable_type
                            , object_url
                            , dispatch_all = function() {
                                dispatch(filesaver, "writestart progress write writeend".split(" "));
                            }
                            // on any filesys errors revert to saving with object URLs
                            , fs_error = function() {
                                if ((is_chrome_ios || (force && is_safari)) && view.FileReader) {
                                    // Safari doesn"t allow downloading of blob urls
                                    var reader = new FileReader();
                                    reader.onloadend = function() {
                                        var url = is_chrome_ios ? reader.result : reader.result.replace(/^data:[^;]*;/, "data:attachment/file;");
                                        var popup = view.open(url, "_blank");
                                        if(!popup) view.location.href = url;
                                        url=undefined; // release reference before dispatching
                                        filesaver.readyState = filesaver.DONE;
                                        dispatch_all();
                                    };
                                    reader.readAsDataURL(blob);
                                    filesaver.readyState = filesaver.INIT;
                                    return;
                                }
                                // don"t create more object URLs than needed
                                if (!object_url) {
                                    object_url = get_URL().createObjectURL(blob);
                                }
                                if (force) {
                                    view.location.href = object_url;
                                } else {
                                    var opened = view.open(object_url, "_blank");
                                    if (!opened) {
                                        // Apple does not allow window.open, see https://developer.apple.com/library/safari/documentation/Tools/Conceptual/SafariExtensionGuide/WorkingwithWindowsandTabs/WorkingwithWindowsandTabs.html
                                        view.location.href = object_url;
                                    }
                                }
                                filesaver.readyState = filesaver.DONE;
                                dispatch_all();
                                revoke(object_url);
                            }
                        ;
                        filesaver.readyState = filesaver.INIT;

                        if (can_use_save_link) {
                            object_url = get_URL().createObjectURL(blob);
                            setTimeout(function() {
                                save_link.href = object_url;
                                save_link.download = name;
                                click(save_link);
                                dispatch_all();
                                revoke(object_url);
                                filesaver.readyState = filesaver.DONE;
                            });
                            return;
                        }

                        fs_error();
                    }
                    , FS_proto = FileSaver.prototype
                    , saveAs = function(blob, name, no_auto_bom) {
                        return new FileSaver(blob, name || blob.name || "download", no_auto_bom);
                    }
                ;
                // IE 10+ (native saveAs)
                if (typeof navigator !== "undefined" && navigator.msSaveOrOpenBlob) {
                    return function(blob, name, no_auto_bom) {
                        name = name || blob.name || "download";

                        if (!no_auto_bom) {
                            blob = auto_bom(blob);
                        }
                        return navigator.msSaveOrOpenBlob(blob, name);
                    };
                }

                FS_proto.abort = function(){};
                FS_proto.readyState = FS_proto.INIT = 0;
                FS_proto.WRITING = 1;
                FS_proto.DONE = 2;

                FS_proto.error =
                FS_proto.onwritestart =
                FS_proto.onprogress =
                FS_proto.onwrite =
                FS_proto.onabort =
                FS_proto.onerror =
                FS_proto.onwriteend =
                    null;

                return saveAs;
            }(
                    typeof self !== "undefined" && self
                || typeof window !== "undefined" && window
                || this
            ));

            if (typeof module !== "undefined" && module.exports) {
                module.exports.saveAs = saveAs;
            } else if ((typeof define !== "undefined" && define !== null) && (define.amd !== null)) {
                define("FileSaver.js", function() {
                    return saveAs;
                });
            }

            function s2ab(s) {
                var buf = new ArrayBuffer(s.length); //convert s to arrayBuffer
                var view = new Uint8Array(buf);  //create uint8array as viewer
                for (var i=0; i<s.length; i++) view[i] = s.charCodeAt(i) & 0xFF; //convert to octet
                return buf;
            }

            // step 1. workbook 생성
            var wb = XLSX.utils.book_new();

            // step 2. 시트 만들기
            var newWorksheet = excelHandler.getWorksheet();

            // step 3. workbook에 새로만든 워크시트에 이름을 주고 붙인다.
            XLSX.utils.book_append_sheet(wb, newWorksheet, excelHandler.getSheetName());

            // step 4. 엑셀 파일 만들기
            var wbout = XLSX.write(wb, {bookType:"xlsx",  type: "binary"});

            // step 5. 엑셀 파일 내보내기
            saveAs(new Blob([s2ab(wbout)],{type:"application/octet-stream"}), excelHandler.getExcelFileName());

            component.set("v.showSpinner", false);
        }catch(e) {
            console.log(e);
            component.set("v.showSpinner", false);
        }
    },

    // Toast 메시지
	showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    },

	// Null , Undefined , '' 체크
    isNullCheck : function(value){
        if(value == null || value == undefined || value == ""){
            return true;
        }
        else{
            return false;
        }
    },
    // 로딩바 활성화
    showSpinner: function (component) {
		/* this will show the <lightning:spinner /> */
		component.set('v.showSpinner', true);	
	},
    // 로딩바 비활성화
	hideSpinner: function (component) {
		/* this will hide the <lightning:spinner /> */
		component.set('v.showSpinner', false);
	},
	
})