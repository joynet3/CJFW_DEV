/**
 * @description       : 
 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 07-31-2023
 * @last modified by  : eunyoung.choi@dkbmc.com 
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   07-31-2023   eunyoung.choi@dkbmc.com   Initial Version
**/
({
    /**
     * @description 초기화 (기업로드 데이터 화면 셋팅)
     */
    fnInit : function(component, event, helper) {
        helper.doInit(component);
    },

    /**
     * @description 시산요약표 업로드 (Validation 및 Excel -> Data 변환)
     */
    fnDataRenderSum: function(component, event, helper) {
        console.log('start fnDataRender ::');

        let data = component.find('exceldataSum').get('v.value');
        component.find('exceldataSum').set('v.value','');
        
        let rows = [];
        if ( data == '' || data == null){
            helper.showToast('error', "입력된 데이터가 없습니다.");
            return false;
        }
        rows = data.split("\n");
        let listParseData = []; 

        for(let y in rows) {
            let cells = rows[y].split("\t");
            listParseData.push(cells);
        }

        if( rows[rows.length-1] == ''){
            listParseData.splice(rows.length-1);
        }

        let rowsLength = listParseData.length;
        let cellsLength = rows[0].split("\t").length;    

        console.log('c.1> rowsLength ', rowsLength );
        console.log('c.2> cellsLength ', cellsLength );
        
        if ( cellsLength != 14){
            helper.showToast("error", "데이터의 열 개수가 일치하지 않습니다. ( 입력 : " + cellsLength + " / 필요 : 14 )" );
            return false;
        } 
        else if ( rowsLength != 12 ){
            helper.showToast("error", "데이터의 행 개수가 일치하지 않습니다. ( 입력 : " + rowsLength + " / 필요 : 12 )" );
            return false;
        }

        let listKeyCode = ["10","20","30","40","50","60","70","71","80","81","90","91"];
        
        let listBalanceDetail_SUM = [];
        listParseData.forEach(function(row, rowIdx){
            let objBalanceDetail_SUM = new Object();
            objBalanceDetail_SUM["Name"] = 'SUM';
            objBalanceDetail_SUM["KeyCode__c"] = listKeyCode[rowIdx];
            row.forEach(function(cell, cellIdx){
                objBalanceDetail_SUM["Column"+(cellIdx+1)+"__c"] = cell;
            })
            listBalanceDetail_SUM.push(objBalanceDetail_SUM);
        })

        component.set("v.listPasteTempResultSum", listBalanceDetail_SUM);
        component.set("v.isExistSum", true);

        setTimeout(function(){ 
            component.set("v.showSpinner", false);
        }, 1000);

        console.log('end fnDataRender ::');
    },
    
    /**
     * @description IRR 업로드 (Validation 및 Excel -> Data 변환)
     */
    fnDataRenderIRR: function(component, event, helper) {
        console.log('start fnDataRender ::');

        let data = component.find('exceldataIRR').get('v.value');
        component.find('exceldataIRR').set('v.value','');
        
        let rows = [];
        if ( data == '' || data == null){
            helper.showToast('error', "입력된 데이터가 없습니다.");
            return false;
        }
        rows = data.split("\n");
        let listParseData = []; 

        for(let y in rows) {
            let cells = rows[y].split("\t");
            listParseData.push(cells);
        }

        if( rows[rows.length-1] == ''){
            listParseData.splice(rows.length-1);
        }

        // Validation
        let rowsLength = listParseData.length;
        let cellsLength = rows[0].split("\t").length;    

        if ( cellsLength != 9 ){
            helper.showToast("error", "데이터의 열 개수가 일치하지 않습니다. ( 입력 : " + cellsLength + " / 필요 : 9 )" );
            return false;
        } else if ( rowsLength != 46 ){
            helper.showToast("error", "데이터의 행 개수가 일치하지 않습니다. ( 입력 : " + rowsLength + " / 필요 : 46 )" );
            return false;
        }

        let regex = new RegExp("[\(\)\ \,]","gi");

        if ( isNaN(listParseData[45][1].replace(regex, ""))){
            helper.showToast("error", "46행의 IRR(%) 의 형식이 정상적이지 않습니다." );
            return false;
        } 
        
        let listKeyCode = ["201","202","203","204","205","206","207","208","209","210",
                           "211","212","213","214","215","216","217","218","219","220",
                           "221","222","223","224","225","226","227","228","229","230",
                           "231","232","233","234","235","236","237","238","239","240",
                           "241","242","243","244","245","246"];

        let listBalanceDetail_IRR = [];
        listParseData.forEach(function(row, rowIdx){
            let objBalanceDetail_IRR = new Object();
            objBalanceDetail_IRR["Name"] = 'IRR';
            objBalanceDetail_IRR["KeyCode__c"] = listKeyCode[rowIdx];
            row.forEach(function(cell, cellIdx){
                objBalanceDetail_IRR["Column"+(cellIdx+1)+"__c"] = cell;
            })
            listBalanceDetail_IRR.push(objBalanceDetail_IRR);
        })

        regex = new RegExp("[\(\)\ ]","gi");
        let objBalance = component.get('v.objBalance');        
        objBalance.IRRPct__c = listParseData[45][1].replace(regex, "");
        console.log ( 'objBalance.IRRPct__c ::: ' + objBalance.IRRPct__c);

        component.set("v.listPasteTempResultIRR", listBalanceDetail_IRR);
        component.set("v.isExistIRR", true);

        setTimeout(function(){ 
            component.set("v.showSpinner", false);
        }, 1000);

        console.log('end fnDataRender ::');
    },
    
    /**
     * @description PL 업로드 (Validation 및 Excel -> Data 변환)
     */
    fnDataRenderPL: function(component, event, helper) {
        console.log('start fnDataRender ::');

        let data = component.find('exceldataPL').get('v.value');
        component.find('exceldataPL').set('v.value','');
        
        let rows = [];
        if ( data == '' || data == null){
            helper.showToast('error', "입력된 데이터가 없습니다.");
            return false;
        }
        rows = data.split("\n");
        let listParseData = []; 

        for(let y in rows) {
            let cells = rows[y].split("\t");
            listParseData.push(cells);
        }

        if( rows[rows.length-1] == ''){
            listParseData.splice(rows.length-1);
        }

        // Validation
        let rowsLength = listParseData.length;
        let cellsLength = rows[0].split("\t").length;    

        if ( cellsLength != 17){
            helper.showToast("error", "데이터의 열 개수가 일치하지 않습니다. ( 입력 : " + cellsLength + " / 필요 : 17 )" );
            return false;
        } else if ( rowsLength != 24 ){
            helper.showToast("error", "데이터의 행 개수가 일치하지 않습니다. ( 입력 : " + rowsLength + " / 필요 : 24 )" );
            return false;
        }

        let regex = new RegExp("[\(\)\ \,]","gi");
        if ( isNaN(listParseData[1][1].replace(regex, ""))){
            helper.showToast("error", "2행의 [매출액] 형식이 정상적이지 않습니다." );
            return false;
        } 
        if ( isNaN(listParseData[2][1].replace(regex, ""))){
            helper.showToast("error", "3행의 [매입원가] 형식이 정상적이지 않습니다." );
            return false;
        } 
        if ( isNaN(listParseData[3][1].replace(regex, ""))){
            helper.showToast("error", "4행의 [매입원가(%)] 형식이 정상적이지 않습니다." );
            return false;
        } 
        if ( isNaN(listParseData[4][1].replace(regex, ""))){
            helper.showToast("error", "5행의 [제조경비] 형식이 정상적이지 않습니다." );
            return false;
        } 
        if ( isNaN(listParseData[5][1].replace(regex, ""))){
            helper.showToast("error", "6행의 [제조경비(%)] 형식이 정상적이지 않습니다." );
            return false;
        } 

        if ( isNaN(listParseData[6][1].replace(regex, ""))){
            helper.showToast("error", "7행의 [인건비] 형식이 정상적이지 않습니다." );
            return false;
        } 
        if ( isNaN(listParseData[7][1].replace(regex, ""))){
            helper.showToast("error", "8행의 [서비스전문직비] 형식이 정상적이지 않습니다." );
            return false;
        } 
        if ( isNaN(listParseData[8][1].replace(regex, ""))){
            helper.showToast("error", "9행의 [물류비] 형식이 정상적이지 않습니다." );
            return false;
        } 
        if ( isNaN(listParseData[9][1].replace(regex, ""))){
            helper.showToast("error", "10행의 [상각비] 형식이 정상적이지 않습니다." );
            return false;
        } 
        if ( isNaN(listParseData[10][1].replace(regex, ""))){
            helper.showToast("error", "11행의 [임차료] 형식이 정상적이지 않습니다." );
            return false;
        } 
        if ( isNaN(listParseData[11][1].replace(regex, ""))){
            helper.showToast("error", "12행의 [유틸리티] 형식이 정상적이지 않습니다." );
            return false;
        } 
        if ( isNaN(listParseData[12][1].replace(regex, ""))){
            helper.showToast("error", "13행의 [소모품비] 형식이 정상적이지 않습니다." );
            return false;
        } 
        if ( isNaN(listParseData[13][1].replace(regex, ""))){
            helper.showToast("error", "14행의 [기타경비] 형식이 정상적이지 않습니다." );
            return false;
        } 


        if ( isNaN(listParseData[14][1].replace(regex, ""))){
            helper.showToast("error", "15행의 [매출이익] 형식이 정상적이지 않습니다." );
            return false;
        } 
        if ( isNaN(listParseData[15][1].replace(regex, ""))){
            helper.showToast("error", "16행의 [매출이익(%)] 형식이 정상적이지 않습니다." );
            return false;
        } 

        
        if ( isNaN(listParseData[16][1].replace(regex, ""))){
            helper.showToast("error", "17행의 [금융수지] 형식이 정상적이지 않습니다." );
            return false;
        } 
        if ( isNaN(listParseData[17][1].replace(regex, ""))){
            helper.showToast("error", "18행의 [금융수익] 형식이 정상적이지 않습니다." );
            return false;
        } 
        if ( isNaN(listParseData[18][1].replace(regex, ""))){
            helper.showToast("error", "19행의 [금융비용] 형식이 정상적이지 않습니다." );
            return false;
        } 
        if ( isNaN(listParseData[19][1].replace(regex, ""))){
            helper.showToast("error", "20행의 [기타영외수지] 형식이 정상적이지 않습니다." );
            return false;
        } 
        if ( isNaN(listParseData[20][1].replace(regex, ""))){
            helper.showToast("error", "21행의 [기타영외수익] 형식이 정상적이지 않습니다." );
            return false;
        } 
        if ( isNaN(listParseData[21][1].replace(regex, ""))){
            helper.showToast("error", "22행의 [기타영외비용] 형식이 정상적이지 않습니다." );
            return false;
        } 

        if ( isNaN(listParseData[22][1].replace(regex, ""))){
            helper.showToast("error", "23행의 [관리이익] 형식이 정상적이지 않습니다." );
            return false;
        } 
        if ( isNaN(listParseData[23][1].replace(regex, ""))){
            helper.showToast("error", "24행의 [관리이익(%)] 형식이 정상적이지 않습니다." );
            return false;
        }

        let listKeyCode = ["0","101","102","103","104","105","106","107","108",
                           "109","110","111","112","113","114","115","116",
                           "117","118","119","120","121","122","123"];
                    
        let listBalanceDetail_PL = [];
        listParseData.forEach(function(row, rowIdx){
            let objBalanceDetail_PL = new Object();
            objBalanceDetail_PL["Name"] = 'PL';
            objBalanceDetail_PL["KeyCode__c"] = listKeyCode[rowIdx];
            row.forEach(function(cell, cellIdx){
                objBalanceDetail_PL["Column"+(cellIdx+1)+"__c"] = cell;
            })
            listBalanceDetail_PL.push(objBalanceDetail_PL);
        })

        regex = new RegExp("[\(\)\ ]","gi");
        let objBalance = component.get('v.objBalance');
        objBalance.SalesRevenue__c = listParseData[1][1].replace(regex, "");
        objBalance.PurchasingCost__c = listParseData[2][1].replace(regex, "");
        objBalance.PurchasingCostPct__c = listParseData[3][1].replace(regex, "");
        objBalance.ManufacturingCost__c = listParseData[4][1].replace(regex, "");
        objBalance.ManufacturingCostPct__c = listParseData[5][1].replace(regex, "");
        objBalance.CommonLaborCostAmt__c = listParseData[6][1].replace(regex, "");
        objBalance.ServiceLaborCostAmt__c = listParseData[7][1].replace(regex, "");
        objBalance.LogisticCostAmt__c = listParseData[8][1].replace(regex, "");
        objBalance.DepreciationCostAmt__c = listParseData[9][1].replace(regex, "");
        objBalance.RentalCostAmt__c = listParseData[10][1].replace(regex, "");
        objBalance.UtilityCostAmt__c = listParseData[11][1].replace(regex, "");
        objBalance.ConsumableCostAmt__c = listParseData[12][1].replace(regex, "");
        objBalance.EtcCostAmt__c = listParseData[13][1].replace(regex, "");

        objBalance.SalesProfit__c = listParseData[14][1].replace(regex, "");
        objBalance.SalesProfitPct__c = listParseData[15][1].replace(regex, "");
        
        objBalance.FinancialBalanceAmt__c = listParseData[16][1].replace(regex, "");
        objBalance.FinancialProfitAmt__c = listParseData[17][1].replace(regex, "");
        objBalance.FinancialExpenseAmt__c = listParseData[18][1].replace(regex, "");
        objBalance.EtcBalanceAmt__c = listParseData[19][1].replace(regex, "");
        objBalance.EtcProfitAmt__c = listParseData[20][1].replace(regex, "");
        objBalance.EtcExpenseAmt__c = listParseData[21][1].replace(regex, "");

        objBalance.MgmtProfit__c = listParseData[22][1].replace(regex, "");
        objBalance.MgmtProfitPct__c = listParseData[23][1].replace(regex, "");

        component.set("v.listPasteTempResultPL", listBalanceDetail_PL);
        component.set("v.isExistPL", true);
        component.set("v.objBalance", objBalance);

        setTimeout(function(){ 
            component.set("v.showSpinner", false);
        }, 1000);

        console.log('end fnDataRender ::');
    },

    /**
     * @description 데이터 저장 (3개표 업로드 확인)
     */
    fnSave : function(component, event, helper) {
        // Validation
        let errorList = [];
        let isValid = true;
        
        let isExistSum = component.get('v.isExistSum');
        let isExistIRR = component.get('v.isExistIRR');
        let isExistPL = component.get('v.isExistPL');

        if ( !isExistSum ){
            errorList.push('시산요약표');
            isValid = false;
        }
        if ( !isExistIRR ){
            errorList.push('IRR');
            isValid = false;
        }
        if ( !isExistPL ){
            errorList.push('PL');
            isValid = false;
        }

        if ( !isValid ){
            let errorMessage = '';
            let isFirst = true;
            for ( let i in errorList ){
                errorMessage = isFirst ? errorList[i] : errorMessage + ', '+ errorList[i];
                isFirst = false;                 
            }
            helper.showToast("error",  errorMessage + "(이)가 입력되지 않았습니다." );
            return false;
        }

        if(component.get("v.isBTNClicked") == true){
            console.log("Duplication prevention!");
            return;
        }
        component.set("v.isBTNClicked", true);  
        helper.doSave(component);
    },

    fnCancel : function(component, event, helper) {
        helper.doCloseModal(component);
    },
})