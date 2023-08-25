import { LightningElement, api, track } from 'lwc';
import { utilAlert, utilShowToast, utilConfrim,  setCustomStyle, removeCustomStyle} from 'c/commUtils';

//
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

//Static Resource
import CJFWCOMMCSS from '@salesforce/resourceUrl/cjfwCOMMCss'

export default class CjfwRevenueAdjustment extends LightningElement {
  numberFieldList = [
    'sppVATincl'    //기준 매입가(VAT포함)
    ,'fmvVATincl'   //적정판가(VAT포함)
    ,'rrpVATincl'   //실판가(VAT포함)
    ,'ns'           //순매출
    ,'vat'          //부가세
    ,'tr'           //총매출
    ,'apVATincl'    //조정판가
    ,'pmp'          //전월판가
    ,'ans'          //조정 순매출
    ,'aVAT'         //조정 부가세
    ,'atr'          //조정 총매출
    ,'ataVATincl'   //조정총액
  ];

  tdFocusTimer = {};

  notUseNumberList = [
    Infinity
    ,NaN
    //,undefined
  ];

  @track _raData = [
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 0,"productCode":100295,"productName":"오뚜기 빵가루(1Kg/EA)","unit":"EA","sppVATincl":2066,"fmvVATincl":2718,"gpmFMV":24,"rrpVATincl":2047,"gpmRRP":-0.92,"quantity":2,"ns":3722,"vat":372,"tr":4094,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":5907,"pmGMP":24.15,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 1,"productCode":101356,"productName":"삼호 구운어묵(부들_50g/개 1Kg/EA)","unit":"EA","sppVATincl":5280,"fmvVATincl":7164,"gpmFMV":26.3,"rrpVATincl":6600,"gpmRRP":20,"quantity":2.00,"ns":12000,"vat":1200,"tr":13200,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":2200,"pmGMP":14.5,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 2,"productCode":108424,"productName":"동원F&B 참치캔(스탠다드 1.88Kg/EA)","unit":"EA","sppVATincl":19812,"fmvVATincl":28303,"gpmFMV":30.0,"rrpVATincl":28314,"gpmRRP":30.03,"quantity":3,"ns":77220,"vat":7722,"tr":84942,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":28314,"pmGMP":30.03,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 3,"productCode":109735,"productName":"백설 튀김가루(2Kg/EA)","unit":"EA","sppVATincl":3769,"fmvVATincl":5383,"gpmFMV":30.0,"rrpVATincl":5137,"gpmRRP":26.64,"quantity":7,"ns":32.690,"vat":3269,"tr":35959,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":5137,"pmGMP":26.64,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 4,"productCode":123452,"productName":"홉라 휘핑크림(식물성 1Kg/EA)","unit":"EA","sppVATincl":4950,"fmvVATincl":7072,"gpmFMV":30.0,"rrpVATincl":5643,"gpmRRP":12.28,"quantity":72,"ns":369.360,"vat":36936,"tr":406296,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":5673,"pmGMP":12.74,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 5,"productCode":127692,"productName":"스팸 햄캔(1.81Kg/EA)","unit":"EA","sppVATincl":18689,"fmvVATincl":26698,"gpmFMV":30.0,"rrpVATincl":22880,"gpmRRP":18.32,"quantity":13,"ns":270.400,"vat":27040,"tr":297440,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":22880,"pmGMP":18.32,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 6,"productCode":128459,"productName":"오뚜기 데리야끼소스C(2Kg/EA)","unit":"EA","sppVATincl":6838,"fmvVATincl":9768,"gpmFMV":30.0,"rrpVATincl":8829,"gpmRRP":22.55,"quantity":13,"ns":104.340,"vat":10434,"tr":114774,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":9119,"pmGMP":25.02,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 7,"productCode":128988,"productName":"사세통상 왕새우튀김(30g*10개입 300g/EA)","unit":"EA","sppVATincl":3245,"fmvVATincl":4635,"gpmFMV":30.0,"rrpVATincl":3850,"gpmRRP":15.71,"quantity":54,"ns":189.000,"vat":18.900,"tr":207900,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":3850,"pmGMP":15.71,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 8,"productCode":133099,"productName":"크레잇 냉동베이컨(B2B 1Kg/EA)","unit":"EA","sppVATincl":12323,"fmvVATincl":17604,"gpmFMV":30.0,"rrpVATincl":15620,"gpmRRP":21.11,"quantity":5,"ns":71.000,"vat":7100,"tr":78100,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":15620,"pmGMP":21.11,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 9,"productCode":142410,"productName":"신영상회 파슬리후레이크(100g/EA)","unit":"EA","sppVATincl":3968,"fmvVATincl":5669,"gpmFMV":30.01,"rrpVATincl":4870,"gpmRRP":18.52,"quantity":1,"ns":4.870,"vat":0,"tr":4870,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":4870,"pmGMP":18.52,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 10,"productCode":154639,"productName":"오뚜기 마요네즈(골드 스파우트팩 3.2Kg/EA)","unit":"EA","sppVATincl":14053,"fmvVATincl":20075,"gpmFMV":30.0,"rrpVATincl":18326,"gpmRRP":23.32,"quantity":7,"ns":116.620,"vat":11662,"tr":128282,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":18326,"pmGMP":23.32,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 11,"productCode":202345,"productName":"깐대파(상품 KG)","unit":"KG","sppVATincl":2165,"fmvVATincl":3231,"gpmFMV":32.99,"rrpVATincl":2.640,"gpmRRP":17.99,"quantity":121,"ns":319.440,"vat":0,"tr":319.440,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":2721,"pmGMP":18.17,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 12,"productCode":203216,"productName":"청결 고춧가루(특품 김치용 1Kg/PAC)","unit":"PAC","sppVATincl":8920,"fmvVATincl":12743,"gpmFMV":30.0,"rrpVATincl":11500,"gpmRRP":22.43,"quantity":9,"ns":103.500,"vat":0,"tr":103500,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":11500,"pmGMP":22.43,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 13,"productCode":225885,"productName":"토담 밀떡볶이떡(누들떡 1Kg/EA)","unit":"EA","sppVATincl":2397,"fmvVATincl":3424,"gpmFMV":30.0,"rrpVATincl":3.289,"gpmRRP":27.12,"quantity":16,"ns":47.840,"vat":4.784,"tr":52624,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":3291,"pmGMP":27.16,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 14,"productCode":229740,"productName":"농심 사리면(110g*5입 CJ프레시웨이전용 550g/EA)","unit":"EA","sppVATincl":1066,"fmvVATincl":1522,"gpmFMV":29.99,"rrpVATincl":1408,"gpmRRP":24.3,"quantity":85,"ns":108.800,"vat":10880,"tr":119680,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":1.408,"pmGMP":24.3,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 15,"productCode":271174,"productName":"백설 하얀설탕(1Kg/EA)","unit":"EA","sppVATincl":1371,"fmvVATincl":1958,"gpmFMV":30.0,"rrpVATincl":1672,"gpmRRP":18.03,"quantity":2,"ns":3.040,"vat":304,"tr":3.344,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":1672,"pmGMP":18.03,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 16,"productCode":283194,"productName":"모짜크림치즈찰볼(60계용 1.2Kg/EA)","unit":"EA","sppVATincl":11990,"fmvVATincl":17128,"gpmFMV":30.0,"rrpVATincl":14850,"gpmRRP":19.26,"quantity":11,"ns":148.500,"vat":14850,"tr":163350,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":14850,"pmGMP":19.26,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 17,"productCode":286622,"productName":"신선 마유(神鲜麻油_400ml 400g/EA)","unit":"EA","sppVATincl":6021,"fmvVATincl":8602,"gpmFMV":30.0,"rrpVATincl":7689,"gpmRRP":21.69,"quantity":4,"ns":27.960,"vat":2796,"tr":30756,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":7689,"pmGMP":21.69,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 18,"productCode":311593,"productName":"사조 조미김가루(1Kg/EA)","unit":"EA","sppVATincl":12826,"fmvVATincl":18323,"gpmFMV":30.0,"rrpVATincl":16500,"gpmRRP":22.27,"quantity":1,"ns":15.000,"vat":1500,"tr":16500,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":15565,"pmGMP":22.26,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
  {isFocusAtaVATincl:false,isFocusGpmAP:false, isFocusApVATincl:false,idx: 19,"productCode":323476,"productName":"쫀도그(장스푸드용 55g*9입 495g/EA)","unit":"EA","sppVATincl":6578,"fmvVATincl":9397,"gpmFMV":30.0,"rrpVATincl":7150,"gpmRRP":8.0,"quantity":15,"ns":97.500,"vat":9750,"tr":107250,"apVATincl":null,"gpmAP":null,"ar":null,"pmp":7150,"pmGMP":8.0,"ans":null,"aVAT":null,"atr":null,"ataVATincl":null},
];

customStyle = {
  id:'revenueAdjustment'
  ,style:`
  .revenueAdjustment.related-card .slds-card__header {
      border: 1px solid rgb(201,201,201);
      border-radius: 0.25rem 0.25rem 0 0;
      background-color: rgb(243, 243, 243);
      margin-bottom: 0;
      padding: 12px;
  }
  .revenueAdjustment.related-card .slds-card__body {
      margin-top: 0;
      margin-bottom:0;
      border: 1px solid rgb(201,201,201);
      border-top: 0;
      border-radius: 0 0 0.25rem 0.25rem;
      overflow: hidden;
  }
  .revenueAdjustment.related-card .btnFooter .textRight input[lightning-input_input] {
    text-align: right;
  }
  `
};

  connectedCallback() {
    setCustomStyle(this.customStyle.style, this.customStyle.id);

    Promise.all([
        loadStyle(this, CJFWCOMMCSS) 
    ])
    .then(() => {
        console.log('성공')
    })
    .catch(error => {
        console.error('error');
    });


  }

  /**
  * destroy method
  *
  */
  disconnectedCallback() {
    removeCustomStyle(this.customStyle.id);
  }

  renderedCallback() {
    if(!this._isInit) {
      
      this._isInit = true;
    }

  }

  handleSearch(event) {
    console.log('자식 search 버튼 클릭');
  }

  handleSave(event) {
    console.log('자식 save 버튼 클릭');
  }

  handleScroll(event) {

    //console.log(event.currentTarget.scrollTop);
    let rightContainer = event.currentTarget;
    let leftDiv = this.template.querySelector('.tableleftContainer');
    leftDiv.scrollTop = event.currentTarget.scrollTop;

    let scrollxSize= rightContainer.offsetHeight - rightContainer.clientHeight;

    leftDiv.style.cssText = 'padding-bottom:'+scrollxSize+'px;';
    //.slds-scrollable .leftContainer

    //console.log(leftDiv.scrollTop);
  }
  


  handleFocus(event) {
    // console.log('td focus')
    // console.log(event.eventPhase);
    event.stopImmediatePropagation();
    let tdCmp = event.currentTarget;
    let targetInfo = tdCmp.dataset.name;
    let field = tdCmp.dataset.field;
    let trCmp = tdCmp.parentElement;
    //field+'Str'
    let idx = trCmp.dataset.idx;
    
    let key = idx+'_'+targetInfo;

    
    
    let fieldValue = this.raData[idx][field];
    let self = this;
    if(this.tdFocusTimer[key]) {
      clearTimeout(this.tdFocusTimer[key]);
      this.tdFocusTimer[key] = undefined;
    }

    this.raData[idx][targetInfo] = true;

    let timerId = setTimeout(()=>{
      //console.log('td setTimeout');
      let input = self.template.querySelector('.'+targetInfo);
      if(input) {
        let inputValue= (fieldValue && typeof fieldValue == 'string') ? Number(fieldValue)  : fieldValue;
        
        //Infinity,NaN check
        let isNotNumber = this.notUseNumberList.includes(inputValue);
        if(!isNotNumber)
        input.value = inputValue;

        let checkValue = input.value;
        let existValueStr = this.raData[idx][field+'Str'];
        if(!checkValue || isNotNumber) {
          input.value = (existValueStr && typeof existValueStr == 'string') ? Number(existValueStr.replaceAll(/,/gm ,'')) : undefined; 
        }
        
        input.focus();
        this.tdFocusTimer[key] = undefined;
      }
    }, 100);
    
    this.tdFocusTimer[key] = timerId;
    //console.log(`timerId: ${timerId}`);
  }

  handleFocusOut(event) {
    //console.log('handleFocusOut');
    event.stopImmediatePropagation();
    let inputCmp = event.currentTarget;
    //console.log(inputCmp.value);
    
    let tdCmp = inputCmp.parentElement;
    let targetInfo = tdCmp.dataset.name;
    let field = tdCmp.dataset.field;
    let trCmp = inputCmp.parentElement.parentElement;
    let idx = trCmp.dataset.idx;

    let changeValue = (inputCmp?.value  && typeof inputCmp?.value == 'string') ? Number(inputCmp?.value)  : inputCmp?.value;

    if(changeValue == 0) {
      inputCmp.value = undefined;
    }
   

    if(changeValue) {
      this.raData[idx][field] = inputCmp.value;

      if(field =='apVATincl') {
        //조정판가 변경시 

        //조정 매익률
        let gpmAP = this.calculateGmpAP(this.raData[idx].sppVATincl, this.raData[idx].apVATincl); //(this.raData[idx].apVATincl - this.raData[idx].sppVATincl) / this.raData[idx].apVATincl * 100;
        
        // round 반올림 
        const result = Math.round(gpmAP * 100) / 100;
        this.raData[idx].gpmAP = changeValue != 0 ? result : undefined;
      }else if(field == 'gpmAP') {
        //조정 매익율 변경시 

        let sppVATincl = this.raData[idx].sppVATincl ; //기준 매입가

        //조정판가
        let apVATincl = this.calculateApVATincl(sppVATincl, inputCmp.value); // sppVATincl / ( 1 - inputCmp.value / 100);
        
        //내림
        const result = Math.floor(apVATincl);
        this.raData[idx].apVATincl = changeValue != 0 ? result : undefined;

      }
      this.raData[idx].atr = this.raData[idx].apVATincl * this.raData[idx].quantity;
      //조정 총 매출액 부가세 계산
      let vatInfo = this.calculateVAT(this.raData[idx].atr);
      this.raData[idx].ans = vatInfo.netRevenue;
      this.raData[idx].aVAT = vatInfo.vat;

      //조정감가율 
      let rateOfChange = this.calculateRateOfChage(this.raData[idx].gpmAP, this.raData[idx].gpmRRP);
      this.raData[idx].ar = changeValue != 0 ? rateOfChange : 0;

      //조정총액 계산
      this.raData[idx].ataVATincl = this.raData[idx].atr - this.raData[idx].tr;

    }else {
       //빈값일떄 초기화
      this.raData[idx].apVATincl = undefined;
      this.raData[idx].gpmAP = undefined;
      this.raData[idx].atr = undefined;
      this.raData[idx].ans = undefined;
      this.raData[idx].aVAT = undefined;
      this.raData[idx].ar = undefined;         //조정감가율 
      this.raData[idx].ataVATincl = undefined; //조정총액
    }
    //this.afterAdjustmentTotalSales; //getter 호출
    this.raData[idx][targetInfo] = false;
  }

  /**
  * 부가가치세 계산
  *
  *@param  변수명 조정 총매출액
  *@return  {netRevenue:순매출, vat:부가세 }
  */
  calculateVAT(totalRevenue) {
    let vat = (totalRevenue / 11);

    let netRevenue= Math.ceil(vat * 10);
    vat = Math.floor(vat);
    

    return {
      vat:vat,
      netRevenue:netRevenue
    };
  }

  /**
  * 조정 매익률로 조정 판가 구하는 메소드
  *
  *@param  sppVATincl 기준매입가
  *@param  gpmAP 매익률
  *@return  조정 판가
  */
  calculateApVATincl(sppVATincl, gpmAP) {
    //공식: 기준매입가 / ( 1 - 매익율/100) = 조정판가
    return sppVATincl / ( 1 - gpmAP / 100);
  }

  /**
  * 조정 매익률 구하는 메소드
  *
  *@param  sppVATincl 기준매입가
  *@param  apVATincl 조정판가
  *@return  매익률
  */
  calculateGmpAP(sppVATincl, apVATincl) {
    //공식:  1 - (기준매입가/조정판가) = 조정 매익률

    return (apVATincl - sppVATincl) / apVATincl * 100;
  }

  /**
  * 가감율 구하는 메소드 
  *
  *@param  gpmAP 매익율 조정판가
  *@param  gpmRRP 매익율 실판가
  *@return  감가율
  */
  calculateRateOfChage(gpmAP, gpmRRP) {
    //if(!gpmAP) return undefined;
    //TBD 공식 (조정판가 - 실판가)/실판가 * 100 = 가감율(올림) > 공식 안 맞음...
    //(매익율 조정판가 - 매익율 실판가)

    //가감율은 ?
    return gpmAP - gpmRRP;

  }


  get preAdjustmentTotalSales() {
    this._preAdjustmentTotalSales = 0;

    this.raData.forEach((raDatum)=>{
      if(raDatum.tr)
      this._preAdjustmentTotalSales += raDatum.tr;
    });
    this._preAdjustmentTotalSales = this._preAdjustmentTotalSales;

    return this._preAdjustmentTotalSales;
  }


  set preAdjustmentTotalSales(value) {
    this._preAdjustmentTotalSales = value;
  }

  get adjustedAmount() {
    this._adjustedAmount = 0;

    this.raData.forEach((raDatum)=>{
      if(raDatum.ataVATincl)
      this._adjustedAmount += raDatum.ataVATincl;
    });

    return this._adjustedAmount;
  }

  set adjustedAmount(value) {
    this._adjustedAmount;
  }


  get afterAdjustmentTotalSales() {

    return this.adjustedAmount + this.preAdjustmentTotalSales;
  }


  get raData() {
    this._raData.forEach((raDatum)=>{
        this.numberFieldList.forEach((numberField)=>{
          if(raDatum[numberField])
           raDatum[numberField+'Str'] = Number(raDatum[numberField]).toLocaleString('ko-KR');
        });
    });
    
    return this._raData;
  }

  set raData(value) {
    this._raData = value;
  }

}